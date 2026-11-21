import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jarvis_android/services/ai_gateway_service.dart';
import 'test_support/secure_storage_mock.dart';

void main(){
 TestWidgetsFlutterBinding.ensureInitialized();
 group('AI gateway routing',(){
  test('uses ordered fallback after HTTP 429 and 500',()async{
   installSecureStorageMock();
   SharedPreferences.setMockInitialValues({});
   final prefs=await SharedPreferences.getInstance();
   var calls=0;
   final service=AiGatewayService.forTesting(preferences:prefs,client:MockClient((request)async{
    calls++;
    if(request.url.host=='first.test')return http.Response('rate limit',429);
    if(request.url.host=='second.test')return http.Response('server error',500);
    return http.Response(jsonEncode({'choices':[{'message':{'content':'fallback reply'}}]}),200);
   }));
   await service.init();
   await service.updateProvider(service.providers[0].copyWith(baseUrl:'https://first.test/v1',enabled:true,priorityTier:0));
   await service.updateProvider(service.providers[4].copyWith(baseUrl:'https://second.test/v1',enabled:true,priorityTier:1));
   await service.updateProvider(service.providers[5].copyWith(baseUrl:'https://third.test/v1',enabled:true,priorityTier:2));
   for(var i=1;i<4;i++){await service.updateProvider(service.providers[i].copyWith(enabled:false));}
   final answer=await service.routeChatCompletion(messages:[{'role':'user','content':'ping'}]);
   expect(answer,'fallback reply');
   expect(calls,3);
   expect(service.lastActiveProvider,'omniroute_external');
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
   Future<String> request(String path)async{
    final socket=await Socket.connect('127.0.0.1',port);
    socket.write('GET $path HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: close\r\n\r\n');
    final response=await socket.fold<List<int>>(<int>[],(buffer,data)=>buffer..addAll(data));
    return utf8.decode(response);
   }
   final health=await request('/health');
   expect(health.startsWith('HTTP/1.1 200'),isTrue);
   expect(health,contains('"running":true'));
   final models=await request('/v1/models');
   expect(models.startsWith('HTTP/1.1 200'),isTrue);
   expect(models,contains('"object":"list"'));
   await service.stopLocalGateway();
   expect(service.localGatewayRunning,isFalse);
   service.dispose();
  });
  test('stopped embedded gateway keeps direct mode available',()async{
   SharedPreferences.setMockInitialValues({});
   final prefs=await SharedPreferences.getInstance();
   final service=AiGatewayService.forTesting(preferences:prefs);
   await service.init();
   expect(service.localGatewayRunning,isFalse);
   expect(service.autoFallbackEnabled,isFalse);
   await service.setAutoFallbackEnabled(false);
   expect(service.localGatewayRunning,isFalse);
   service.dispose();
  });
 });
}
