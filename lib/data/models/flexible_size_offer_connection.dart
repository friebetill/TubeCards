import 'package:built_collection/built_collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'offer.dart';
import 'page_info.dart';

part 'flexible_size_offer_connection.g.dart';

@CopyWith()
@JsonSerializable()
// Don't use Connection because it has totalCount and we don't have the
// total count for some offer queries.
class FlexibleSizeOfferConnection extends Equatable {
  const FlexibleSizeOfferConnection({
    this.nodes,
    this.pageInfo,
    this.refetch,
    this.fetchMore,
  });

  factory FlexibleSizeOfferConnection.fromJson(Map<String, dynamic> json) =>
      _$FlexibleSizeOfferConnectionFromJson(json);

  Map<String, dynamic> toJson() => _$FlexibleSizeOfferConnectionToJson(this);

  final BuiltList<Offer>? nodes;
  final PageInfo? pageInfo;

  @JsonKey(ignore: true)
  final AsyncCallback? refetch;
  @JsonKey(ignore: true)
  final AsyncCallback? fetchMore;

  @override
  List<Object?> get props => [
        nodes,
        pageInfo,
        refetch,
        fetchMore,
      ];
}
