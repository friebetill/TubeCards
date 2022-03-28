import 'package:built_value/serializer.dart';

class DateTimeSerializer implements PrimitiveSerializer<DateTime> {
  @override
  DateTime deserialize(
    Serializers _,
    Object serialized, {
    // ignore: avoid-unused-parameters
    FullType specifiedType = FullType.unspecified,
  }) {
    assert(serialized is String,
        "Expected 'String' but got ${serialized.runtimeType}");

    return DateTime.parse(serialized as String);
  }

  @override
  Object serialize(
    Serializers _,
    DateTime date, {
    // ignore: avoid-unused-parameters
    FullType specifiedType = FullType.unspecified,
  }) {
    return date.toUtc().toIso8601String();
  }

  @override
  Iterable<Type> get types => [DateTime];

  @override
  String get wireName => 'DateTime';
}
