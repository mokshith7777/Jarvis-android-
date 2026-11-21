import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appointment_service.dart';
import 'settings_service.dart';
import 'telegram_service.dart';

@immutable
class CallLogEntry {
  final String number,name;
  final int type,date,duration;
  const CallLogEntry({required this.number,required this.name,required this.type,required this.date,required this.duration});
  bool get isMissed=>type==3;
  DateTime get callTime=>DateTime.fromMillisecondsSinceEpoch(date);
  factory CallLogEntry.fromMap(Map<dynamic,dynamic> m)=>CallLogEntry(number:(m['number']??'').toString(),name:(m['name']??'').toString(),type:(m['type'] as num?)?.toInt()??0,date:(m['date'] as num?)?.toInt()??0,duration:(m['duration'] as num?)?.toInt()??0);
}
class CallerAssistantService extends ChangeNotifier {
  CallerAssistantService._();
  static final CallerAssistantService instance=CallerAssistantService._();
  static const _channel=MethodChannel('com.mokshith.jarvis/accessibility');
  bool _optedIn=false,_loading=false;
  bool _initialized=false;
  static const _optInKey='jarvis_call_triage_opt_in_v1';
  Future<void> init()async{if(_initialized)return;final prefs=await SharedPreferences.getInstance();_optedIn=prefs.getBool(_optInKey)??false;_initialized=true;notifyListeners();}

  List<CallLogEntry> _calls=[];
  bool get optedIn=>_optedIn;
  bool get loading=>_loading;
  List<CallLogEntry> get recentCalls=>List.unmodifiable(_calls);
  Future<bool> requestCallLogPermission()async{try{return await _channel.invokeMethod<bool>('requestCallLogPermission')??false;}on PlatformException{return false;}}
  Future<void> setOptedIn(bool value)async{_optedIn=value;final prefs=await SharedPreferences.getInstance();await prefs.setBool(_optInKey,value);notifyListeners();}
  Future<void> loadRecentCalls({int limit=15})async{await init();if(!_optedIn)return;_loading=true;notifyListeners();try{final result=await _channel.invokeMethod<List<dynamic>>('getRecentCalls',{'limit':limit});_calls=(result??[]).whereType<Map>().map(CallLogEntry.fromMap).toList();}on PlatformException{_calls=[];}catch(_){_calls=[];}finally{_loading=false;notifyListeners();}}
  Future<AppointmentItem> createAppointmentFromCall(CallLogEntry call,{required String title,required DateTime scheduledAt,String notes=''})=>AppointmentService.instance.add(title:title,callerName:call.name,phoneNumber:call.number,scheduledAt:scheduledAt,notes:notes);
  String formatCallSummary(CallLogEntry call)=>'JARVIS PRO • Call follow-up draft
Caller: '+(call.name.isEmpty?'Unknown caller':call.name)+'
Number: '+call.number+'
Type: '+(call.isMissed?'Missed call':'Recent call')+'
Time: '+call.callTime.toLocal().toString()+'
Duration: '+call.duration.toString()+' seconds';
  Future<String> sendTelegramSummary(CallLogEntry call)async{final settings=SettingsService.instance;if(settings.telegramToken.isEmpty)return 'Telegram bot token is not configured in Settings.';if(settings.telegramOwnerChatId.isEmpty)return 'Telegram owner chat ID is not configured in Settings.';final success=await TelegramService.instance.sendMessage(settings.telegramOwnerChatId,formatCallSummary(call));return success?'Call summary sent to your configured Telegram owner chat.':'Telegram send failed. Check connection and bot configuration.';}
}
