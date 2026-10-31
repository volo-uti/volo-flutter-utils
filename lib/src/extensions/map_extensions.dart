/// Search, typed lookup, filtering, merging and key picking for [Map].
///
/// Every transforming member returns a new map and leaves the receiver alone.
/// Order follows the receiver's iteration order (insertion order for the
/// default map).
///
/// ```dart
/// final map = {'a': 1, 'b': 2, 'c': 3};
/// map.firstWhereOrNull((k, v) => v > 1); // MapEntry('b', 2)
/// map.getAs<int>('a');                   // 1
/// map.pick(['a', 'c']);                  // {'a': 1, 'c': 3}
/// ```
extension VMapExtension<K, V> on Map<K, V> {
  // ============================================================
  // Search
  // ============================================================

  /// Finds the first entry matching a condition.
  ///
  /// Returns the first MapEntry that satisfies the test.
  /// Returns null if no entry matches.
  ///
  /// ```dart
  /// final map = {'a': 1, 'b': 2, 'c': 3};
  /// map.firstWhereOrNull((k, v) => v > 1); // MapEntry('b', 2)
  /// map.firstWhereOrNull((k, v) => v > 10); // null
  /// ```
  MapEntry<K, V>? firstWhereOrNull(bool Function(K key, V value) test) {
    for (final entry in entries) {
      if (test(entry.key, entry.value)) {
        return entry;
      }
    }
    return null;
  }

