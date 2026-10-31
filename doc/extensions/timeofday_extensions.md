# timeofday_extensions

Import: `package:volo_flutter_utils/volo_flutter_utils.dart`

## VTimeOfDayExtension

Comparison and midnight-wrapping arithmetic for [TimeOfDay].

```dart
const t = TimeOfDay(hour: 23, minute: 30);
t.add(const Duration(hours: 2)); // 01:30 the next day, as a TimeOfDay
t.toMinutes();                   // 1410
t.toDateTime(date: DateTime(2024, 1, 1)); // 2024-01-01 23:30
```

### Members

| Member | Description |
|---|---|
| `DateTime toDateTime({DateTime? date})` | Combines this time with [date] (default: today) into a local [DateTime].<br>Seconds and smaller units are zero. Today comes from `clock.now()`, so tests can override it with `withClock`. A time skipped by a daylight-saving change moves forward, as `DateTime` does: 02:30 on a spring-forward day gives 03:30. |
| `bool isBefore(TimeOfDay other)` | Whether this time is earlier in the day than [other]. |
| `bool isAfter(TimeOfDay other)` | Whether this time is later in the day than [other]. |
| `int toMinutes()` | Minutes since midnight, from 0 to 1439. |
| `TimeOfDay add(Duration duration)` | Returns this time moved forward by [duration], wrapping past midnight.<br>Only whole minutes count; seconds of [duration] are dropped. |
| `TimeOfDay subtract(Duration duration)` | Returns this time moved back by [duration], wrapping before midnight.<br>Only whole minutes count; seconds of [duration] are dropped. |
| `int difference(TimeOfDay other)` | Minutes from [other] to this time, negative when this is earlier.<br>Does not wrap: 00:10 minus 23:50 is -1420. |
