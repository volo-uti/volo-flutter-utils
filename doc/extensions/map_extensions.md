# map_extensions

Import: `package:volo_flutter_utils/volo_flutter_utils.dart`

## VMapExtension

Search, typed lookup, filtering, merging and key picking for [Map].

Every transforming member returns a new map and leaves the receiver alone.
Order follows the receiver's iteration order (insertion order for the
default map).

```dart
final map = {'a': 1, 'b': 2, 'c': 3};
map.firstWhereOrNull((k, v) => v > 1); // MapEntry('b', 2)
map.getAs<int>('a');                   // 1
map.pick(['a', 'c']);                  // {'a': 1, 'c': 3}
```

### Members

| Member | Description |
|---|---|
| `MapEntry<K, V>? firstWhereOrNull(bool Function(K, V) test)` | Finds the first entry matching a condition.<br>Returns the first MapEntry that satisfies the test. Returns null if no entry matches. |
| `V? firstValueWhere(bool Function(K) test)` | Finds the first value matching a key condition.<br>Returns the first value whose key satisfies the test. |
| `K? firstKeyWhere(bool Function(V) test)` | Finds the first key matching a value condition.<br>Returns the first key whose value satisfies the test. |
| `T? getAs<T>(K key)` | Returns the value for [key] if it is a [T], otherwise null.<br>A missing key and a value of another type both give null. When [T] is `double`, an `int` value is converted, so JSON numbers such as `10` read the same as `10.0`. |
| `T getOrDefault<T>(K key, T defaultValue)` | Returns the value for [key] as a [T], or [defaultValue] when absent or mistyped. |
| `Map<K, V> whereNotNull()` | Removes entries with null values.<br>Returns a new Map with all null-valued entries removed. |
| `Map<K, V> whereValue(bool Function(V) test)` | Filters entries by value condition.<br>Returns a new Map containing only entries that satisfy the test. |
| `Map<K, V> whereKey(bool Function(K) test)` | Filters entries by key condition.<br>Returns a new Map containing only entries whose keys satisfy the test. |
| `Map<K, T> mapValues<T>(T Function(V) transform)` | Transforms all values.<br>Returns a new Map with the transform function applied to all values. |
| `Map<T, V> mapKeys<T>(T Function(K) transform)` | Transforms all keys.<br>Returns a new Map with the transform function applied to all keys. |
| `Map<K, V> merge(Map<K, V> other)` | Merges with another Map.<br>Returns a new Map with the other Map merged into this one. When keys conflict, values from other take precedence. |
| `Map<K, V> mergeWith(Map<K, V> other, V Function(V, V) resolve)` | Merges with conflict resolution.<br>Resolves conflicting keys using the resolve function. |
| `Map<V, K> invert()` | Inverts keys and values.<br>Returns a new Map with keys and values swapped. If values are duplicated, the last one is retained. |
| `Map<K, V> pick(Iterable<K> keys)` | Picks only the specified keys. |
| `Map<K, V> omit(Iterable<K> keys)` | Omits the specified keys. |
