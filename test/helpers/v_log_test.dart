import 'package:flutter_test/flutter_test.dart';
import 'package:volo_flutter_utils/volo_flutter_utils.dart';

void main() {
  group('VLog', () {
    test('debug log output', () {
      // Only works in debug mode, so success if it runs without exception
      expect(() => VLog.debug('Test debug message'), returnsNormally);
      expect(
        () => VLog.debug('Test with title', title: 'Title'),
        returnsNormally,
      );
      expect(
        () => VLog.debug('Test with time', showTime: true),
        returnsNormally,
      );
      expect(
        () => VLog.debug('Test without path', showPath: false),
        returnsNormally,
      );
    });

    test('info log output', () {
      expect(() => VLog.info('Test info message'), returnsNormally);
      expect(
        () => VLog.info('Test with options', title: 'Info', showTime: true),
        returnsNormally,
      );
    });

    test('warn log output', () {
      expect(() => VLog.warn('Test warning message'), returnsNormally);
      expect(
        () => VLog.warn('Test with title', title: 'Warning'),
        returnsNormally,
      );
    });

    test('error log output', () {
      expect(
        () => VLog.error(exception: Exception('Test exception')),
        returnsNormally,
      );
      expect(
        () => VLog.error(message: 'Custom error message'),
        returnsNormally,
      );
      expect(
        () => VLog.error(
          exception: Exception('Error'),
          title: 'API',
          showTime: true,
        ),
        returnsNormally,
      );
    });

    test('all options combination', () {
      expect(
        () => VLog.debug('Full options test', title: 'Test', showTime: true),
        returnsNormally,
      );
    });
  });
}
