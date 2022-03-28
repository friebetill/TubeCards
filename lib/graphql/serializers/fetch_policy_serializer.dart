import 'package:built_value/serializer.dart';
import 'package:ferry/ferry.dart';

class FetchPolicySerializer implements PrimitiveSerializer<FetchPolicy> {
  @override
  FetchPolicy deserialize(
    Serializers _,
    Object serialized, {
    // ignore: avoid-unused-parameters
    FullType specifiedType = FullType.unspecified,
  }) {
    assert(serialized is String,
        "Expected 'String' but got ${serialized.runtimeType}");

    return _fetchPolicyMap.entries
        .singleWhere(
          (e) => e.value == serialized,
          orElse: () => throw ArgumentError(
            '`$serialized` is not one of the supported values: '
            '${_fetchPolicyMap.values.join(', ')}',
          ),
        )
        .key;
  }

  @override
  Object serialize(
    Serializers _,
    FetchPolicy fetchPolicy, {
    // ignore: avoid-unused-parameters
    FullType specifiedType = FullType.unspecified,
  }) =>
      _fetchPolicyMap[fetchPolicy]!;

  @override
  Iterable<Type> get types => [FetchPolicy];

  @override
  String get wireName => 'FetchPolicy';
}

const _fetchPolicyMap = <FetchPolicy, String>{
  FetchPolicy.NoCache: 'NoCache',
  FetchPolicy.NetworkOnly: 'NetworkOnly',
  FetchPolicy.CacheOnly: 'CacheOnly',
  FetchPolicy.CacheFirst: 'CacheFirst',
  FetchPolicy.CacheAndNetwork: 'CacheAndNetwork',
};
