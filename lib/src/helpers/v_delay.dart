import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

/// Runs [callback] once calls have stopped for [duration].
///
/// Each [call] restarts the wait, so a burst of calls (typing in a search
/// box) runs [callback] once, [duration] after the last one. Call [cancel]
/// in `dispose` so no callback fires after the owner is gone.
///
/// ```dart
/// final debouncer = VDebouncer(const Duration(milliseconds: 300), search);
/// debouncer(); // schedules search
/// debouncer(); // restarts the wait
/// debouncer.cancel();
/// ```
class VDebouncer {
  /// Creates a debouncer that runs [callback] after [duration] of quiet.
  VDebouncer(this.duration, this.callback);

  /// How long calls must stop before [callback] runs.
  final Duration duration;

  /// The function to run.
  final VoidCallback callback;

  Timer? _timer;

  /// Whether a run is scheduled and has not fired or been cancelled yet.
  bool get isPending => _timer?.isActive ?? false;

  /// Restarts the wait; [callback] runs after [duration] unless called again.
  void call() {
    _timer?.cancel();
    _timer = Timer(duration, () {
      _timer = null;
      callback();
    });
  }

  /// Drops the scheduled run, if any.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Runs [callback] at most once per [duration].
///
/// The first [call] runs immediately; calls inside the window are dropped,
/// not queued. The window is measured with `clock.now()` from package:clock,
/// which equals `DateTime.now()` unless a test overrides it. If the clock
/// moves back after a run, the window counts as passed.
///
/// ```dart
/// final throttler = VThrottler(const Duration(milliseconds: 100), save);
/// throttler(); // runs now
/// throttler(); // ignored until 100 ms have passed
/// ```
class VThrottler {
  /// Creates a throttler that allows [callback] once per [duration].
  VThrottler(this.duration, this.callback);

  /// Length of the window after each run.
  final Duration duration;

  /// The function to run.
  final VoidCallback callback;

  DateTime? _lastExecutionTime;

  /// Runs [callback] if the window since the last run has passed.
  void call() {
    final now = clock.now();

    if (_lastExecutionTime == null ||
        now.isBefore(_lastExecutionTime!) ||
        now.difference(_lastExecutionTime!) >= duration) {
      _lastExecutionTime = now;
      callback();
    }
  }

  /// Time left until the next call may run, or null before the first run.
  ///
  /// Returns [Duration.zero] once the window has passed, or when the clock
  /// has moved back since the last run.
  Duration? get remainingTime {
    if (_lastExecutionTime == null) return null;
    final elapsed = clock.now().difference(_lastExecutionTime!);
    if (elapsed.isNegative || elapsed >= duration) return Duration.zero;
    return duration - elapsed;
  }

  /// Forgets the last run so the next [call] runs immediately.
  void reset() {
    _lastExecutionTime = null;
  }
}
