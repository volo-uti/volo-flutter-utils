# v_validator

Import: `package:volo_flutter_utils/volo_flutter_utils.dart`

## VValidationResult

Why a value failed validation, or [valid] when it passed.

A result names the category only. Turn it into text with
[VValidator.errorMessage] or into a translation key with
[VValidator.errorKey].

### Values

| Value | Description |
|---|---|
| `valid` | The value passed every check. |
| `empty` | The value is null, empty or only whitespace. |
| `format` | The value does not have the expected shape (pattern, characters). |
| `length` | The value is shorter or longer than allowed. |
| `invalid` | The value is well formed but not acceptable, such as a mismatch. |
| `duplicate` | The value already exists. No built-in validator returns this; it is for results the app computes itself, such as a taken username. |

## VValidator

Synchronous input checks that return a [VValidationResult].

Every check treats null and empty input as [VValidationResult.empty], so
optional fields should test for emptiness before calling. The checks are
pragmatic: [email] and [url] reject obvious mistakes, not every invalid
address, and [phone] accepts Korean mobile numbers only. Lengths count
UTF-16 code units.

Messages: [errorMessage] returns English text only. For any other
language use [errorKey] and translate in the app.

```dart
final result = VValidator.password('abc');
if (result != VValidationResult.valid) {
  VValidator.errorKey(result, 'password');     // 'error.password.length'
  VValidator.errorMessage(result, 'password'); // 'Invalid password length'
}
```

### Members

| Member | Description |
|---|---|
| `static VValidationResult email(String? value)` | Checks a basic `user@domain.tld` email shape.<br>Returns [VValidationResult.empty] or [VValidationResult.format]. The value is not trimmed before the pattern test, so surrounding spaces fail. Dots may not lead, trail or repeat in the local part, and every domain label must start and end with a letter or digit; the final label is at least two ASCII letters. |
| `static VValidationResult password(String? value, {int minLength = 8, bool requireDigit = true, bool requireLetter = true})` | Checks a password's length and character mix.<br>Returns [VValidationResult.length] below [minLength] and [VValidationResult.format] when a required digit or ASCII letter is missing. [requireDigit] and [requireLetter] default to true. |
| `static VValidationResult confirmPassword(String? value, String? original)` | Checks that [value] equals the [original] password.<br>Returns [VValidationResult.empty] for an empty [value] and [VValidationResult.invalid] on a mismatch. |
| `static VValidationResult phone(String? value)` | Checks a Korean mobile number (`010`, `011`, `016` to `019` prefixes).<br>Spaces and hyphens are ignored, and a leading `+82` or `82` country code stands in for the `0` (`+82 10-1234-5678`). A `010` number has 8 digits after the prefix; 011 and 016 to 019 have 7 or 8. Numbers from other countries return [VValidationResult.format]. |
| `static VValidationResult url(String? value)` | Checks a web URL whose host is a dotted domain name or an IPv4 address.<br>A value without a scheme is tested as if `https://` were prepended, so `example.com` passes; the scheme `http` or `https` is matched in any letter case, and any other scheme (`ftp://`, `mailto:`) fails. Without a scheme, user info (`name@host`) is not accepted. The host needs well-formed labels and a final label of two or more characters that is not all digits, and a port must be 0 to 65535. |
| `static VValidationResult required(Object? value)` | Checks that [value] is present.<br>Null, blank strings, and empty iterables (lists, sets) and maps return [VValidationResult.empty]; any other object is valid. |
| `static VValidationResult minLength(String? value, int minLength)` | Checks that [value] has at least [minLength] characters. |
| `static VValidationResult maxLength(String? value, int maxLength)` | Checks that [value] has at most [maxLength] characters. |
| `static VValidationResult numeric(String? value)` | Checks that [value] is made of ASCII digits only. |
| `static VValidationResult pattern(String? value, RegExp regex)` | Checks that [regex] matches somewhere in [value].<br>Anchor the pattern with `^` and `$` to test the whole value. |
| `static String? errorKey(VValidationResult result, String fieldName)` | Returns the translation key `error.<fieldName>.<result>`, or null if valid. |
| `static String? errorMessage(VValidationResult result, String fieldName)` | Returns a ready-made English message for [result], or null if it is valid.<br>[fieldName] is inserted as given. For other languages, translate in the app using [errorKey]. |
