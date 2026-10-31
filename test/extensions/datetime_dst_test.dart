// Runs only when the machine's time zone has daylight-saving time; the
// Makefile also runs it with TZ=America/New_York so CI always covers it.
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volo_flutter_utils/volo_flutter_utils.dart';

bool get _hasDst =>
    DateTime(2024).timeZoneOffset != DateTime(2024, 7).timeZoneOffset;

void main() {
  group(
    'daylight-saving transitions',
    skip: !_hasDst ? 'no DST here' : null,
    () {
      // Spring forward 2024-03-10 (23-hour day), fall back 2024-11-03 (25-hour
      // day) in America/New_York. A "+24 hours" implementation skips a day.
      test('isTomorrow just before the spring-forward day', () {
        withClock(Clock.fixed(DateTime(2024, 3, 9, 23, 30)), () {
          expect(DateTime(2024, 3, 10, 12).isTomorrow, isTrue);
          expect(DateTime(2024, 3, 10).isTomorrow, isTrue);
          expect(DateTime(2024, 3, 11, 0, 30).isTomorrow, isFalse);
        });
      });

      test('isYesterday just after the spring-forward day', () {
        withClock(Clock.fixed(DateTime(2024, 3, 11, 0, 30)), () {
          expect(DateTime(2024, 3, 10, 12).isYesterday, isTrue);
          expect(DateTime(2024, 3, 9, 23, 30).isYesterday, isFalse);
        });
      });

      test('isTomorrow and isYesterday around the fall-back day', () {
        withClock(Clock.fixed(DateTime(2024, 11, 2, 23, 30)), () {
          expect(DateTime(2024, 11, 3, 12).isTomorrow, isTrue);
          expect(DateTime(2024, 11, 4, 0, 30).isTomorrow, isFalse);
        });
        withClock(Clock.fixed(DateTime(2024, 11, 4, 0, 30)), () {
          expect(DateTime(2024, 11, 3, 12).isYesterday, isTrue);
          expect(DateTime(2024, 11, 2, 23, 30).isYesterday, isFalse);
        });
      });

      test('isThisWeek across the spring-forward Sunday', () {
        // Saturday 2024-03-09; the week is Mon 03-04 to Sun 03-10.
        withClock(Clock.fixed(DateTime(2024, 3, 9, 23, 30)), () {
          expect(DateTime(2024, 3, 4).isThisWeek, isTrue);
          expect(DateTime(2024, 3, 10, 23, 59).isThisWeek, isTrue);
          expect(DateTime(2024, 3, 11).isThisWeek, isFalse);
          expect(DateTime(2024, 3, 3, 23, 59).isThisWeek, isFalse);
        });
      });
    },
  );
}
