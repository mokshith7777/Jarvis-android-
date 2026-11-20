import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_android/services/voice_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('voice lifecycle exposes initial state', () {
    final v = VoiceService.instance;
    expect(v.listeningNotifier.value, isFalse);
    expect(v.lastError, isNull);
    expect(v.lastPermissionPermanentlyDenied, isFalse);
  });
}
