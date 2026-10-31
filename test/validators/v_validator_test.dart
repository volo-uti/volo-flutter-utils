import 'package:flutter_test/flutter_test.dart';
import 'package:volo_flutter_utils/volo_flutter_utils.dart';

void main() {
  group('VValidator', () {
    group('email', () {
      test('valid email', () {
        expect(VValidator.email('test@example.com'), VValidationResult.valid);
        expect(
          VValidator.email('user.name@domain.co.kr'),
          VValidationResult.valid,
        );
        expect(
          VValidator.email('user+tag@example.org'),
          VValidationResult.valid,
        );
      });

      test('empty email', () {
        expect(VValidator.email(null), VValidationResult.empty);
        expect(VValidator.email(''), VValidationResult.empty);
        expect(VValidator.email('   '), VValidationResult.empty);
      });

      test('invalid format', () {
        expect(VValidator.email('invalid'), VValidationResult.format);
        expect(VValidator.email('test@'), VValidationResult.format);
        expect(VValidator.email('@example.com'), VValidationResult.format);
      });
    });

    group('password', () {
      test('valid password', () {
        expect(VValidator.password('Password1'), VValidationResult.valid);
        expect(VValidator.password('Abcd1234'), VValidationResult.valid);
      });

      test('empty password', () {
        expect(VValidator.password(null), VValidationResult.empty);
        expect(VValidator.password(''), VValidationResult.empty);
      });

      test('short password', () {
        expect(VValidator.password('Pass1'), VValidationResult.length);
      });

      test('password without numbers', () {
        expect(VValidator.password('Password'), VValidationResult.format);
      });

      test('password without letters', () {
        expect(VValidator.password('12345678'), VValidationResult.format);
      });
    });

    group('confirmPassword', () {
      test('matching password', () {
        expect(
          VValidator.confirmPassword('pass123', 'pass123'),
          VValidationResult.valid,
        );
      });

      test('mismatching password', () {
        expect(
          VValidator.confirmPassword('pass123', 'pass456'),
          VValidationResult.invalid,
        );
      });

      test('empty confirm password', () {
        expect(
          VValidator.confirmPassword(null, 'pass123'),
          VValidationResult.empty,
        );
        expect(
          VValidator.confirmPassword('', 'pass123'),
          VValidationResult.empty,
        );
      });
    });

    group('phone', () {
      test('valid phone number', () {
        expect(VValidator.phone('01012345678'), VValidationResult.valid);
        expect(VValidator.phone('010-1234-5678'), VValidationResult.valid);
        expect(VValidator.phone('016-123-4567'), VValidationResult.valid);
      });

      test('empty phone number', () {
        expect(VValidator.phone(null), VValidationResult.empty);
        expect(VValidator.phone(''), VValidationResult.empty);
      });

      test('invalid format', () {
        expect(VValidator.phone('02-123-4567'), VValidationResult.format);
        expect(VValidator.phone('12345'), VValidationResult.format);
      });
    });

    group('url', () {
      test('valid URL', () {
        expect(VValidator.url('https://example.com'), VValidationResult.valid);
        expect(VValidator.url('http://example.com'), VValidationResult.valid);
        expect(VValidator.url('example.com'), VValidationResult.valid);
      });

      test('empty URL', () {
        expect(VValidator.url(null), VValidationResult.empty);
        expect(VValidator.url(''), VValidationResult.empty);
      });

      test('invalid format', () {
        expect(VValidator.url('not-a-url'), VValidationResult.format);
      });
    });

    group('required', () {
      test('valid value', () {
        expect(VValidator.required('value'), VValidationResult.valid);
        expect(VValidator.required(123), VValidationResult.valid);
        expect(VValidator.required([1, 2]), VValidationResult.valid);
        expect(VValidator.required({'key': 'value'}), VValidationResult.valid);
      });

      test('empty value', () {
        expect(VValidator.required(null), VValidationResult.empty);
        expect(VValidator.required(''), VValidationResult.empty);
        expect(VValidator.required('   '), VValidationResult.empty);
        expect(VValidator.required(<int>[]), VValidationResult.empty);
        expect(
          VValidator.required(<String, dynamic>{}),
          VValidationResult.empty,
        );
      });
    });

    group('minLength', () {
      test('sufficient length', () {
        expect(VValidator.minLength('hello', 3), VValidationResult.valid);
        expect(VValidator.minLength('hi', 2), VValidationResult.valid);
      });

      test('too short', () {
        expect(VValidator.minLength('hi', 3), VValidationResult.length);
      });

      test('empty value', () {
        expect(VValidator.minLength(null, 3), VValidationResult.empty);
        expect(VValidator.minLength('', 3), VValidationResult.empty);
      });
    });

    group('maxLength', () {
      test('appropriate length', () {
        expect(VValidator.maxLength('hi', 5), VValidationResult.valid);
        expect(VValidator.maxLength('hello', 5), VValidationResult.valid);
      });

      test('too long', () {
        expect(
          VValidator.maxLength('hello world', 5),
          VValidationResult.length,
        );
      });
    });

    group('numeric', () {
      test('numbers only', () {
        expect(VValidator.numeric('12345'), VValidationResult.valid);
      });

      test('contains letters', () {
        expect(VValidator.numeric('123a'), VValidationResult.format);
        expect(VValidator.numeric('12.34'), VValidationResult.format);
      });
    });

    group('pattern', () {
      test('pattern match', () {
        expect(
          VValidator.pattern('ABC123', RegExp(r'^[A-Z]+[0-9]+$')),
          VValidationResult.valid,
        );
      });

      test('pattern mismatch', () {
        expect(
          VValidator.pattern('abc123', RegExp(r'^[A-Z]+[0-9]+$')),
          VValidationResult.format,
        );
      });
    });

    group('errorKey', () {
      test('error key generation', () {
        expect(
          VValidator.errorKey(VValidationResult.empty, 'email'),
          'error.email.empty',
        );
        expect(
          VValidator.errorKey(VValidationResult.format, 'password'),
          'error.password.format',
        );
        expect(VValidator.errorKey(VValidationResult.valid, 'email'), isNull);
      });
    });

    group('errorMessage', () {
      test('every result has its own English message', () {
        const expected = {
          VValidationResult.empty: 'Please enter email',
          VValidationResult.format: 'Invalid email format',
          VValidationResult.length: 'Invalid email length',
          VValidationResult.invalid: 'email is invalid',
          VValidationResult.duplicate: 'email already exists',
        };
        for (final entry in expected.entries) {
          expect(VValidator.errorMessage(entry.key, 'email'), entry.value);
        }
      });

      test('field names are inserted as given, in any script', () {
        expect(
          VValidator.errorMessage(VValidationResult.empty, 'メール'),
          'Please enter メール',
        );
      });

      test('English default messages', () {
        expect(
          VValidator.errorMessage(VValidationResult.empty, 'email'),
          'Please enter email',
        );
        expect(
          VValidator.errorMessage(VValidationResult.format, 'password'),
          'Invalid password format',
        );
        expect(
          VValidator.errorMessage(VValidationResult.valid, 'email'),
          isNull,
        );
      });
    });

    group('regressions', () {
      test('url: schemes other than http and https are rejected', () {
        for (final v in [
          'mailto:a@b.com',
          'javascript:alert(1)@a.b',
          'tel:1@2.com',
          'sms:1@2.com',
          'ftp://example.com',
          'file:///a.b',
          'javascript:alert(1)',
        ]) {
          expect(VValidator.url(v), VValidationResult.format, reason: v);
        }
      });

      test('url: scheme letter case does not matter', () {
        expect(VValidator.url('HTTPS://example.com'), VValidationResult.valid);
        expect(VValidator.url('Http://example.com'), VValidationResult.valid);
        expect(VValidator.url('FTP://example.com'), VValidationResult.format);
      });

      test('url: ports, user info, paths and IPv4 hosts', () {
        expect(VValidator.url('example.com:8080'), VValidationResult.valid);
        expect(VValidator.url('http://a.io:65535/x'), VValidationResult.valid);
        expect(
          VValidator.url('http://192.168.0.1:3000'),
          VValidationResult.valid,
        );
        expect(
          VValidator.url('https://user:pw@example.com/a'),
          VValidationResult.valid,
        );
        expect(VValidator.url('example.com:99999'), VValidationResult.format);
        expect(VValidator.url('http://300.1.1.1'), VValidationResult.format);
        expect(VValidator.url('user@example.com'), VValidationResult.format);
      });

      test('url: malformed hosts are rejected', () {
        for (final v in [
          'http://.com',
          'http://a..b',
          'http://example.',
          'https://-.-',
          'http://-a.com',
          'http://a-.com',
          '1.2',
          'a.b',
          'http://exa%mple.com',
        ]) {
          expect(VValidator.url(v), VValidationResult.format, reason: v);
        }
      });

      test('email: dots and hyphens must sit inside their parts', () {
        for (final v in [
          'a@b..com',
          '.a@x.com',
          'a.@x.com',
          'a..b@x.com',
          'a@-x.com',
          'a@x-.com',
          'a@.x.com',
        ]) {
          expect(VValidator.email(v), VValidationResult.format, reason: v);
        }
        expect(VValidator.email('a.b@x-y.co.kr'), VValidationResult.valid);
        expect(VValidator.email('a_b%c+d@x.com'), VValidationResult.valid);
      });

      test('phone: international form of a Korean mobile number', () {
        expect(VValidator.phone('+82 10-1234-5678'), VValidationResult.valid);
        expect(VValidator.phone('+82 10 1234 5678'), VValidationResult.valid);
        expect(VValidator.phone('82101234567'), VValidationResult.format);
        expect(VValidator.phone('821012345678'), VValidationResult.valid);
        expect(VValidator.phone('+82 16-123-4567'), VValidationResult.valid);
        expect(VValidator.phone('+82 2-123-4567'), VValidationResult.format);
      });

      test('phone: a 010 number has 8 digits after the prefix', () {
        expect(VValidator.phone('010-123-4567'), VValidationResult.format);
        expect(VValidator.phone('0101234567'), VValidationResult.format);
        expect(VValidator.phone('010123456789'), VValidationResult.format);
        expect(VValidator.phone('011-123-4567'), VValidationResult.valid);
        expect(VValidator.phone('019-1234-5678'), VValidationResult.valid);
      });

      test('phone: only spaces and hyphens are separators', () {
        expect(VValidator.phone('010\t1234\n5678'), VValidationResult.format);
        expect(VValidator.phone('010 1234-5678'), VValidationResult.valid);
      });

      test('required: empty sets and other empty iterables are empty', () {
        expect(VValidator.required(<int>{}), VValidationResult.empty);
        expect(
          VValidator.required(<int>[1].where((e) => e > 1)),
          VValidationResult.empty,
        );
        expect(VValidator.required({1}), VValidationResult.valid);
        expect(
          VValidator.required(<int>[1].where((e) => e > 0)),
          VValidationResult.valid,
        );
      });
    });

    group('scope and edge cases', () {
      test('email: surrounding spaces fail the pattern', () {
        expect(VValidator.email(' a@b.co'), VValidationResult.format);
        expect(VValidator.email('   '), VValidationResult.empty);
        expect(VValidator.email('a@b'), VValidationResult.format);
        expect(VValidator.email('a@@b.co'), VValidationResult.format);
      });

      test('phone: Korean mobile only, separators ignored', () {
        expect(VValidator.phone('010 1234 5678'), VValidationResult.valid);
        expect(VValidator.phone('02-123-4567'), VValidationResult.format);
        expect(VValidator.phone('+1 415 555 0100'), VValidationResult.format);
      });

      test('url: scheme-less passes, other schemes and bare hosts fail', () {
        expect(VValidator.url('example.com/path?q=1'), VValidationResult.valid);
        expect(VValidator.url('ftp://example.com'), VValidationResult.format);
        expect(VValidator.url('http://localhost'), VValidationResult.format);
        expect(VValidator.url('http://exa mple.com'), VValidationResult.format);
      });

      test('password: boundary length and optional rules', () {
        expect(VValidator.password('abcd1234'), VValidationResult.valid);
        expect(VValidator.password('abc1234'), VValidationResult.length);
        expect(VValidator.password('        '), VValidationResult.format);
        expect(
          VValidator.password('abcdefgh', requireDigit: false),
          VValidationResult.valid,
        );
        expect(
          VValidator.password('12345678', requireLetter: false),
          VValidationResult.valid,
        );
      });

      test('required: non-collection objects are valid, zero included', () {
        expect(VValidator.required(0), VValidationResult.valid);
        expect(VValidator.required(false), VValidationResult.valid);
        expect(VValidator.required(' x '), VValidationResult.valid);
        expect(VValidator.required(const <int>[]), VValidationResult.empty);
        expect(
          VValidator.required(const <String, int>{}),
          VValidationResult.empty,
        );
      });

      test('length checks count characters at the boundary', () {
        expect(VValidator.minLength('abc', 3), VValidationResult.valid);
        expect(VValidator.minLength('ab', 3), VValidationResult.length);
        expect(VValidator.maxLength('abc', 3), VValidationResult.valid);
        expect(VValidator.maxLength('abcd', 3), VValidationResult.length);
      });

      test('numeric rejects signs, spaces and full-width digits', () {
        expect(VValidator.numeric('+1'), VValidationResult.format);
        expect(VValidator.numeric('1 2'), VValidationResult.format);
        expect(VValidator.numeric('１２'), VValidationResult.format);
      });

      test('errorKey and errorMessage are null for valid', () {
        expect(VValidator.errorKey(VValidationResult.valid, 'x'), isNull);
        expect(VValidator.errorMessage(VValidationResult.valid, 'x'), isNull);
      });

      test('every non-valid result has a message and a key', () {
        for (final r in VValidationResult.values) {
          if (r == VValidationResult.valid) continue;
          expect(VValidator.errorMessage(r, 'f'), isNotEmpty);
          expect(VValidator.errorKey(r, 'f'), 'error.f.${r.name}');
        }
      });
    });
  });
}
