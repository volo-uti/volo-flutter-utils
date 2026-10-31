# int_extensions

Import: `package:volo_flutter_utils/volo_flutter_utils.dart`

## VIntExtension

Range, padding, duration and Unix-time helpers for [int].

```dart
5.isBetween(1, 10);  // true
5.padLeft(2);        // '05'
90.seconds;          // Duration(seconds: 90)
0.toDateTime();      // 1970-01-01 in local time
```

### Members

| Member | Description |
|---|---|
| `Duration get milliseconds` | This many milliseconds as a [Duration]. |
| `Duration get seconds` | This many seconds as a [Duration]. |
| `Duration get minutes` | This many minutes as a [Duration]. |
| `Duration get hours` | This many hours as a [Duration]. |
| `Duration get days` | This many 24-hour days as a [Duration].<br>A [Duration] has no calendar, so adding it to a local [DateTime] across a daylight-saving change moves the clock time by an hour. |
| `bool isBetween(int min, int max)` | Whether this value lies in `[min, max]`, both ends included. |
| `int clampTo(int min, int max)` | Returns this value limited to `[min, max]` as an [int].<br>Unlike `num.clamp` the result type is [int]. `min` greater than `max` throws, as `num.clamp` does. |
| `String padLeft(int width)` | Pads the decimal form with leading zeros up to [width] characters.<br>A negative number keeps its minus sign in front of the zeros and counts it toward [width]. |
| `DateTime toDateTime()` | Interprets this as a Unix timestamp in seconds and returns local time. |
| `DateTime toDateTimeMs()` | Interprets this as a Unix timestamp in milliseconds and returns local time. |
