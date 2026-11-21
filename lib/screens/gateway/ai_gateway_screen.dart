import 'package:flutter/material.dart';
import '../../services/ai_gateway_service.dart';
import '../../services/settings_service.dart';

class AiGatewayScreen extends StatefulWidget {
 const AiGatewayScreen({super.key});
 @override State<AiGatewayScreen> createState()=>_AiGatewayScreenState();
}
class _AiGatewayScreenState extends State<AiGatewayScreen>{
 final gateway=AiGatewayService.instance;
 final Map<String,TextEditingController> _urls={},_models={},_keys={};
 final Map<String,String> _tests={};
 bool _loading=true;
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{await gateway.init();for(final p in gateway.providers){_urls[p.id]=TextEditingController(text:p.baseUrl);_models[p.id]=TextEditingController(text:p.model);_keys[p.id]=TextEditingController(text:'');}if(mounted)setState(()=>_loading=false);}
 @override void dispose(){for(final c in [..._urls.values,..._models.values,..._keys.values]){c.dispose();}super.dispose();}
 Future<void> _save(AiProviderConfig p)async{await gateway.updateProvider(p.copyWith(baseUrl:_urls[p.id]!.text.trim(),model:_models[p.id]!.text.trim()));if(_keys[p.id]!.text.trim().isNotEmpty){await SettingsService.instance.setProviderApiKey(p.id,_keys[p.id]!.text);_keys[p.id]!.clear();}if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Provider settings saved securely')));}
 Future<void> _test(String id)async{setState(()=>_tests[id]='Testing…');final result=await gateway.testProvider(id);if(mounted)setState(()=>_tests[id]=result);}
 @override Widget build(BuildContext context){const bg=Color(0xFF050505),panel=Color(0xFF141522),accent=Color(0xFF5E4AE3);return AnimatedBuilder(animation:gateway,builder:(context,_)=>Scaffold(backgroundColor:bg,appBar:AppBar(backgroundColor:panel,title:const Text('JARVIS PRO • AI Gateway')),body:_loading?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.all(12),children:[
 Card(color:panel,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16),side:const BorderSide(color:accent)),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 Row(children:[const Expanded(child:Text('Embedded Gateway',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold))),Chip(label:Text(gateway.localGatewayRunning?'RUNNING':'STOPPED'),backgroundColor:gateway.localGatewayRunning?Colors.green.withOpacity(.18):Colors.grey.withOpacity(.15),labelStyle:TextStyle(color:gateway.localGatewayRunning?Colors.greenAccent:Colors.white70))]),
 const Text('http://127.0.0.1:20128/v1',style:TextStyle(color:Colors.white70)),const SizedBox(height:8),
 Row(children:[Expanded(child:ElevatedButton(onPressed:gateway.localGatewayRunning?null:()async{final ok=await gateway.startLocalGateway();if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(ok?'Gateway started on loopback':'Port unavailable or gateway could not start')));},child:const Text('Start'))),const SizedBox(width:8),Expanded(child:OutlinedButton(onPressed:gateway.localGatewayRunning?gateway.stopLocalGateway:null,child:const Text('Stop')))]),
 Wrap(spacing:8,children:[Chip(label:Text('Active: '+(gateway.lastActiveProvider??'None')),backgroundColor:panel,labelStyle:const TextStyle(color:Colors.white70)),Chip(label:Text('Model: '+(gateway.providers.firstWhere((p)=>p.id==gateway.lastActiveProvider,orElse:()=>gateway.providers.first).model)),backgroundColor:panel,labelStyle:const TextStyle(color:Colors.white70))])
 ]))),
 SwitchListTile(tileColor:panel,title:const Text('AI fallback routing',style:TextStyle(color:Colors.white)),subtitle:const Text('Use provider failover when the embedded gateway is running. Direct AI mode remains available when stopped.'),value:gateway.autoFallbackEnabled,onChanged:gateway.setAutoFallbackEnabled),
 const Padding(padding:EdgeInsets.all(8),child:Text('Providers • drag to prioritize',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))),
 ReorderableListView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:gateway.providers.length,onReorder:gateway.reorderProviders,itemBuilder:(context,index){final p=gateway.providers[index];final stat=gateway.telemetryFor(p.id);return Card(key:ValueKey(p.id),color:panel,child:ExpansionTile(leading:const Icon(Icons.drag_handle,color:Colors.white54),title:Text(p.displayName,style:const TextStyle(color:Colors.white)),subtitle:Text('Requests: ${stat.requestCount} • Errors: ${stat.errorCount} • ${stat.isCoolingDown?'Cooling down':'Ready'}',style:const TextStyle(color:Colors.white54)),trailing:Switch(value:p.enabled,onChanged:(v)=>gateway.updateProvider(p.copyWith(enabled:v))),children:[Padding(padding:const EdgeInsets.all(12),child:Column(children:[
 TextField(controller:_models[p.id],style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Model name',labelStyle:TextStyle(color:Colors.white54))),
 TextField(controller:_urls[p.id],style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Base URL',labelStyle:TextStyle(color:Colors.white54))),
 TextField(controller:_keys[p.id],style:const TextStyle(color:Colors.white),obscureText:true,decoration:const InputDecoration(labelText:'API key (secure storage, optional)',labelStyle:TextStyle(color:Colors.white54))),
 if(stat.lastLatency!=null)Align(alignment:Alignment.centerLeft,child:Text('Last latency: ${stat.lastLatency!.inMilliseconds} ms',style:const TextStyle(color:Colors.white60))),
 if(stat.isCoolingDown)Align(alignment:Alignment.centerLeft,child:Text('Circuit breaker until ${stat.cooldownUntil}',style:const TextStyle(color:Colors.orange))),
 if(_tests[p.id]!=null)Align(alignment:Alignment.centerLeft,child:Text(_tests[p.id]!,style:const TextStyle(color:Colors.white70))),
 Row(children:[TextButton(onPressed:()=>_test(p.id),child:const Text('Latency / health test')),const Spacer(),ElevatedButton(onPressed:()=>_save(p),child:const Text('Save'))])
 ]))]));}),
 const SizedBox(height:12),const Text('Gateway is loopback-only. External OmniRoute and the embedded server both default to port 20128, so they cannot be active simultaneously at that address.',style:TextStyle(color:Colors.white54))
 ])));
}
}
