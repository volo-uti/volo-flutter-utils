import 'package:flutter_test/flutter_test.dart';
import 'package:volo_flutter_utils/volo_flutter_utils.dart';

void main() {
  group('VMapExtension', () {
    group('firstWhereOrNull', () {
      test('find entry matching condition', () {
        final map = {'a': 1, 'b': 2, 'c': 3};

        final result = map.firstWhereOrNull((k, v) => v > 1);
        expect(result, isNotNull);
        expect(result!.key, equals('b'));
        expect(result.value, equals(2));
      });

      test('returns null when no match', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        expect(map.firstWhereOrNull((k, v) => v > 10), isNull);
      });
    });

    group('firstValueWhere', () {
      test('find value by key condition', () {
        final map = {'apple': 1, 'banana': 2, 'cherry': 3};
        expect(map.firstValueWhere((k) => k.startsWith('b')), equals(2));
        expect(map.firstValueWhere((k) => k.startsWith('z')), isNull);
      });
    });

    group('firstKeyWhere', () {
      test('find key by value condition', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        expect(map.firstKeyWhere((v) => v > 2), equals('c'));
        expect(map.firstKeyWhere((v) => v > 10), isNull);
      });
    });

    group('getAs', () {
      test('safe type casting', () {
        final map = <String, dynamic>{'count': 10, 'name': 'test'};

        expect(map.getAs<int>('count'), equals(10));
        expect(map.getAs<String>('name'), equals('test'));
        expect(map.getAs<String>('count'), isNull); // Type mismatch
        expect(map.getAs<int>('missing'), isNull); // Key not found
      });
    });

    group('getAs double', () {
      test('an int value reads as a double', () {
        final map = <String, dynamic>{'p': 10, 'q': 1.5, 's': 'x'};
        expect(map.getAs<double>('p'), 10.0);
        expect(map.getAs<double>('q'), 1.5);
        expect(map.getAs<double>('s'), isNull);
        expect(map.getAs<num>('p'), 10);
        expect(map.getAs<double?>('p'), 10.0);
        expect(map.getAs<int>('q'), isNull);
        expect(map.getOrDefault<double>('p', 0), 10.0);
        expect(map.getOrDefault<double>('missing', 0.5), 0.5);
      });
    });

    group('getOrDefault', () {
      test('get value with default', () {
        final map = <String, dynamic>{'count': 10};

        expect(map.getOrDefault<int>('count', 0), equals(10));
        expect(map.getOrDefault<int>('missing', 0), equals(0));
      });
    });

    group('whereNotNull', () {
      test('remove null values', () {
        final map = {'a': 1, 'b': null, 'c': 3};
        final result = map.whereNotNull();

        expect(result.length, equals(2));
        expect(result.containsKey('b'), isFalse);
      });
    });

    group('whereValue', () {
      test('filter by value condition', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        final result = map.whereValue((v) => v > 1);

        expect(result.length, equals(2));
        expect(result.containsKey('a'), isFalse);
      });
    });

    group('whereKey', () {
      test('filter by key condition', () {
        final map = {'apple': 1, 'banana': 2, 'cherry': 3};
        final result = map.whereKey((k) => k.length > 5);

        expect(result.length, equals(2));
        expect(result.containsKey('apple'), isFalse);
      });
    });

    group('mapValues', () {
      test('transform values', () {
        final map = {'a': 1, 'b': 2};
        final result = map.mapValues((v) => v * 2);

        expect(result['a'], equals(2));
        expect(result['b'], equals(4));
      });
    });

    group('mapKeys', () {
      test('transform keys', () {
        final map = {'a': 1, 'b': 2};
        final result = map.mapKeys((k) => k.toUpperCase());

        expect(result['A'], equals(1));
        expect(result['B'], equals(2));
      });
    });

    group('merge', () {
      test('merge maps', () {
        final map1 = {'a': 1, 'b': 2};
        final map2 = {'b': 3, 'c': 4};
        final result = map1.merge(map2);

        expect(result['a'], equals(1));
        expect(result['b'], equals(3)); // Other value takes precedence
        expect(result['c'], equals(4));
      });
    });

    group('mergeWith', () {
      test('conditional merge', () {
        final map1 = {'a': 1, 'b': 2};
        final map2 = {'b': 3, 'c': 4};
        final result = map1.mergeWith(map2, (v1, v2) => v1 + v2);

        expect(result['a'], equals(1));
        expect(result['b'], equals(5)); // 2 + 3
        expect(result['c'], equals(4));
      });
    });

    group('invert', () {
      test('swap keys and values', () {
        final map = {'a': 1, 'b': 2};
        final result = map.invert();

        expect(result[1], equals('a'));
        expect(result[2], equals('b'));
      });
    });

    group('pick', () {
      test('extract specific keys', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        final result = map.pick(['a', 'c']);

        expect(result.length, equals(2));
        expect(result.containsKey('a'), isTrue);
        expect(result.containsKey('c'), isTrue);
        expect(result.containsKey('b'), isFalse);
      });
    });

    group('omit', () {
      test('exclude specific keys', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        final result = map.omit(['b']);

        expect(result.length, equals(2));
        expect(result.containsKey('a'), isTrue);
        expect(result.containsKey('c'), isTrue);
        expect(result.containsKey('b'), isFalse);
      });
    });

    group('edge cases', () {
      test('empty map', () {
        final empty = <String, int>{};
        expect(empty.firstWhereOrNull((k, v) => true), isNull);
        expect(empty.firstKeyWhere((v) => true), isNull);
        expect(empty.invert(), isEmpty);
        expect(empty.merge({'a': 1}), {'a': 1});
        expect(empty.pick(['a']), isEmpty);
      });

      test('transforms leave the receiver unchanged', () {
        final map = {'a': 1, 'b': null};
        final copy = Map.of(map);
        map
          ..whereNotNull()
          ..merge({'c': 3})
          ..omit(['a']);
        expect(map, copy);
      });

      test('getAs treats a stored null as absent', () {
        final map = <String, Object?>{'a': null};
        expect(map.getAs<int>('a'), isNull);
        expect(map.getOrDefault<int>('a', 7), 7);
      });

      test('getAs on num subtype', () {
        final map = <String, Object?>{'n': 1};
        expect(map.getAs<num>('n'), 1);
        // An int reads as a double, as it does on the web
        expect(map.getAs<double>('n'), 1.0);
        expect(map.getAs<String>('n'), isNull);
      });

      test('invert keeps the last key for duplicate values', () {
        expect({'a': 1, 'b': 1}.invert(), {1: 'b'});
      });

      test('pick and omit ignore unknown keys', () {
        expect({'a': 1}.pick(['x']), isEmpty);
        expect({'a': 1}.omit(['x']), {'a': 1});
      });

      test('mergeWith resolver only runs for shared keys', () {
        var calls = 0;
        final r = {'a': 1}.mergeWith({'a': 2, 'b': 3}, (x, y) {
          calls++;
          return x + y;
        });
        expect(r, {'a': 3, 'b': 3});
        expect(calls, 1);
      });
    });
  });
}
