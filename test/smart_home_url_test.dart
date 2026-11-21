import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_android/services/smart_home_service.dart';

void main() {
  group('normalizeHomeAssistantBaseUrl', () {
    test('normalizes local host and trailing slashes', () {
      expect(normalizeHomeAssistantBaseUrl('localhost:8123///'), 'http://localhost:8123');
      expect(normalizeHomeAssistantBaseUrl('http://192.168.1.25:8123/'), 'http://192.168.1.25:8123');
    });

    test('allows RFC1918, loopback, link-local and IPv6 local addresses over HTTP', () {
      expect(normalizeHomeAssistantBaseUrl('http://10.1.2.3:8123'), 'http://10.1.2.3:8123');
      expect(normalizeHomeAssistantBaseUrl('http://172.20.2.3:8123'), 'http://172.20.2.3:8123');
      expect(normalizeHomeAssistantBaseUrl('http://192.168.0.5:8123'), 'http://192.168.0.5:8123');
      expect(normalizeHomeAssistantBaseUrl('http://127.0.0.1:8123'), 'http://127.0.0.1:8123');
      expect(normalizeHomeAssistantBaseUrl('http://[::1]:8123'), 'http://[::1]:8123');
      expect(normalizeHomeAssistantBaseUrl('http://[fc00::2]:8123'), 'http://[fc00::2]:8123');
      expect(normalizeHomeAssistantBaseUrl('http://[fe80::2]:8123'), 'http://[fe80::2]:8123');
    });

    test('allows HTTPS remote hosts and rejects HTTP public hosts', () {
      expect(normalizeHomeAssistantBaseUrl('https://ha.example.com/'), 'https://ha.example.com');
      expect(() => normalizeHomeAssistantBaseUrl('http://ha.example.com'), throwsFormatException);
      expect(() => normalizeHomeAssistantBaseUrl('http://fc-public.example.com'), throwsFormatException);
    });

    test('rejects embedded credentials, query, fragment and malformed URL', () {
      expect(() => normalizeHomeAssistantBaseUrl('http://user:pass@localhost:8123'), throwsFormatException);
      expect(() => normalizeHomeAssistantBaseUrl('http://localhost:8123/?token=x'), throwsFormatException);
      expect(() => normalizeHomeAssistantBaseUrl('http://localhost:8123/#fragment'), throwsFormatException);
      expect(() => normalizeHomeAssistantBaseUrl('http://:bad-port'), throwsFormatException);
    });
  });
}
