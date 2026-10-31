// ignore_for_file: avoid_print

import 'package:volo_flutter_utils/volo_flutter_utils.dart';

void main() {
  // ============================================================
  // String Extensions
  // ============================================================
  print('=== String Extensions ===');
  print('Email valid: ${'test@example.com'.isValidEmail}'); // true
  print('Password strong: ${'Abcd1234'.isStrongPassword}'); // true
  print('Phone valid: ${'010-1234-5678'.isValidPhone}'); // true
  print('Capitalize: ${'hello'.capitalize}'); // Hello
  print('Is blank: ${'   '.isBlank}'); // true
  print('');

  // ============================================================
  // Double Extensions
  // ============================================================
  print('=== Double Extensions ===');
  print('Figma height: ${24.0.toFigmaHeight(16)}'); // 1.5
  print('');

  // ============================================================
  // DateTime Extensions
  // ============================================================
  print('=== DateTime Extensions ===');
  final now = DateTime.now();
  print('Is today: ${now.isToday}'); // true
  print('Is weekend: ${now.isWeekend}');
  print('');

  // ============================================================
  // Map Extensions
  // ============================================================
  print('=== Map Extensions ===');
  final map = {'name': 'John', 'age': 30};
  print('Get as String: ${map.getAs<String>('name')}'); // John
  print('Get as int: ${map.getAs<int>('age')}'); // 30
  print('');

  // ============================================================
  // Logging
  // ============================================================
  print('=== Logging ===');
  VLog.debug('Debug message');
  VLog.info('Info message', title: 'API');
  VLog.warn('Warning message');
  VLog.error(exception: Exception('Test error'), title: 'Network');
  print('');

  // ============================================================
  // Validators
  // ============================================================
  print('=== Validators ===');
  print(
    'Email: ${VValidator.email('test@example.com')}',
  ); // VValidationResult.valid
  print('Password: ${VValidator.password('weak')}'); // VValidationResult.length
  print(
    'Phone: ${VValidator.phone('010-1234-5678')}',
  ); // VValidationResult.valid
  print('Required: ${VValidator.required('')}'); // VValidationResult.empty
  print('');

  // ============================================================
  // Delay
  // ============================================================
  print('=== Debounce and throttle ===');
  print('VDebouncer - debounces function calls');
  print('VThrottler - throttles function calls');
}
