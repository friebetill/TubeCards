import 'package:built_collection/built_collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'card.dart';
import 'deck.dart';
import 'deck_member.dart';
import 'offer.dart';
import 'offer_review.dart';
import 'page_info.dart';

part 'connection.g.dart';

/// A generic connection class.
///
/// When you use the class, the generic type must implement a toJson method and
/// the type must appear in the [fromJsonFactory].
@CopyWith()
@JsonSerializable(genericArgumentFactories: true)
class Connection<E> extends Equatable {
  const Connection({
    this.nodes,
    this.totalCount,
    this.pageInfo,
    this.refetch,
    this.fetchMore,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return _$ConnectionFromJson(
      json,
      // Assume that E is inside the fromJsonFactory map.
      (v) => fromJsonFactory[E]!(v! as Map<String, dynamic>) as E,
    );
  }

  Map<String, dynamic> toJson() {
    // Assume that E implements a toJson method.
    return _$ConnectionToJson(this, (v) => (v as dynamic).toJson());
  }

  final BuiltList<E>? nodes;
  final int? totalCount;
  final PageInfo? pageInfo;

  @JsonKey(ignore: true)
  final AsyncCallback? refetch;
  @JsonKey(ignore: true)
  final AsyncCallback? fetchMore;

  @override
  List<Object?> get props => [nodes, totalCount, pageInfo, refetch, fetchMore];
}

final fromJsonFactory = <Type, Function(Map<String, dynamic>)>{
  Card: (json) => Card.fromJson(json),
  Deck: (json) => Deck.fromJson(json),
  DeckMember: (json) => DeckMember.fromJson(json),
  Offer: (json) => Offer.fromJson(json),
  OfferReview: (json) => OfferReview.fromJson(json),
};
