/// Why a value failed validation, or [valid] when it passed.
///
/// A result names the category only. Turn it into text with
/// [VValidator.errorMessage] or into a translation key with
/// [VValidator.errorKey].
enum VValidationResult {
  /// The value passed every check.
  valid,

  /// The value is null, empty or only whitespace.
  empty,

  /// The value does not have the expected shape (pattern, characters).
  format,

  /// The value is shorter or longer than allowed.
  length,

  /// The value is well formed but not acceptable, such as a mismatch.
  invalid,

  /// The value already exists. No built-in validator returns this; it is for
  /// results the app computes itself, such as a taken username.
  duplicate,
}

/// Synchronous input checks that return a [VValidationResult].
///
/// Every check treats null and empty input as [VValidationResult.empty], so
/// optional fields should test for emptiness before calling. The checks are
/// pragmatic: [email] and [url] reject obvious mistakes, not every invalid
/// address, and [phone] accepts Korean mobile numbers only. Lengths count
/// UTF-16 code units.
///
/// Messages: [errorMessage] returns English text only. For any other
/// language use [errorKey] and translate in the app.
///
/// ```dart
/// final result = VValidator.password('abc');
/// if (result != VValidationResult.valid) {
///   VValidator.errorKey(result, 'password');     // 'error.password.length'
///   VValidator.errorMessage(result, 'password'); // 'Invalid password length'
/// }
/// ```
class VValidator {
  VValidator._();

  static final _emailRegex = RegExp(
    r'^[A-Za-z0-9_%+-]+(\.[A-Za-z0-9_%+-]+)*'
    r'@([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z]{2,}$',
  );

  // Korean mobile numbers: 010 takes 8 more digits, 011 and 016 to 019 take
  // 7 or 8.
  static final _phoneRegex = RegExp(r'^(010[0-9]{8}|01[16789][0-9]{7,8})$');

  static final _urlSchemeRegex = RegExp('^[a-zA-Z][a-zA-Z0-9+.-]*://');

  static final _hostLabelRegex = RegExp(
    r'^[a-z0-9\u00a1-\uffff]([a-z0-9\u00a1-\uffff-]*[a-z0-9\u00a1-\uffff])?$',
  );

  static final _ipv4Regex = RegExp(r'^[0-9]{1,3}(\.[0-9]{1,3}){3}$');

