import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_android/services/multi_task_service.dart';

void main() {
  group('parseReminderTime', () {
    final now = DateTime(2026, 11, 6, 15, 0);

    test('parses 12-hour time with AM/PM', () {
      expect(
        parseReminderTime('4:30 PM', now: now),
        DateTime(2026, 11, 6, 16, 30),
      );
    });

    test('parses 24-hour time', () {
      expect(
        parseReminderTime('09:05', now: now),
        DateTime(2026, 11, 7, 9, 5),
      );
    });

    test('moves a time that has passed to tomorrow', () {
      expect(
        parseReminderTime('14:30', now: now),
        DateTime(2026, 11, 7, 14, 30),
      );
    });

    test('rejects invalid values', () {
      expect(parseReminderTime('25:90', now: now), isNull);
      expect(parseReminderTime('not a time', now: now), isNull);
      expect(parseReminderTime(null, now: now), isNull);
    });
  });
}