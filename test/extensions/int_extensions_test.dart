import 'package:flutter_test/flutter_test.dart';
import 'package:volo_flutter_utils/volo_flutter_utils.dart';

void main() {
  group('VIntExtension', () {
    group('toDateTime', () {
      test('Unix timestamp to DateTime', () {
        final result = 1704067200.toDateTime().toUtc();
        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 1);
      });

      test('handles zero', () {
        final result = 0.toDateTime();
        expect(result, DateTime.fromMillisecondsSinceEpoch(0));
      });
    });

    group('toDateTimeMs', () {
      test('milliseconds to DateTime', () {
        final result = 1704067200000.toDateTimeMs().toUtc();
        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 1);
      });
    });

    group('isBetween', () {
      test('in range', () {
        expect(5.isBetween(1, 10), isTrue);
        expect(1.isBetween(1, 10), isTrue);
        expect(10.isBetween(1, 10), isTrue);
      });

      test('out of range', () {
        expect(0.isBetween(1, 10), isFalse);
        expect(11.isBetween(1, 10), isFalse);
      });
    });

    group('clampTo', () {
      test('clamps value', () {
        expect(5.clampTo(0, 10), 5);
        expect((-5).clampTo(0, 10), 0);
        expect(15.clampTo(0, 10), 10);
      });
    });

    group('padLeft', () {
      test('pads with zeros', () {
        expect(5.padLeft(2), '05');
        expect(42.padLeft(4), '0042');
        expect(123.padLeft(2), '123');
      });

      test('keeps the minus sign in front of the zeros', () {
        expect((-5).padLeft(3), '-05');
        expect((-123).padLeft(2), '-123');
        expect((-5).padLeft(1), '-5');
      });

      test('zero and non-positive widths', () {
        expect(0.padLeft(2), '00');
        expect(7.padLeft(0), '7');
      });
    });

    group('clampTo errors', () {
      test('throws when min is greater than max', () {
        expect(() => 1.clampTo(5, 1), throwsArgumentError);
      });
    });

    group('Duration getters', () {
      test('seconds', () {
        expect(90.seconds, const Duration(seconds: 90));
      });

      test('minutes', () {
        expect(5.minutes, const Duration(minutes: 5));
      });

      test('hours', () {
        expect(2.hours, const Duration(hours: 2));
      });

      test('days', () {
        expect(7.days, const Duration(days: 7));
      });

      test('milliseconds', () {
        expect(500.milliseconds, const Duration(milliseconds: 500));
      });
    });
  });
}
