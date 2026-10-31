import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:volo_flutter_utils/volo_flutter_utils.dart';

void main() {
  group('VStringExtension', () {
    group('isValidEmail', () {
      test('valid email verification', () {
        expect('test@example.com'.isValidEmail, isTrue);
        expect('user.name@domain.co.kr'.isValidEmail, isTrue);
        expect('user+tag@example.org'.isValidEmail, isTrue);
      });

      test('invalid email verification', () {
        expect('invalid-email'.isValidEmail, isFalse);
        expect('@example.com'.isValidEmail, isFalse);
        expect('test@'.isValidEmail, isFalse);
        expect(''.isValidEmail, isFalse);
      });
    });

    group('isValidUrl', () {
      test('valid URL verification', () {
        expect('https://example.com'.isValidUrl, isTrue);
        expect('http://example.com'.isValidUrl, isTrue);
        expect('example.com'.isValidUrl, isTrue);
      });

      test('invalid URL verification', () {
        expect('not-a-url'.isValidUrl, isFalse);
        expect('mailto:a@b.com'.isValidUrl, isFalse);
        expect(''.isValidUrl, isFalse);
      });
    });

    group('isStrongPassword', () {
      test('strong password verification', () {
        expect('Abcd1234'.isStrongPassword, isTrue);
        expect('Password123'.isStrongPassword, isTrue);
        expect('MyP@ssw0rd'.isStrongPassword, isTrue);
      });

      test('weak password verification', () {
        expect('password'.isStrongPassword, isFalse); // No uppercase, no digits
        expect('PASSWORD'.isStrongPassword, isFalse); // No lowercase, no digits
        expect('12345678'.isStrongPassword, isFalse); // No letters
        expect('Abc123'.isStrongPassword, isFalse); // Less than 8 characters
      });

      test('line breaks count as characters', () {
        expect('Abcd\n1234'.isStrongPassword, isTrue);
        expect('Abcd1234\r'.isStrongPassword, isTrue);
        expect('Ab1\n\n'.isStrongPassword, isFalse);
      });
    });

    group('isValidPassword', () {
      test('basic password verification', () {
        expect('pass123'.isValidPassword, isTrue);
        expect('abcdef'.isValidPassword, isTrue);
        expect('123456'.isValidPassword, isTrue);
      });

      test('invalid password verification', () {
        expect('ab12'.isValidPassword, isFalse); // Less than 6 characters
        expect(
          'abcdefghijklm'.isValidPassword,
          isFalse,
        ); // More than 12 characters
        expect(
          'abc@123'.isValidPassword,
          isFalse,
        ); // Contains special characters
      });
    });

    group('isValidIpAddress', () {
      test('valid IP address verification', () {
        expect('192.168.0.1'.isValidIpAddress, isTrue);
        expect('10.0.0.1'.isValidIpAddress, isTrue);
        expect('255.255.255.255'.isValidIpAddress, isTrue);
        expect('0.0.0.0'.isValidIpAddress, isTrue);
      });

      test('invalid IP address verification', () {
        expect('256.0.0.1'.isValidIpAddress, isFalse);
        expect('192.168.0'.isValidIpAddress, isFalse);
        expect('192.168.0.1.1'.isValidIpAddress, isFalse);
        expect('abc.def.ghi.jkl'.isValidIpAddress, isFalse);
      });

      test('parts with leading zeros are rejected', () {
        expect('000.000.000.000'.isValidIpAddress, isFalse);
        expect('192.168.0.01'.isValidIpAddress, isFalse);
        expect('01.001.000.001'.isValidIpAddress, isFalse);
        expect('192.168.0.100'.isValidIpAddress, isTrue);
        expect('10.20.30.99'.isValidIpAddress, isTrue);
      });
    });

    group('isValidPhone', () {
      test('valid phone number verification', () {
        expect('010-1234-5678'.isValidPhone, isTrue);
        expect('01012345678'.isValidPhone, isTrue);
        expect('011-123-4567'.isValidPhone, isTrue);
      });

      test('invalid phone number verification', () {
        expect('02-1234-5678'.isValidPhone, isFalse);
        expect('010-12-3456'.isValidPhone, isFalse);
        expect('phone'.isValidPhone, isFalse);
      });

      test('international form is accepted, impossible lengths are not', () {
        expect('+82 10-1234-5678'.isValidPhone, isTrue);
        expect('010-123-4567'.isValidPhone, isFalse);
      });
    });

    group('toTimeOfDay', () {
      test('valid time conversion', () {
        final time1 = '14:30'.toTimeOfDay();
        expect(time1, isNotNull);
        expect(time1!.hour, equals(14));
        expect(time1.minute, equals(30));

        final time2 = '00:00'.toTimeOfDay();
        expect(time2, isNotNull);
        expect(time2!.hour, equals(0));
        expect(time2.minute, equals(0));
      });

      test('invalid time conversion', () {
        expect('invalid'.toTimeOfDay(), isNull);
        expect('25:00'.toTimeOfDay(), isNull);
        expect('12:60'.toTimeOfDay(), isNull);
        expect(''.toTimeOfDay(), isNull);
      });
    });

    group('capitalize', () {
      test('capitalize first letter', () {
        expect('hello'.capitalize, equals('Hello'));
        expect('Hello'.capitalize, equals('Hello'));
        expect('HELLO'.capitalize, equals('HELLO'));
        expect('h'.capitalize, equals('H'));
      });

      test('empty string handling', () {
        expect(''.capitalize, equals(''));
      });
    });

    group('isBlank / isNotBlank', () {
      test('blank string check', () {
        expect(''.isBlank, isTrue);
        expect('   '.isBlank, isTrue);
        expect('\t\n'.isBlank, isTrue);
        expect('hello'.isBlank, isFalse);
      });

      test('non-blank string check', () {
        expect('hello'.isNotBlank, isTrue);
        expect(''.isNotBlank, isFalse);
        expect('   '.isNotBlank, isFalse);
      });
    });

    group('isNumeric / isAlpha / isAlphanumeric', () {
      test('numeric only check', () {
        expect('12345'.isNumeric, isTrue);
        expect('12.34'.isNumeric, isFalse);
        expect('abc'.isNumeric, isFalse);
      });

      test('alpha only check', () {
        expect('Hello'.isAlpha, isTrue);
        expect('Hello123'.isAlpha, isFalse);
        expect('123'.isAlpha, isFalse);
      });

      test('alphanumeric only check', () {
        expect('Hello123'.isAlphanumeric, isTrue);
        expect('Hello 123'.isAlphanumeric, isFalse);
        expect('Hello@123'.isAlphanumeric, isFalse);
      });
    });

    group('toTimeOfDay strictness', () {
      test('accepts H:mm and HH:mm', () {
        expect('9:05'.toTimeOfDay(), const TimeOfDay(hour: 9, minute: 5));
        expect('00:00'.toTimeOfDay(), const TimeOfDay(hour: 0, minute: 0));
        expect('23:59'.toTimeOfDay(), const TimeOfDay(hour: 23, minute: 59));
      });

      test('rejects signs, spaces, bad ranges and wrong shapes', () {
        for (final bad in [
          '',
          ' ',
          '24:00',
          '12:60',
          '+9:30',
          '-1:30',
          '9:5',
          '9 :30',
          '12:30:00',
          '1230',
          ':30',
          '12:',
        ]) {
          expect(bad.toTimeOfDay(), isNull, reason: '"$bad"');
        }
      });
    });

    group('verdicts agree with VValidator', () {
      test('email, url and phone use the same rules', () {
        for (final v in [
          '',
          ' a@b.co',
          'a@b.co',
          'example.com',
          'not-a-url',
          'http://localhost',
          '010 1234 5678',
          '010-12-3456',
        ]) {
          expect(
            v.isValidEmail,
            VValidator.email(v) == VValidationResult.valid,
            reason: v,
          );
          expect(
            v.isValidUrl,
            VValidator.url(v) == VValidationResult.valid,
            reason: v,
          );
          expect(
            v.isValidPhone,
            VValidator.phone(v) == VValidationResult.valid,
            reason: v,
          );
        }
      });
    });

    group('empty and non-ASCII input', () {
      test('empty string is not numeric, alpha or alphanumeric', () {
        expect(''.isNumeric, isFalse);
        expect(''.isAlpha, isFalse);
        expect(''.isAlphanumeric, isFalse);
      });

      test('letters outside ASCII are not alpha', () {
        expect('日本語'.isAlpha, isFalse);
        expect('é'.isAlpha, isFalse);
      });

      test('capitalize only changes the first character', () {
        expect('éa'.capitalize, 'Éa');
        expect(' a'.capitalize, ' a');
        expect('1a'.capitalize, '1a');
      });

      test('full-width space counts as whitespace for isBlank', () {
        expect('\u3000'.isBlank, isTrue);
      });
    });
  });
}
