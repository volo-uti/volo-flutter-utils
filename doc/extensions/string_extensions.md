# string_extensions

Import: `package:volo_flutter_utils/volo_flutter_utils.dart`

## VStringExtension

Format checks and small conversions for [String].

The `isValid…` getters are pragmatic shape checks, not proof that an email
exists or a phone number is reachable. [isValidEmail], [isValidUrl] and
[isValidPhone] give the same verdict as `VValidator.email`, `.url` and
`.phone`, and the phone check accepts Korean mobile numbers only.

```dart
'test@example.com'.isValidEmail; // true
'Abcd1234'.isStrongPassword;     // true
'hello'.capitalize;              // 'Hello'
'14:30'.toTimeOfDay();           // TimeOfDay(hour: 14, minute: 30)
```

### Members

| Member | Description |
|---|---|
| `bool get isValidEmail` | Validates a basic `user@domain.tld` email shape.<br>Covers common addresses but is not RFC 5322 compliant, and does not trim. |
| `bool get isValidUrl` | Validates an http or https URL whose host contains a dot.<br>A missing scheme is accepted (`example.com`); other schemes such as `mailto:` are not. See `VValidator.url` for the host rules. |
| `bool get isStrongPassword` | Whether this has 8+ characters with an uppercase, a lowercase and a digit.<br>Any character counts toward the length, line breaks included. |
| `bool get isValidPassword` | Whether this is 6 to 12 ASCII letters or digits and nothing else. |
| `bool get isValidIpAddress` | Whether this is a dotted IPv4 address with each part 0 to 255.<br>Parts have no leading zeros, so `192.168.0.01` is rejected. |
| `bool get isValidPhone` | Whether this is a Korean mobile number (`010-1234-5678`, `01012345678`).<br>Spaces and hyphens are ignored and a leading `+82` or `82` replaces the `0`; other countries' numbers are rejected. |
| `String get capitalize` | Returns this with its first character uppercased.<br>Uses Dart's locale-independent `toUpperCase`, so `i` becomes `I` even in Turkish. |
| `bool get isBlank` | Whether this is empty or only whitespace. |
| `bool get isNotBlank` | Whether this has at least one non-whitespace character. |
| `bool get isNumeric` | Whether this is one or more digits `0-9` and nothing else. |
| `bool get isAlpha` | Whether this is one or more ASCII letters (`a-z`, `A-Z`) and nothing else. |
| `bool get isAlphanumeric` | Whether this is one or more ASCII letters or digits and nothing else. |
| `TimeOfDay? toTimeOfDay()` | Parses `H:mm` or `HH:mm` (24-hour) into a [TimeOfDay].<br>Returns null for anything else, including out-of-range parts and signs. |
