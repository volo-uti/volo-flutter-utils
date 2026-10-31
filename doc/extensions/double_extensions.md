# double_extensions

Import: `package:volo_flutter_utils/volo_flutter_utils.dart`

## VDoubleExtension

Layout and range helpers for [double].

```dart
24.0.toFigmaHeight(16); // 1.5
5.0.isBetween(1, 10);   // true
15.0.clampTo(0, 10);    // 10.0
```

### Members

| Member | Description |
|---|---|
| `double toFigmaHeight(double fontSize)` | Converts a Figma line height in px to a Flutter `TextStyle.height`.<br>Returns this divided by [fontSize], so [fontSize] must not be zero. |
| `bool isBetween(double min, double max)` | Whether this value lies in `[min, max]`, both ends included.<br>NaN is never between two values. |
| `double clampTo(double min, double max)` | Returns this value limited to `[min, max]` as a [double].<br>Unlike `num.clamp` the result type is [double], and NaN stays NaN (the SDK would turn it into `max`). `min` greater than `max` throws, NaN included. |
