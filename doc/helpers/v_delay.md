# v_delay

Import: `package:volo_flutter_utils/volo_flutter_utils.dart`

## VDebouncer

Runs [callback] once calls have stopped for [duration].

Each [call] restarts the wait, so a burst of calls (typing in a search
box) runs [callback] once, [duration] after the last one. Call [cancel]
in `dispose` so no callback fires after the owner is gone.

```dart
final debouncer = VDebouncer(const Duration(milliseconds: 300), search);
debouncer(); // schedules search
debouncer(); // restarts the wait
debouncer.cancel();
```

### Constructors

#### `VDebouncer`

Creates a debouncer that runs [callback] after [duration] of quiet.

| Parameter | Type | Default | Required | Description |
|---|---|---|---|---|
| `duration` | `Duration` |  | yes | How long calls must stop before [callback] runs. |
| `callback` | `void Function()` |  | yes | The function to run. |

### Members

| Member | Description |
|---|---|
| `bool get isPending` | Whether a run is scheduled and has not fired or been cancelled yet. |
| `void call()` | Restarts the wait; [callback] runs after [duration] unless called again. |
| `void cancel()` | Drops the scheduled run, if any. |

## VThrottler

Runs [callback] at most once per [duration].

The first [call] runs immediately; calls inside the window are dropped,
not queued. The window is measured with `clock.now()` from package:clock,
which equals `DateTime.now()` unless a test overrides it. If the clock
moves back after a run, the window counts as passed.

```dart
final throttler = VThrottler(const Duration(milliseconds: 100), save);
throttler(); // runs now
throttler(); // ignored until 100 ms have passed
```

### Constructors

#### `VThrottler`

Creates a throttler that allows [callback] once per [duration].

| Parameter | Type | Default | Required | Description |
|---|---|---|---|---|
| `duration` | `Duration` |  | yes | Length of the window after each run. |
| `callback` | `void Function()` |  | yes | The function to run. |

### Members

| Member | Description |
|---|---|
| `Duration? get remainingTime` | Time left until the next call may run, or null before the first run.<br>Returns [Duration.zero] once the window has passed, or when the clock has moved back since the last run. |
| `void call()` | Runs [callback] if the window since the last run has passed. |
| `void reset()` | Forgets the last run so the next [call] runs immediately. |
