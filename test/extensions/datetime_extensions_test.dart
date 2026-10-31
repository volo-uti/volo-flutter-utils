import 'package:flutter_test/flutter_test.dart';
import 'package:volo_flutter_utils/volo_flutter_utils.dart';

void main() {
  group('VDateTimeExtension', () {
    group('isToday', () {
      test('check today', () {
        expect(DateTime.now().isToday, isTrue);
        expect(
          DateTime.now().subtract(const Duration(days: 1)).isToday,
          isFalse,
        );
      });
    });

    group('isTomorrow', () {
      test('check tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(tomorrow.isTomorrow, isTrue);
        expect(DateTime.now().isTomorrow, isFalse);
      });
    });

    group('isYesterday', () {
      test('check yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isYesterday, isTrue);
        expect(DateTime.now().isYesterday, isFalse);
      });
    });

    group('isThisMonth', () {
      test('check this month', () {
        expect(DateTime.now().isThisMonth, isTrue);
        final lastMonth = DateTime(
          DateTime.now().year,
          DateTime.now().month - 1,
        );
        expect(lastMonth.isThisMonth, isFalse);
      });
    });

    group('isThisYear', () {
      test('check this year', () {
        expect(DateTime.now().isThisYear, isTrue);
        final lastYear = DateTime(DateTime.now().year - 1);
        expect(lastYear.isThisYear, isFalse);
      });
    });

    group('isWeekend / isWeekday', () {
      test('check weekend/weekday', () {
        final saturday = DateTime(2024, 12, 28); // Saturday
        final sunday = DateTime(2024, 12, 29); // Sunday
        final monday = DateTime(2024, 12, 30); // Monday

        expect(saturday.isWeekend, isTrue);
        expect(sunday.isWeekend, isTrue);
        expect(monday.isWeekend, isFalse);

        expect(saturday.isWeekday, isFalse);
        expect(monday.isWeekday, isTrue);
      });
    });

    group('startOfDay / endOfDay', () {
      test('start/end of day', () {
        final date = DateTime(2024, 12, 28, 14, 30);

        final start = date.startOfDay;
        expect(start.hour, equals(0));
        expect(start.minute, equals(0));
        expect(start.second, equals(0));

        final end = date.endOfDay;
        expect(end.hour, equals(23));
        expect(end.minute, equals(59));
        expect(end.second, equals(59));
      });
    });

    group('startOfMonth / endOfMonth', () {
      test('start/end of month', () {
        final date = DateTime(2024, 12, 15);

        expect(date.startOfMonth.day, equals(1));
        expect(date.endOfMonth.day, equals(31));
      });
    });

    group('daysInMonth', () {
      test('days per month', () {
        expect(DateTime(2024, 2).daysInMonth, equals(29)); // Leap year
        expect(DateTime(2023, 2).daysInMonth, equals(28));
        expect(DateTime(2024, 12).daysInMonth, equals(31));
        expect(DateTime(2024, 4).daysInMonth, equals(30));
      });
    });

    group('isSameDay', () {
      test('same day comparison', () {
        final date1 = DateTime(2024, 12, 28, 10, 30);
        final date2 = DateTime(2024, 12, 28, 15, 45);
        final date3 = DateTime(2024, 12, 29, 10, 30);

        expect(date1.isSameDay(date2), isTrue);
        expect(date1.isSameDay(date3), isFalse);
      });
    });

    group('copyWith', () {
      test('field modification', () {
        final date = DateTime(2024, 12, 28, 14, 30);
        final modified = date.copyWith(hour: 0, minute: 0);

        expect(modified.year, equals(2024));
        expect(modified.month, equals(12));
        expect(modified.day, equals(28));
        expect(modified.hour, equals(0));
        expect(modified.minute, equals(0));
      });
    });

    group('calendar-based relative days', () {
      final now = DateTime.now();
      DateTime day(int offset, [int hour = 12]) =>
          DateTime(now.year, now.month, now.day + offset, hour);

      test('tomorrow and yesterday use calendar days', () {
        expect(day(1, 0).isTomorrow, isTrue);
        expect(day(1, 23).isTomorrow, isTrue);
        expect(day(2).isTomorrow, isFalse);
        expect(day(-1, 0).isYesterday, isTrue);
        expect(day(-1, 23).isYesterday, isTrue);
        expect(day(-2).isYesterday, isFalse);
      });

      test('isThisWeek covers Monday to Sunday of the current week', () {
        final monday = day(-(now.weekday - 1), 0);
        expect(monday.isThisWeek, isTrue);
        expect(
          DateTime(
            monday.year,
            monday.month,
            monday.day + 6,
            23,
            59,
          ).isThisWeek,
          isTrue,
        );
        expect(
          DateTime(
            monday.year,
            monday.month,
            monday.day - 1,
            23,
            59,
          ).isThisWeek,
          isFalse,
        );
        expect(
          DateTime(monday.year, monday.month, monday.day + 7).isThisWeek,
          isFalse,
        );
      });
    });

    group('month boundaries', () {
      test('leap-year February', () {
        final feb = DateTime(2024, 2, 10, 8);
        expect(feb.endOfMonth, DateTime(2024, 2, 29, 23, 59, 59, 999));
        expect(feb.startOfMonth, DateTime(2024, 2));
      });

      test('century years: 1900 is not leap, 2000 is', () {
        expect(DateTime(1900, 2).daysInMonth, 28);
        expect(DateTime(2000, 2).daysInMonth, 29);
      });

      test('December rolls into the next year without leaking', () {
        final dec = DateTime(2024, 12, 31, 5);
        expect(dec.endOfMonth, DateTime(2024, 12, 31, 23, 59, 59, 999));
        expect(dec.startOfMonth, DateTime(2024, 12));
      });

      test('endOfDay keeps the date and clears microseconds', () {
        final end = DateTime(2024, 3, 9, 1, 2, 3, 4, 5).endOfDay;
        expect(end, DateTime(2024, 3, 9, 23, 59, 59, 999));
      });

      test('startOfDay clears every smaller unit', () {
        final start = DateTime(2024, 3, 9, 1, 2, 3, 4, 5).startOfDay;
        expect(start, DateTime(2024, 3, 9));
      });
    });

    group('UTC values', () {
      test('copyWith keeps the UTC kind', () {
        final utc = DateTime.utc(2024, 5, 6, 7);
        expect(utc.copyWith(hour: 1).isUtc, isTrue);
        expect(utc.copyWith(hour: 1), DateTime.utc(2024, 5, 6, 1));
      });

      test('day and month boundaries keep the UTC kind', () {
        final utc = DateTime.utc(2024, 2, 10, 7);
        expect(utc.startOfDay, DateTime.utc(2024, 2, 10));
        expect(utc.endOfMonth, DateTime.utc(2024, 2, 29, 23, 59, 59, 999));
        expect(utc.daysInMonth, 29);
      });
    });

    group('copyWith overflow', () {
      test('day past month end normalises into the next month', () {
        expect(DateTime(2024, 1, 31).copyWith(month: 2), DateTime(2024, 3, 2));
      });
    });
  });
}
