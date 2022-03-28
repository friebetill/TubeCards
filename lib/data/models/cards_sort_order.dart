import 'dart:convert';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'cards_order_field.dart';
import 'order_direction.dart';

part 'cards_sort_order.g.dart';

/// Sorting options for a cards connection.
@JsonSerializable()
@CopyWith()
@immutable
class CardsSortOrder extends Equatable {
  const CardsSortOrder({
    required this.field,
    required this.direction,
  });

  static const defaultValue = CardsSortOrder(
    field: CardsOrderField.createdAt,
    direction: OrderDirection.descending,
  );

  /// The field to sort cards members by.
  final CardsOrderField field;

  /// The sorting direction.
  final OrderDirection direction;

  static final jsonAdapter = JsonAdapter<CardsSortOrder>(
    serializer: (sortOrder) => jsonEncode(_$CardsSortOrderToJson(sortOrder)),
    deserializer: (value) => _$CardsSortOrderFromJson(
      jsonDecode(value as String) as Map<String, dynamic>,
    ),
  );

  @override
  List<Object> get props => [field, direction];
}
