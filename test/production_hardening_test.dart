import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jarvis_android/services/ai_service.dart';
import 'package:jarvis_android/services/local_worker_service.dart';

void main() {
  group('Local backend address validation', () {
    test('accepts loopback, private LAN, and Tailscale CGNAT', () {
      for (final url in [
        'http://localhost:9000/v1',
        'http://127.0.0.1:9000/v1',
        'http://10.2.3.4:9000/v1',
        'http://172.16.0.1:9000/v1',
        'http://172.31.255.254:9000/v1',
        'http://192.168.1.20:9000/v1',
        'http://100.64.0.1:9000/v1',
        'http://100.127.255.254:9000/v1',
        'http://jarvis-device.local:9000/v1',
        'http://device.tailnet.ts.net:9000/v1',
        'http://[::1]:9000/v1',
      ]) {
        expect(
          AiService.isLocalBackendConfig(provider: 'custom', baseUrl: url),
          isTrue,
          reason: url,
        );
      }
    });

    test('rejects public addresses and non-Tailscale 100/8 addresses', () {
      for (final url in [
        'https://api.example.com/v1',
        'http://8.8.8.8:9000/v1',
        'http://172.15.255.255:9000/v1',
        'http://172.32.0.1:9000/v1',
        'http://100.63.255.255:9000/v1',
        'http://100.128.0.1:9000/v1',
        'http://100.10.0.1:9000/v1',
      ]) {
        expect(
          AiService.isLocalBackendConfig(provider: 'custom', baseUrl: url),
          isFalse,
          reason: url,
        );
      }
    });

    test('explicit local providers and privacy mode remain local', () {
      expect(
        AiService.isLocalBackendConfig(
          provider: 'jarvis_local',
          baseUrl: 'https://remote.example',
        ),
        isTrue,
      );
      expect(
        AiService.isLocalBackendConfig(
          provider: 'ollama',
          baseUrl: 'https://remote.example',
        ),
        isTrue,
      );
      expect(
        AiService.isLocalBackendConfig(
          provider: 'custom',
          baseUrl: 'https://remote.example',
          localFirstPrivacyMode: true,
        ),
        isTrue,
      );
    });
  });

  group('Local worker error parsing', () {
    test('uses API detail and appends HTTP status', () async {
      final service = LocalWorkerService.forTesting(
        client: MockClient((request) async => http.Response(
          '{"detail":"Model is not configured"}',
          503,
        )),
        baseUrl: 'http://127.0.0.1:9000',
      );
      await expectLater(
        service.browse('test'),
        throwsA(predicate((error) =>
            error.toString().contains('Model is not configured (HTTP 503)'))),
      );
    });

    test('handles malformed error JSON without crashing the parser', () async {
      final service = LocalWorkerService.forTesting(
        client: MockClient((request) async =>
            http.Response('upstream unavailable', 502)),
        baseUrl: 'http://127.0.0.1:9000',
      );
      await expectLater(
        service.health(),
        throwsA(predicate((error) =>
            error.toString().contains('upstream unavailable (HTTP 502)'))),
      );
    });
  });
}
