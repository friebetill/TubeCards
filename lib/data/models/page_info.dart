import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'page_info.g.dart';

@CopyWith()
@JsonSerializable()
class PageInfo extends Equatable {
  const PageInfo({
    required this.endCursor,
    required this.hasNextPage,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) =>
      _$PageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PageInfoToJson(this);

  final String? endCursor;

  final bool? hasNextPage;

  @override
  List<Object?> get props => [endCursor, hasNextPage];
}
