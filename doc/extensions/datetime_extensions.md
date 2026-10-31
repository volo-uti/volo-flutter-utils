# datetime_extensions

Import: `package:volo_flutter_utils/volo_flutter_utils.dart`

## VDateTimeExtension

Calendar comparisons and day, month boundaries for [DateTime].

Every "is today / this week" check compares the calendar fields of the
receiver with the device's local `clock.now()`, so call them on local
values. Date math builds new values from calendar fields, never by adding a
24-hour [Duration], so daylight-saving shifts cannot skip or repeat a day.

```dart
final d = DateTime(2024, 2, 10, 15, 30);
d.startOfDay;   // 2024-02-10 00:00:00
d.daysInMonth;  // 29
d.isWeekend;    // true (Saturday)
```

### Members

| Member | Description |
|---|---|
| `bool get isToday` | Checks whether this date is today. |
| `bool get isTomorrow` | Checks whether this date is tomorrow. |
| `bool get isYesterday` | Checks whether this date is yesterday. |
| `bool get isThisWeek` | Checks whether this date is within the current week (Monday to Sunday). |
| `bool get isThisMonth` | Checks whether this date is within the current month. |
| `bool get isThisYear` | Checks whether this date is within the current year. |
| `bool get isWeekend` | Checks whether this date is a weekend. |
| `bool get isWeekday` | Checks whether this date is a weekday. |
| `DateTime get startOfDay` | Returns the start of the day (00:00:00).<br>In a zone whose daylight-saving change skips midnight (such as Santiago), that day starts at 01:00, the first moment that exists. |
| `DateTime get endOfDay` | Returns the last millisecond of the day (23:59:59.999). |
| `DateTime get startOfMonth` | Returns the start of the month. |
| `DateTime get endOfMonth` | Returns the end of the month. |
| `int get daysInMonth` | Returns the number of days in the month. |
| `bool isSameDay(DateTime other)` | Compares whether two dates are the same day (ignoring time). |
| `DateTime copyWith({int? year, int? month, int? day, int? hour, int? minute, int? second, int? millisecond, int? microsecond})` | Copies the date with modified fields, keeping the local or UTC kind. |
