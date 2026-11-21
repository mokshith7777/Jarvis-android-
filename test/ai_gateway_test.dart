import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jarvis_android/services/ai_gateway_service.dart';

void main(){
 TestWidgetsFlutterBinding.ensureInitialized();
 group('AI gateway routing',(){
  test('uses ordered fallback after HTTP 429 and 500',()async{
   SharedPreferences.setMockInitialValues({});
   final prefs=await SharedPreferences.getInstance();
   var calls=0;
   final service=AiGatewayService.forTesting(preferences:prefs,client:MockClient((request)async{
    calls++;
    if(request.url.host=='first.test')return http.Response('rate limit',429);
    return http.Response(jsonEncode({'choices':[{'message':{'content':'fallback reply'}}]}),200);
   }));
   await service.init();
   await service.updateProvider(service.providers[0].copyWith(baseUrl:'https://first.test/v1',enabled:true,priorityTier:0));
   await service.updateProvider(service.providers[1].copyWith(baseUrl:'https://second.test/v1',enabled:true,priorityTier:1));
   for(var i=2;i<service.providers.length;i++){await service.updateProvider(service.providers[i].copyWith(enabled:false));}
   final answer=await service.routeChatCompletion(messages:[{'role':'user','content':'ping'}]);
   expect(answer,'fallback reply');expect(calls,3);expect(service.lastActiveProvider,'omniroute_external');
   service.dispose();
  });
  test('circuit breaker cools down after three provider failures',()async{
   SharedPreferences.setMockInitialValues({});
   final prefs=await SharedPreferences.getInstance();
   final service=AiGatewayService.forTesting(preferences:prefs,client:MockClient((_)async=>http.Response('failure',500)));
   await service.init();
   await service.updateProvider(service.providers[0].copyWith(baseUrl:'https://broken.test/v1',enabled:true));
   for(var i=1;i<service.providers.length;i++){await service.updateProvider(service.providers[i].copyWith(enabled:false));}
   for(var i=0;i<3;i++){await expectLater(service.routeChatCompletion(messages:[]),throwsA(isA<AiGatewayException>()));}
   expect(service.telemetryFor('jarvis_local').consecutiveFailures,3);
   expect(service.telemetryFor('jarvis_local').isCoolingDown,isTrue);
   service.dispose();
  });
  test('loopback health and models endpoints respond',()async{
   SharedPreferences.setMockInitialValues({});
   final prefs=await SharedPreferences.getInstance();
   final service=AiGatewayService.forTesting(preferences:prefs,client:MockClient((_)async=>http.Response('no upstream',503)));
   await service.init();
   final started=await service.startLocalGateway(port:0);
   expect(started,isTrue);
   final port=service.localGatewayPort!;
   final health=await http.get(Uri.parse('http://127.0.0.1:$port/health'));
   expect(health.statusCode,200);expect(jsonDecode(health.body)['running'],true);
   final models=await http.get(Uri.parse('http://127.0.0.1:$port/v1/models'));
   expect(models.statusCode,200);expect(jsonDecode(models.body)['object'],'list');
   await service.stopLocalGateway();
   expect(service.localGatewayRunning,isFalse);
   service.dispose();
  });
 });
}
