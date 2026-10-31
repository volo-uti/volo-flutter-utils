import 'package:flutter_test/flutter_test.dart';
import 'package:volo_flutter_utils/volo_flutter_utils.dart';

void main() {
  group('VDoubleExtension', () {
    group('toFigmaHeight', () {
      test('Figma line height calculation', () {
        expect(24.0.toFigmaHeight(16), equals(1.5));
        expect(20.0.toFigmaHeight(16), equals(1.25));
      });
    });

    group('isBetween', () {
      test('value in range check', () {
        expect(5.0.isBetween(1, 10), isTrue);
        expect(1.0.isBetween(1, 10), isTrue);
        expect(10.0.isBetween(1, 10), isTrue);
        expect(0.0.isBetween(1, 10), isFalse);
        expect(11.0.isBetween(1, 10), isFalse);
      });
    });

    group('clampTo', () {
      test('range clamping', () {
        expect(15.0.clampTo(0, 10), equals(10.0));
        expect((-5.0).clampTo(0, 10), equals(0.0));
        expect(5.0.clampTo(0, 10), equals(5.0));
      });
    });
    group('edge cases', () {
      test('NaN is never between and stays NaN when clamped', () {
        expect(double.nan.isBetween(0, 1), isFalse);
        expect(double.nan.clampTo(0, 1).isNaN, isTrue);
      });

      test('infinity clamps to the bounds', () {
        expect(double.infinity.clampTo(0, 10), 10.0);
        expect(double.negativeInfinity.clampTo(0, 10), 0.0);
        expect(double.infinity.isBetween(0, 10), isFalse);
      });

      test('clampTo throws when min is greater than max', () {
        expect(() => 1.0.clampTo(5, 1), throwsArgumentError);
        expect(() => double.nan.clampTo(10, 0), throwsArgumentError);
      });

      test('toFigmaHeight by zero gives infinity', () {
        expect(24.0.toFigmaHeight(0), double.infinity);
      });
    });
  });
}
