import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volo_flutter_utils/volo_flutter_utils.dart';

void main() {
  group('VTimeOfDayExtension', () {
    group('toDateTime', () {
      test('uses today when no date provided', () {
        const time = TimeOfDay(hour: 14, minute: 30);
        final result = time.toDateTime();
        final now = DateTime.now();

        expect(result.year, now.year);
        expect(result.month, now.month);
        expect(result.day, now.day);
        expect(result.hour, 14);
        expect(result.minute, 30);
      });

      test('uses the clock for today', () {
        const time = TimeOfDay(hour: 14, minute: 30);
        final result = withClock(
          Clock.fixed(DateTime(2030, 6, 15, 8)),
          time.toDateTime,
        );

        expect(result, DateTime(2030, 6, 15, 14, 30));
      });

      test('uses provided date', () {
        const time = TimeOfDay(hour: 9, minute: 0);
        final date = DateTime(2024, 1, 15);
        final result = time.toDateTime(date: date);

        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 15);
        expect(result.hour, 9);
        expect(result.minute, 0);
      });
    });

    group('isBefore', () {
      test('returns true when before', () {
        const time1 = TimeOfDay(hour: 9, minute: 0);
        const time2 = TimeOfDay(hour: 10, minute: 0);
        expect(time1.isBefore(time2), true);
      });

      test('returns true when same hour but earlier minute', () {
        const time1 = TimeOfDay(hour: 10, minute: 0);
        const time2 = TimeOfDay(hour: 10, minute: 30);
        expect(time1.isBefore(time2), true);
      });

      test('returns false when after', () {
        const time1 = TimeOfDay(hour: 10, minute: 30);
        const time2 = TimeOfDay(hour: 10, minute: 0);
        expect(time1.isBefore(time2), false);
      });

      test('returns false when equal', () {
        const time1 = TimeOfDay(hour: 10, minute: 30);
        const time2 = TimeOfDay(hour: 10, minute: 30);
        expect(time1.isBefore(time2), false);
      });
    });

    group('isAfter', () {
      test('returns true when after', () {
        const time1 = TimeOfDay(hour: 10, minute: 0);
        const time2 = TimeOfDay(hour: 9, minute: 0);
        expect(time1.isAfter(time2), true);
      });

      test('returns true when same hour but later minute', () {
        const time1 = TimeOfDay(hour: 10, minute: 30);
        const time2 = TimeOfDay(hour: 10, minute: 0);
        expect(time1.isAfter(time2), true);
      });

      test('returns false when before', () {
        const time1 = TimeOfDay(hour: 9, minute: 0);
        const time2 = TimeOfDay(hour: 10, minute: 0);
        expect(time1.isAfter(time2), false);
      });

      test('returns false when equal', () {
        const time1 = TimeOfDay(hour: 10, minute: 30);
        const time2 = TimeOfDay(hour: 10, minute: 30);
        expect(time1.isAfter(time2), false);
      });
    });

    group('toMinutes', () {
      test('converts to total minutes', () {
        const time = TimeOfDay(hour: 1, minute: 30);
        expect(time.toMinutes(), 90);
      });

      test('handles midnight', () {
        const time = TimeOfDay(hour: 0, minute: 0);
        expect(time.toMinutes(), 0);
      });

      test('handles end of day', () {
        const time = TimeOfDay(hour: 23, minute: 59);
        expect(time.toMinutes(), 1439);
      });
    });

    group('add', () {
      test('adds hours', () {
        const time = TimeOfDay(hour: 10, minute: 30);
        final result = time.add(const Duration(hours: 2));
        expect(result.hour, 12);
        expect(result.minute, 30);
      });

      test('adds minutes', () {
        const time = TimeOfDay(hour: 10, minute: 30);
        final result = time.add(const Duration(minutes: 45));
        expect(result.hour, 11);
        expect(result.minute, 15);
      });

      test('wraps around midnight', () {
        const time = TimeOfDay(hour: 23, minute: 30);
        final result = time.add(const Duration(hours: 2));
        expect(result.hour, 1);
        expect(result.minute, 30);
      });
    });

    group('subtract', () {
      test('subtracts hours', () {
        const time = TimeOfDay(hour: 10, minute: 30);
        final result = time.subtract(const Duration(hours: 2));
        expect(result.hour, 8);
        expect(result.minute, 30);
      });

      test('subtracts minutes', () {
        const time = TimeOfDay(hour: 10, minute: 30);
        final result = time.subtract(const Duration(minutes: 45));
        expect(result.hour, 9);
        expect(result.minute, 45);
      });

      test('wraps around midnight', () {
        const time = TimeOfDay(hour: 1, minute: 30);
        final result = time.subtract(const Duration(hours: 2));
        expect(result.hour, 23);
        expect(result.minute, 30);
      });
    });

    group('difference', () {
      test('returns positive difference', () {
        const time1 = TimeOfDay(hour: 10, minute: 30);
        const time2 = TimeOfDay(hour: 9, minute: 0);
        expect(time1.difference(time2), 90);
      });

      test('returns negative difference', () {
        const time1 = TimeOfDay(hour: 9, minute: 0);
        const time2 = TimeOfDay(hour: 10, minute: 30);
        expect(time1.difference(time2), -90);
      });

      test('returns zero for same time', () {
        const time1 = TimeOfDay(hour: 10, minute: 30);
        const time2 = TimeOfDay(hour: 10, minute: 30);
        expect(time1.difference(time2), 0);
      });
    });

    group('midnight wrap and minute truncation', () {
      test('add and subtract wrap exactly at midnight', () {
        const t = TimeOfDay(hour: 23, minute: 59);
        expect(
          t.add(const Duration(minutes: 1)),
          const TimeOfDay(hour: 0, minute: 0),
        );
        const z = TimeOfDay(hour: 0, minute: 0);
        expect(z.subtract(const Duration(minutes: 1)), t);
      });

      test('durations longer than a day wrap by whole days', () {
        const t = TimeOfDay(hour: 10, minute: 0);
        expect(
          t.add(const Duration(days: 3, hours: 2)),
          const TimeOfDay(hour: 12, minute: 0),
        );
        expect(
          t.subtract(const Duration(days: 3, hours: 11)),
          const TimeOfDay(hour: 23, minute: 0),
        );
      });

      test('negative duration reverses the direction', () {
        const t = TimeOfDay(hour: 10, minute: 0);
        expect(
          t.add(const Duration(hours: -2)),
          const TimeOfDay(hour: 8, minute: 0),
        );
        expect(
          t.subtract(const Duration(hours: -2)),
          const TimeOfDay(hour: 12, minute: 0),
        );
      });

      test('seconds below a minute are dropped', () {
        const t = TimeOfDay(hour: 10, minute: 0);
        expect(t.add(const Duration(seconds: 59)), t);
      });

      test('difference does not wrap', () {
        const a = TimeOfDay(hour: 0, minute: 10);
        const b = TimeOfDay(hour: 23, minute: 50);
        expect(a.difference(b), -1420);
        expect(b.difference(a), 1420);
      });

      test('toMinutes spans 0 to 1439', () {
        expect(const TimeOfDay(hour: 0, minute: 0).toMinutes(), 0);
        expect(const TimeOfDay(hour: 23, minute: 59).toMinutes(), 1439);
      });
    });
  });
}
