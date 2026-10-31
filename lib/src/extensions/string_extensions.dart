import 'package:flutter/material.dart' show TimeOfDay;

import '../validators/v_validator.dart';

/// Format checks and small conversions for [String].
///
/// The `isValid…` getters are pragmatic shape checks, not proof that an email
/// exists or a phone number is reachable. [isValidEmail], [isValidUrl] and
/// [isValidPhone] give the same verdict as `VValidator.email`, `.url` and
/// `.phone`, and the phone check accepts Korean mobile numbers only.
///
/// ```dart
/// 'test@example.com'.isValidEmail; // true
/// 'Abcd1234'.isStrongPassword;     // true
/// 'hello'.capitalize;              // 'Hello'
/// '14:30'.toTimeOfDay();           // TimeOfDay(hour: 14, minute: 30)
/// ```
extension VStringExtension on String {
  // ============================================================
  // Validation
  // ============================================================

  /// Validates a basic `user@domain.tld` email shape.
  ///
  /// Covers common addresses but is not RFC 5322 compliant, and does not trim.
  ///
  /// ```dart
  /// 'user@example.com'.isValidEmail; // true
  /// 'invalid-email'.isValidEmail; // false
  /// ```
  bool get isValidEmail => VValidator.email(this) == VValidationResult.valid;

  /// Validates an http or https URL whose host contains a dot.
  ///
  /// A missing scheme is accepted (`example.com`); other schemes such as
  /// `mailto:` are not. See `VValidator.url` for the host rules.
  ///
  /// ```dart
  /// 'https://example.com'.isValidUrl; // true
  /// 'not-a-url'.isValidUrl; // false
  /// ```
  bool get isValidUrl => VValidator.url(this) == VValidationResult.valid;

  /// Whether this has 8+ characters with an uppercase, a lowercase and a digit.
  ///
  /// Any character counts toward the length, line breaks included.
  ///
  /// ```dart
  /// 'Abcd1234'.isStrongPassword; // true
  /// 'weakpass'.isStrongPassword; // false
  /// ```
  bool get isStrongPassword => RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
    dotAll: true,
  ).hasMatch(this);

  /// Whether this is 6 to 12 ASCII letters or digits and nothing else.
  ///
  /// ```dart
  /// 'pass123'.isValidPassword; // true
  /// 'ab'.isValidPassword; // false (too short)
  /// ```
  bool get isValidPassword => RegExp(r'^[A-Za-z0-9]{6,12}$').hasMatch(this);

  /// Whether this is a dotted IPv4 address with each part 0 to 255.
  ///
  /// Parts have no leading zeros, so `192.168.0.01` is rejected.
  ///
  /// ```dart
  /// '192.168.0.1'.isValidIpAddress; // true
  /// '999.999.999.999'.isValidIpAddress; // false
  /// ```
  bool get isValidIpAddress => RegExp(
    r'^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$',
  ).hasMatch(this);

  /// Whether this is a Korean mobile number (`010-1234-5678`, `01012345678`).
  ///
  /// Spaces and hyphens are ignored and a leading `+82` or `82` replaces the
  /// `0`; other countries' numbers are rejected.
  ///
  /// ```dart
  /// '010-1234-5678'.isValidPhone; // true
  /// '01012345678'.isValidPhone; // true
  /// '+82 10-1234-5678'.isValidPhone; // true
  /// ```
  bool get isValidPhone => VValidator.phone(this) == VValidationResult.valid;

  // ============================================================
  // Conversion
  // ============================================================

  /// Parses `H:mm` or `HH:mm` (24-hour) into a [TimeOfDay].
  ///
  /// Returns null for anything else, including out-of-range parts and signs.
  ///
  /// ```dart
  /// '14:30'.toTimeOfDay(); // TimeOfDay(14, 30)
  /// 'invalid'.toTimeOfDay(); // null
  /// ```
  TimeOfDay? toTimeOfDay() {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(this);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Returns this with its first character uppercased.
  ///
  /// Uses Dart's locale-independent `toUpperCase`, so `i` becomes `I` even in
  /// Turkish.
  ///
  /// ```dart
  /// 'hello'.capitalize; // 'Hello'
  /// 'HELLO'.capitalize; // 'HELLO'
  /// ''.capitalize; // ''
  /// ```
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Whether this is empty or only whitespace.
  ///
  /// ```dart
  /// ''.isBlank; // true
  /// '   '.isBlank; // true
  /// 'hello'.isBlank; // false
  /// ```
  bool get isBlank => trim().isEmpty;

  /// Whether this has at least one non-whitespace character.
  ///
  /// ```dart
  /// 'hello'.isNotBlank; // true
  /// '   '.isNotBlank; // false
  /// ```
  bool get isNotBlank => !isBlank;

  /// Whether this is one or more digits `0-9` and nothing else.
  ///
  /// ```dart
  /// '12345'.isNumeric; // true
  /// '12.34'.isNumeric; // false
  /// ```
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);

  /// Whether this is one or more ASCII letters (`a-z`, `A-Z`) and nothing else.
  ///
  /// ```dart
  /// 'Hello'.isAlpha; // true
  /// 'Hello123'.isAlpha; // false
  /// ```
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// Whether this is one or more ASCII letters or digits and nothing else.
  ///
  /// ```dart
  /// 'Hello123'.isAlphanumeric; // true
  /// 'Hello 123'.isAlphanumeric; // false
  /// ```
  bool get isAlphanumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
}