  /// Checks a basic `user@domain.tld` email shape.
  ///
  /// Returns [VValidationResult.empty] or [VValidationResult.format]. The
  /// value is not trimmed before the pattern test, so surrounding spaces fail.
  /// Dots may not lead, trail or repeat in the local part, and every domain
  /// label must start and end with a letter or digit; the final label is at
  /// least two ASCII letters.
  static VValidationResult email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return VValidationResult.empty;
    }

    if (!_emailRegex.hasMatch(value)) {
      return VValidationResult.format;
    }

    return VValidationResult.valid;
  }

  /// Checks a password's length and character mix.
  ///
  /// Returns [VValidationResult.length] below [minLength] and
  /// [VValidationResult.format] when a required digit or ASCII letter is
  /// missing. [requireDigit] and [requireLetter] default to true.
  static VValidationResult password(
    String? value, {
    int minLength = 8,
    bool requireDigit = true,
    bool requireLetter = true,
  }) {
    if (value == null || value.isEmpty) {
      return VValidationResult.empty;
    }

    if (value.length < minLength) {
      return VValidationResult.length;
    }

    if (requireDigit && !RegExp('[0-9]').hasMatch(value)) {
      return VValidationResult.format;
    }

    if (requireLetter && !RegExp('[a-zA-Z]').hasMatch(value)) {
      return VValidationResult.format;
    }

    return VValidationResult.valid;
  }

  /// Checks that [value] equals the [original] password.
  ///
  /// Returns [VValidationResult.empty] for an empty [value] and
  /// [VValidationResult.invalid] on a mismatch.
  static VValidationResult confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) {
      return VValidationResult.empty;
    }

    if (value != original) {
      return VValidationResult.invalid;
    }

    return VValidationResult.valid;
  }

  /// Checks a Korean mobile number (`010`, `011`, `016` to `019` prefixes).
  ///
  /// Spaces and hyphens are ignored, and a leading `+82` or `82` country code
  /// stands in for the `0` (`+82 10-1234-5678`). A `010` number has 8 digits
  /// after the prefix; 011 and 016 to 019 have 7 or 8. Numbers from other
  /// countries return [VValidationResult.format].
  static VValidationResult phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return VValidationResult.empty;
    }

    // Only spaces and hyphens are separators
    var cleaned = value.replaceAll(RegExp('[ -]'), '');

    // +82 10... and 82 10... are 010... with the country code
    if (cleaned.startsWith('+82')) {
      cleaned = '0${cleaned.substring(3)}';
    } else if (cleaned.startsWith('82')) {
      cleaned = '0${cleaned.substring(2)}';
    }

    if (!_phoneRegex.hasMatch(cleaned)) {
      return VValidationResult.format;
    }

    return VValidationResult.valid;
  }

  /// Checks a web URL whose host is a dotted domain name or an IPv4 address.
  ///
  /// A value without a scheme is tested as if `https://` were prepended, so
  /// `example.com` passes; the scheme `http` or `https` is matched in any
  /// letter case, and any other scheme (`ftp://`, `mailto:`) fails. Without a
  /// scheme, user info (`name@host`) is not accepted. The host needs
  /// well-formed labels and a final label of two or more characters that is
  /// not all digits, and a port must be 0 to 65535.
  static VValidationResult url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return VValidationResult.empty;
    }

    // Uri.tryParse accepts spaces inside the host, so reject whitespace here
    if (value.contains(RegExp(r'\s'))) {
      return VValidationResult.format;
    }

    // Prepend https:// if the scheme is missing
    var urlToCheck = value;
    final scheme = _urlSchemeRegex.firstMatch(value);
    if (scheme == null) {
      // `scheme:user@host` would parse as user info of an https URL
      final authorityEnd = value.indexOf(RegExp('[/?#]'));
      final authority = authorityEnd < 0
          ? value
          : value.substring(0, authorityEnd);
      if (authority.contains('@')) {
        return VValidationResult.format;
      }
      urlToCheck = 'https://$value';
    }

    final uri = Uri.tryParse(urlToCheck);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return VValidationResult.format;
    }

    final uriScheme = uri.scheme.toLowerCase();
    if (uriScheme != 'http' && uriScheme != 'https') {
      return VValidationResult.format;
    }

    if (!_isDottedHost(uri.host) || uri.port < 0 || uri.port > 65535) {
      return VValidationResult.format;
    }

    return VValidationResult.valid;
  }

  static bool _isDottedHost(String host) {
    if (_ipv4Regex.hasMatch(host)) {
      return host.split('.').every((part) => int.parse(part) <= 255);
    }

    final labels = host.split('.');
    if (labels.length < 2 || !labels.every(_hostLabelRegex.hasMatch)) {
      return false;
    }

    // The top-level label is at least two characters and not all digits
    final tld = labels.last;
    return tld.length >= 2 && !RegExp(r'^[0-9]+$').hasMatch(tld);
  }

  /// Checks that [value] is present.
  ///
  /// Null, blank strings, and empty iterables (lists, sets) and maps return
  /// [VValidationResult.empty]; any other object is valid.
  static VValidationResult required(Object? value) {
    if (value == null) {
      return VValidationResult.empty;
    }

    if (value is String && value.trim().isEmpty) {
      return VValidationResult.empty;
    }

    if (value is Iterable && value.isEmpty) {
      return VValidationResult.empty;
    }

    if (value is Map && value.isEmpty) {
      return VValidationResult.empty;
    }

    return VValidationResult.valid;
  }

  /// Checks that [value] has at least [minLength] characters.
  static VValidationResult minLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return VValidationResult.empty;
    }

    if (value.length < minLength) {
      return VValidationResult.length;
    }

    return VValidationResult.valid;
  }

  /// Checks that [value] has at most [maxLength] characters.
  static VValidationResult maxLength(String? value, int maxLength) {
    if (value == null || value.isEmpty) {
      return VValidationResult.empty;
    }

    if (value.length > maxLength) {
      return VValidationResult.length;
    }

    return VValidationResult.valid;
  }

  /// Checks that [value] is made of ASCII digits only.
  static VValidationResult numeric(String? value) {
    if (value == null || value.isEmpty) {
      return VValidationResult.empty;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return VValidationResult.format;
    }

    return VValidationResult.valid;
  }

  /// Checks that [regex] matches somewhere in [value].
  ///
  /// Anchor the pattern with `^` and `$` to test the whole value.
  static VValidationResult pattern(String? value, RegExp regex) {
    if (value == null || value.isEmpty) {
      return VValidationResult.empty;
    }

    if (!regex.hasMatch(value)) {
      return VValidationResult.format;
    }

    return VValidationResult.valid;
  }

  /// Returns the translation key `error.<fieldName>.<result>`, or null if valid.
  ///
  /// ```dart
  /// VValidator.errorKey(VValidationResult.empty, 'email'); // 'error.email.empty'
  /// ```
  static String? errorKey(VValidationResult result, String fieldName) {
    if (result == VValidationResult.valid) {
      return null;
    }

    return 'error.$fieldName.${result.name}';
  }

  /// Returns a ready-made English message for [result], or null if it is valid.
  ///
  /// [fieldName] is inserted as given. For other languages, translate in the
  /// app using [errorKey].
  ///
  /// ```dart
  /// VValidator.errorMessage(VValidationResult.empty, 'email');
  /// // 'Please enter email'
  /// VValidator.errorMessage(VValidationResult.format, 'email');
  /// // 'Invalid email format'
  /// ```
  static String? errorMessage(VValidationResult result, String fieldName) {
    switch (result) {
      case VValidationResult.valid:
        return null;
      case VValidationResult.empty:
        return 'Please enter $fieldName';
      case VValidationResult.format:
        return 'Invalid $fieldName format';
      case VValidationResult.length:
        return 'Invalid $fieldName length';
      case VValidationResult.invalid:
        return '$fieldName is invalid';
      case VValidationResult.duplicate:
        return '$fieldName already exists';
    }
  }
}