  /// Finds the first value matching a key condition.
  ///
  /// Returns the first value whose key satisfies the test.
  ///
  /// ```dart
  /// final map = {'apple': 1, 'banana': 2, 'cherry': 3};
  /// map.firstValueWhere((k) => k.startsWith('b')); // 2
  /// map.firstValueWhere((k) => k.startsWith('z')); // null
  /// ```
  V? firstValueWhere(bool Function(K key) test) {
    for (final entry in entries) {
      if (test(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Finds the first key matching a value condition.
  ///
  /// Returns the first key whose value satisfies the test.
  ///
  /// ```dart
  /// final map = {'a': 1, 'b': 2, 'c': 3};
  /// map.firstKeyWhere((v) => v > 2); // 'c'
  /// ```
  K? firstKeyWhere(bool Function(V value) test) {
    for (final entry in entries) {
      if (test(entry.value)) {
        return entry.key;
      }
    }
    return null;
  }

  // ============================================================
  // Safe Access
  // ============================================================

  /// Returns the value for [key] if it is a [T], otherwise null.
  ///
  /// A missing key and a value of another type both give null. When [T] is
  /// `double`, an `int` value is converted, so JSON numbers such as `10` read
  /// the same as `10.0`.
  ///
  /// ```dart
  /// final map = {'count': 10, 'name': 'test'};
  /// map.getAs<int>('count'); // 10
  /// map.getAs<double>('count'); // 10.0
  /// map.getAs<String>('count'); // null (type mismatch)
  /// map.getAs<int>('missing'); // null (key not found)
  /// ```
  T? getAs<T>(K key) {
    final value = this[key];
    if (value is T) {
      return value;
    }
    // `int` is not a `double` on the VM, but JSON numbers decode as either
    if (value is int && <T>[] is List<double?>) {
      return value.toDouble() as T;
    }
    return null;
  }

  /// Returns the value for [key] as a [T], or [defaultValue] when absent or mistyped.
  ///
  /// ```dart
  /// final map = {'count': 10};
  /// map.getOrDefault<int>('count', 0); // 10
  /// map.getOrDefault<int>('missing', 0); // 0
  /// ```
  T getOrDefault<T>(K key, T defaultValue) => getAs<T>(key) ?? defaultValue;

  // ============================================================
  // Transformation
  // ============================================================

  /// Removes entries with null values.
  ///
  /// Returns a new Map with all null-valued entries removed.
  ///
  /// ```dart
  /// final map = {'a': 1, 'b': null, 'c': 3};
  /// map.whereNotNull(); // {'a': 1, 'c': 3}
  /// ```
  Map<K, V> whereNotNull() =>
      Map.fromEntries(entries.where((e) => e.value != null));

  /// Filters entries by value condition.
  ///
  /// Returns a new Map containing only entries that satisfy the test.
  ///
  /// ```dart
  /// final map = {'a': 1, 'b': 2, 'c': 3};
  /// map.whereValue((v) => v > 1); // {'b': 2, 'c': 3}
  /// ```
  Map<K, V> whereValue(bool Function(V value) test) =>
      Map.fromEntries(entries.where((e) => test(e.value)));

  /// Filters entries by key condition.
  ///
  /// Returns a new Map containing only entries whose keys satisfy the test.
  ///
  /// ```dart
  /// final map = {'apple': 1, 'banana': 2, 'cherry': 3};
  /// map.whereKey((k) => k.length > 5); // {'banana': 2, 'cherry': 3}
  /// ```
  Map<K, V> whereKey(bool Function(K key) test) =>
      Map.fromEntries(entries.where((e) => test(e.key)));

  /// Transforms all values.
  ///
  /// Returns a new Map with the transform function applied to all values.
  ///
  /// ```dart
  /// final map = {'a': 1, 'b': 2};
  /// map.mapValues((v) => v * 2); // {'a': 2, 'b': 4}
  /// ```
  Map<K, T> mapValues<T>(T Function(V value) transform) =>
      map((key, value) => MapEntry(key, transform(value)));

  /// Transforms all keys.
  ///
  /// Returns a new Map with the transform function applied to all keys.
  ///
  /// ```dart
  /// final map = {'a': 1, 'b': 2};
  /// map.mapKeys((k) => k.toUpperCase()); // {'A': 1, 'B': 2}
  /// ```
  Map<T, V> mapKeys<T>(T Function(K key) transform) =>
      map((key, value) => MapEntry(transform(key), value));

  // ============================================================
  // Merge
  // ============================================================

  /// Merges with another Map.
  ///
  /// Returns a new Map with the other Map merged into this one.
  /// When keys conflict, values from other take precedence.
  ///
  /// ```dart
  /// final map1 = {'a': 1, 'b': 2};
  /// final map2 = {'b': 3, 'c': 4};
  /// map1.merge(map2); // {'a': 1, 'b': 3, 'c': 4}
  /// ```
  Map<K, V> merge(Map<K, V> other) => {...this, ...other};

  /// Merges with conflict resolution.
  ///
  /// Resolves conflicting keys using the resolve function.
  ///
  /// ```dart
  /// final map1 = {'a': 1, 'b': 2};
  /// final map2 = {'b': 3, 'c': 4};
  /// map1.mergeWith(map2, (v1, v2) => v1 + v2); // {'a': 1, 'b': 5, 'c': 4}
  /// ```
  Map<K, V> mergeWith(Map<K, V> other, V Function(V value1, V value2) resolve) {
    final result = Map<K, V>.from(this);
    for (final entry in other.entries) {
      if (result.containsKey(entry.key)) {
        result[entry.key] = resolve(result[entry.key] as V, entry.value);
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  // ============================================================
  // Utility
  // ============================================================

  /// Inverts keys and values.
  ///
  /// Returns a new Map with keys and values swapped.
  /// If values are duplicated, the last one is retained.
  ///
  /// ```dart
  /// final map = {'a': 1, 'b': 2};
  /// map.invert(); // {1: 'a', 2: 'b'}
  /// ```
  Map<V, K> invert() =>
      Map.fromEntries(entries.map((e) => MapEntry(e.value, e.key)));

  /// Picks only the specified keys.
  ///
  /// ```dart
  /// final map = {'a': 1, 'b': 2, 'c': 3};
  /// map.pick(['a', 'c']); // {'a': 1, 'c': 3}
  /// ```
  Map<K, V> pick(Iterable<K> keys) {
    final keySet = keys.toSet();
    return Map.fromEntries(entries.where((e) => keySet.contains(e.key)));
  }

  /// Omits the specified keys.
  ///
  /// ```dart
  /// final map = {'a': 1, 'b': 2, 'c': 3};
  /// map.omit(['b']); // {'a': 1, 'c': 3}
  /// ```
  Map<K, V> omit(Iterable<K> keys) {
    final keySet = keys.toSet();
    return Map.fromEntries(entries.where((e) => !keySet.contains(e.key)));
  }
}
