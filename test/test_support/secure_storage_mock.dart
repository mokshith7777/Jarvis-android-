import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory MethodChannel fake for flutter_secure_storage.
/// Keeps widget/unit tests deterministic without requiring Android Keystore.
void installSecureStorageMock() {
  final values = <String, String>{};
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (call) async {
      final args = call.arguments;
      final map = args is Map ? args : const <Object?, Object?>{};
      final key = map['key']?.toString();

      switch (call.method) {
        case 'read':
          return key == null ? null : values[key];
        case 'write':
          if (key != null) values[key] = map['value']?.toString() ?? '';
          return null;
        case 'delete':
          if (key != null) values.remove(key);
          return null;
        case 'deleteAll':
          values.clear();
          return null;
        case 'containsKey':
          return key != null && values.containsKey(key);
        default:
          return null;
      }
    },
  );
}
