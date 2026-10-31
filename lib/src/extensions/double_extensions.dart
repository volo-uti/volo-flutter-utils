/// Layout and range helpers for [double].
///
/// ```dart
/// 24.0.toFigmaHeight(16); // 1.5
/// 5.0.isBetween(1, 10);   // true
/// 15.0.clampTo(0, 10);    // 10.0
/// ```
extension VDoubleExtension on double {
  /// Converts a Figma line height in px to a Flutter `TextStyle.height`.
  ///
  /// Returns this divided by [fontSize], so [fontSize] must not be zero.
  ///
  /// ```dart
  /// 24.0.toFigmaHeight(16.0); // 1.5
  /// ```
  double toFigmaHeight(double fontSize) => this / fontSize;

  /// Whether this value lies in `[min, max]`, both ends included.
  ///
  /// NaN is never between two values.
  ///
  /// ```dart
  /// 5.0.isBetween(1, 10); // true
  /// 0.0.isBetween(1, 10); // false
  /// ```
  bool isBetween(double min, double max) => this >= min && this <= max;

  /// Returns this value limited to `[min, max]` as a [double].
  ///
  /// Unlike `num.clamp` the result type is [double], and NaN stays NaN (the
  /// SDK would turn it into `max`). `min` greater than `max` throws, NaN
  /// included.
  ///
  /// ```dart
  /// 15.0.clampTo(0, 10);   // 10.0
  /// (-5.0).clampTo(0, 10); // 0.0
  /// ```
  double clampTo(double min, double max) {
    // Clamp first so that bad bounds throw even when this is NaN
    final clamped = clamp(min, max).toDouble();
    return isNaN ? this : clamped;
  }
}
