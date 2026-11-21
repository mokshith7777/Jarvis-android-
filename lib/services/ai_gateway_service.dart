import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_service.dart';

@immutable
class AiProviderConfig {
  final String id, displayName, baseUrl, model;
  final int priorityTier;
  final bool enabled;
  const AiProviderConfig({required this.id, required this.displayName, required this.baseUrl, required this.model, required this.priorityTier, this.enabled = true});
  AiProviderConfig copyWith({String? baseUrl, String? model, int? priorityTier, bool? enabled}) => AiProviderConfig(id:id,displayName:displayName,baseUrl:baseUrl??this.baseUrl,model:model??this.model,priorityTier:priorityTier??this.priorityTier,enabled:enabled??this.enabled);
  Map<String,dynamic> toJson()=>{'id':id,'displayName':displayName,'baseUrl':baseUrl,'model':model,'priorityTier':priorityTier,'enabled':enabled};
  factory AiProviderConfig.fromJson(Map<String,dynamic> j)=>AiProviderConfig(id:(j['id']??'').toString(),displayName:(j['displayName']??j['id']??'').toString(),baseUrl:(j['baseUrl']??'').toString(),model:(j['model']??'').toString(),priorityTier:(j['priorityTier'] as num?)?.toInt()??0,enabled:(j['enabled'] as bool?)??true);
}
class AiProviderTelemetry {
  int requestCount=0,errorCount=0,consecutiveFailures=0;
  Duration? lastLatency;
  DateTime? cooldownUntil;
  bool get isCoolingDown=>cooldownUntil!=null&&cooldownUntil!.isAfter(DateTime.now());
}
class AiGatewayService extends ChangeNotifier {
  AiGatewayService._({http.Client? client,SharedPreferences? preferences}):_client=client??http.Client(),_prefs=preferences;
  static final AiGatewayService instance=AiGatewayService._();
  @visibleForTesting
  factory AiGatewayService.forTesting({http.Client? client,SharedPreferences? preferences})=>AiGatewayService._(client:client,preferences:preferences);
  static const _storage='jarvis_ai_gateway_providers_v1',_fallback='jarvis_ai_gateway_auto_fallback_v1';
  static const defaults=<AiProviderConfig>[
    AiProviderConfig(id:'jarvis_local',displayName:'JARVIS Local',baseUrl:'http://127.0.0.1:9000/v1',model:'local-vision',priorityTier:0),
    AiProviderConfig(id:'gemini',displayName:'Gemini',baseUrl:'https://generativelanguage.googleapis.com/v1beta/openai',model:'gemini-2.0-flash',priorityTier:1),
    AiProviderConfig(id:'openrouter',displayName:'OpenRouter',baseUrl:'https://openrouter.ai/api/v1',model:'openai/gpt-4o-mini',priorityTier:2),
    AiProviderConfig(id:'groq',displayName:'Groq',baseUrl:'https://api.groq.com/openai/v1',model:'llama-3.3-70b-versatile',priorityTier:3),
    AiProviderConfig(id:'ollama',displayName:'Ollama',baseUrl:'http://127.0.0.1:11434/v1',model:'llama3.2',priorityTier:4),
    AiProviderConfig(id:'omniroute_external',displayName:'External OmniRoute',baseUrl:'http://127.0.0.1:20128/v1',model:'auto',priorityTier:5,enabled:false),
  ];
  final http.Client _client;
  SharedPreferences? _prefs;
  List<AiProviderConfig> _providers=List.of(defaults);
  final Map<String,AiProviderTelemetry> _stats={};
  HttpServer? _server;
  bool _loaded=false,_starting=false;
  String? _lastProvider;
  List<AiProviderConfig> get providers=>List.unmodifiable(_providers);
  bool get localGatewayRunning=>_server!=null;
  int? get localGatewayPort=>_server?.port;
  String? get lastActiveProvider=>_lastProvider;
  bool get autoFallbackEnabled=>_prefs?.getBool(_fallback)??false;
  AiProviderTelemetry telemetryFor(String id)=>_stats.putIfAbsent(id,AiProviderTelemetry.new);
  Future<void> init() async {
    if(_loaded)return;
    _prefs??=await SharedPreferences.getInstance();
    final raw=_prefs!.getString(_storage);
    if(raw!=null){try{final list=jsonDecode(raw) as List;final saved=list.whereType<Map>().map((e)=>AiProviderConfig.fromJson(Map<String,dynamic>.from(e))).toList();final ids=saved.map((p)=>p.id).toSet();_providers=[...saved,...defaults.where((p)=>!ids.contains(p.id))];}catch(_){}}
    _loaded=true;
  }
  Future<void> setAutoFallbackEnabled(bool value)async{await init();await _prefs!.setBool(_fallback,value);notifyListeners();}
  Future<void> updateProvider(AiProviderConfig p)async{await init();final i=_providers.indexWhere((x)=>x.id==p.id);if(i<0)return;_providers[i]=p;await _persist();}
  Future<void> reorderProviders(int oldIndex,int newIndex)async{await init();if(newIndex>oldIndex)newIndex--;final p=_providers.removeAt(oldIndex);_providers.insert(newIndex,p);for(var i=0;i<_providers.length;i++){_providers[i]=_providers[i].copyWith(priorityTier:i);}await _persist();}
  Future<void> _persist()async{await _prefs!.setString(_storage,jsonEncode(_providers.map((p)=>p.toJson()).toList()));notifyListeners();}
  Future<String> testProvider(String id)async{await init();final p=_providers.firstWhere((x)=>x.id==id);final start=DateTime.now();final key=await SettingsService.instance.getProviderApiKey(id);try{final r=await _client.get(Uri.parse(p.baseUrl.replaceAll(RegExp(r'/+$'),'')+'/models'),headers:{if(key.isNotEmpty)'Authorization':'Bearer '+key}).timeout(const Duration(seconds:10));telemetryFor(id).lastLatency=DateTime.now().difference(start);return 'HTTP '+r.statusCode.toString()+' • '+telemetryFor(id).lastLatency!.inMilliseconds.toString()+' ms';}catch(e){telemetryFor(id).lastLatency=DateTime.now().difference(start);return 'Failed: '+e.toString();}}
  Future<String> routeChatCompletion({required List<Map<String,dynamic>> messages,int maxTokens=2048,double temperature=0.2})async{
    await init();final ordered=_providers.where((p)=>p.enabled).toList()..sort((a,b)=>a.priorityTier.compareTo(b.priorityTier));if(ordered.isEmpty)throw const AiGatewayException('No enabled AI providers.');
    final errors=<String>[];
    for(final p in ordered){final s=telemetryFor(p.id);if(s.isCoolingDown){errors.add(p.displayName+': cooldown');continue;}
      final baseUri=Uri.tryParse(p.baseUrl);
      if(_server!=null&&p.id=='omniroute_external'&&baseUri?.port==_server!.port&&['127.0.0.1','localhost'].contains(baseUri?.host)){errors.add('External OmniRoute shares the embedded gateway port');continue;}
      final key=await SettingsService.instance.getProviderApiKey(p.id);if(key.isEmpty&&!['jarvis_local','ollama','omniroute_external'].contains(p.id)){errors.add(p.displayName+': API key missing');continue;}
      s.requestCount++;final start=DateTime.now();
      try{final response=await _client.post(Uri.parse(p.baseUrl.replaceAll(RegExp(r'/+$'),'')+'/chat/completions'),headers:{'Content-Type':'application/json',if(key.isNotEmpty)'Authorization':'Bearer '+key,if(p.id=='openrouter')'HTTP-Referer':'https://jarvis.local',if(p.id=='openrouter')'X-Title':'JARVIS PRO'},body:jsonEncode({'model':p.model,'messages':messages,'max_tokens':maxTokens,'temperature':temperature,'stream':false})).timeout(const Duration(seconds:60));
        s.lastLatency=DateTime.now().difference(start);if(response.statusCode<200||response.statusCode>=300){final body=response.body;final snippet=body.length>250?body.substring(0,250):body;throw AiGatewayException('HTTP '+response.statusCode.toString()+': '+snippet,statusCode:response.statusCode);}
        final decoded=jsonDecode(utf8.decode(response.bodyBytes));final choices=decoded is Map?decoded['choices']:null;if(choices is! List||choices.isEmpty)throw const AiGatewayException('No choices in response');
        final content=choices.first is Map?choices.first['message']?['content']:null;
        if(content is String&&content.trim().isNotEmpty){s.consecutiveFailures=0;s.cooldownUntil=null;_lastProvider=p.id;notifyListeners();return content;}
        if(content is List){final joined=content.map((x)=>x is Map?(x['text']??'').toString():x.toString()).join();if(joined.trim().isNotEmpty){s.consecutiveFailures=0;s.cooldownUntil=null;_lastProvider=p.id;notifyListeners();return joined;}}
        throw const AiGatewayException('Empty assistant content');
      }catch(e){s.errorCount++;s.consecutiveFailures++;if(s.consecutiveFailures>=3)s.cooldownUntil=DateTime.now().add(const Duration(seconds:60));errors.add(p.displayName+': '+e.toString());}
    }notifyListeners();throw AiGatewayException('All providers failed: '+errors.join(' | '));
  }
  Future<bool> startLocalGateway({int port=20128})async{if(_server!=null||_starting)return _server!=null;_starting=true;try{_server=await HttpServer.bind(InternetAddress.loopbackIPv4,port);_server!.listen(_handleRequest,onError:(_)=>{});notifyListeners();return true;}on SocketException{_server=null;notifyListeners();return false;}finally{_starting=false;}}
  Future<void> stopLocalGateway()async{final s=_server;_server=null;await s?.close(force:true);notifyListeners();}
  Future<void> _handleRequest(HttpRequest r)async{try{if(r.method=='GET'&&r.uri.path=='/health'){await _writeJson(r.response,{'status':'ok','service':'JARVIS PRO AI Gateway','running':true});return;}if(r.method=='GET'&&r.uri.path=='/v1/models'){await _writeJson(r.response,{'object':'list','data':_providers.where((p)=>p.enabled).map((p)=>{'id':p.model,'object':'model','owned_by':p.id}).toList()});return;}if(r.method=='POST'&&r.uri.path=='/v1/chat/completions'){final decoded=jsonDecode(await utf8.decoder.bind(r).join());final msgs=(decoded['messages'] as List).map((e)=>Map<String,dynamic>.from(e as Map)).toList();final answer=await routeChatCompletion(messages:msgs,maxTokens:(decoded['max_tokens'] as num?)?.toInt()??2048,temperature:(decoded['temperature'] as num?)?.toDouble()??0.2);await _writeJson(r.response,{'id':'jarvis-gateway','object':'chat.completion','choices':[{'index':0,'message':{'role':'assistant','content':answer},'finish_reason':'stop'}]});return;}r.response.statusCode=404;await _writeJson(r.response,{'error':'Not found'});}catch(e){r.response.statusCode=502;await _writeJson(r.response,{'error':e.toString()});}}
  Future<void> _writeJson(HttpResponse r,Object value)async{r.headers.contentType=ContentType.json;r.write(jsonEncode(value));await r.close();}
  @override void dispose(){final server=_server;_server=null;if(server!=null)unawaited(server.close(force:true));_client.close();super.dispose();}
}
class AiGatewayException implements Exception{final String message;final int? statusCode;const AiGatewayException(this.message,{this.statusCode});@override String toString()=>message;}
