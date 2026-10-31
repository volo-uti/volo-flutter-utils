import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volo_flutter_utils/volo_flutter_utils.dart';

void main() {
  group('VDebouncer', () {
    test('a burst runs the callback once, after the last call', () {
      fakeAsync((async) {
        var count = 0;
        final debouncer = VDebouncer(const Duration(milliseconds: 50), () {
          count++;
        });

        debouncer();
        async.elapse(const Duration(milliseconds: 30));
        debouncer();
        async.elapse(const Duration(milliseconds: 30));
        debouncer();
        expect(count, 0);

        async.elapse(const Duration(milliseconds: 49));
        expect(count, 0);
        async.elapse(const Duration(milliseconds: 1));
        expect(count, 1);

        async.elapse(const Duration(seconds: 1));
        expect(count, 1);
      });
    });

    test('runs again for a call after the previous run', () {
      fakeAsync((async) {
        var count = 0;
        final debouncer = VDebouncer(const Duration(milliseconds: 10), () {
          count++;
        });

        debouncer();
        async.elapse(const Duration(milliseconds: 10));
        debouncer();
        async.elapse(const Duration(milliseconds: 10));
        expect(count, 2);
      });
    });

    test('cancel drops the scheduled run', () {
      fakeAsync((async) {
        var count = 0;
        final debouncer = VDebouncer(const Duration(milliseconds: 50), () {
          count++;
        });

        debouncer();
        expect(debouncer.isPending, isTrue);
        debouncer.cancel();
        expect(debouncer.isPending, isFalse);

        async.elapse(const Duration(seconds: 1));
        expect(count, 0);
      });
    });

    test('can be called again after cancel', () {
      fakeAsync((async) {
        var count = 0;
        final debouncer = VDebouncer(const Duration(milliseconds: 50), () {
          count++;
        });

        debouncer();
        debouncer.cancel();
        debouncer();
        async.elapse(const Duration(milliseconds: 50));
        expect(count, 1);
        expect(debouncer.isPending, isFalse);
      });
    });

    test('cancel without a pending run is harmless', () {
      expect(VDebouncer(Duration.zero, () {}).cancel, returnsNormally);
    });
  });

  group('VThrottler', () {
    test('first call runs now, calls inside the window are dropped', () {
      fakeAsync((async) {
        var count = 0;
        final throttler = VThrottler(const Duration(milliseconds: 100), () {
          count++;
        });

        throttler();
        expect(count, 1);
        throttler();
        async.elapse(const Duration(milliseconds: 99));
        throttler();
        expect(count, 1);

        async.elapse(const Duration(milliseconds: 1));
        throttler();
        expect(count, 2);
      });
    });

    test('dropped calls are not queued', () {
      fakeAsync((async) {
        var count = 0;
        final throttler = VThrottler(const Duration(milliseconds: 100), () {
          count++;
        });

        throttler();
        throttler();
        async.elapse(const Duration(seconds: 1));
        expect(count, 1);
      });
    });

    test('remainingTime counts down and ends at zero', () {
      fakeAsync((async) {
        final throttler = VThrottler(const Duration(milliseconds: 100), () {});

        expect(throttler.remainingTime, isNull);
        throttler();
        expect(throttler.remainingTime, const Duration(milliseconds: 100));
        async.elapse(const Duration(milliseconds: 40));
        expect(throttler.remainingTime, const Duration(milliseconds: 60));
        async.elapse(const Duration(milliseconds: 60));
        expect(throttler.remainingTime, Duration.zero);
      });
    });

    test('a clock that moves back does not block calls', () {
      var count = 0;
      final throttler = VThrottler(const Duration(seconds: 10), () => count++);

      withClock(Clock.fixed(DateTime(2024, 1, 1, 12)), throttler.call);
      expect(count, 1);

      withClock(Clock.fixed(DateTime(2024, 1, 1, 11)), () {
        expect(throttler.remainingTime, Duration.zero);
        throttler();
      });
      expect(count, 2);

      // The window now starts at the new time
      withClock(Clock.fixed(DateTime(2024, 1, 1, 11, 0, 5)), () {
        expect(throttler.remainingTime, const Duration(seconds: 5));
        throttler();
      });
      expect(count, 2);
    });

    test('reset lets the next call run immediately', () {
      var count = 0;
      final throttler = VThrottler(const Duration(hours: 1), () => count++);

      throttler();
      throttler.reset();
      expect(throttler.remainingTime, isNull);
      throttler();
      expect(count, 2);
    });
  });
}
