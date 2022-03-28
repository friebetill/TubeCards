import 'package:json_annotation/json_annotation.dart';

import '../../services/image_search_services/unsplash/unsplash_image_search_result_item.dart';
import 'base_model.dart';

part 'unsplash_image.g.dart';

/// An image from Unsplash.com.
@JsonSerializable()
class UnsplashImage extends BaseModel {
  /// Constructs a new [UnsplashImage] instance from the given parameters.
  const UnsplashImage({
    String? id,
    this.unsplashId,
    this.authorName,
    this.authorUrl,
    this.smallUrl,
    this.regularUrl,
    this.fullUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  /// Constructs a new [UnsplashImage] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from a server request.
  factory UnsplashImage.fromJson(Map<String, dynamic> json) =>
      _$UnsplashImageFromJson(json);

  /// Constructs a new [UnsplashImage] from the given [unsplashSearchResult].
  factory UnsplashImage.fromUnsplashSearchResultItem(
    UnsplashImageSearchResultItem unsplashSearchResult,
  ) {
    return UnsplashImage(
      unsplashId: unsplashSearchResult.id,
      authorName: unsplashSearchResult.authorName,
      authorUrl: unsplashSearchResult.authorUrl,
      regularUrl: unsplashSearchResult.regularUrl,
      smallUrl: unsplashSearchResult.smallUrl,
      fullUrl: unsplashSearchResult.fullUrl,
    );
  }

  /// The id that uniquely identifies this image in the Unsplash API.
  ///
  /// It is obtained directly from the Unsplash API.
  final String? unsplashId;

  /// Name of the author of the image.
  final String? authorName;

  /// URL linking to the public profile of the author on Unsplash.
  final String? authorUrl;

  /// URL to the image with medium-sized resolution.
  final String? regularUrl;

  /// URL to the image with small-sized resolution.
  final String? smallUrl;

  /// URL to the image with full-sized resolution.
  final String? fullUrl;

  /// Constructs a new json map from this [UnsplashImage].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$UnsplashImageToJson(this);

  @override
  List<Object?> get props => super.props
    ..addAll([
      unsplashId,
      authorName,
      authorUrl,
      smallUrl,
      regularUrl,
      fullUrl,
    ]);
}

/// The default cover image of decks.
final UnsplashImage defaultCoverImage = UnsplashImage(
  unsplashId: '5NE6mX0WVfQ',
  smallUrl:
      'https://images.unsplash.com/photo-1533158326339-7f3cf2404354?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjM3MDcwfQ',
  regularUrl:
      'https://images.unsplash.com/photo-1533158326339-7f3cf2404354?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjM3MDcwfQ',
  fullUrl:
      'https://images.unsplash.com/photo-1533158326339-7f3cf2404354?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjM3MDcwfQ',
  authorName: 'Geordanna Cordero-Fields',
  authorUrl: 'https://unsplash.com/@geordannatheartist',
  createdAt: DateTime.parse('2019-01-16T15:13:32.551Z'),
  updatedAt: DateTime.parse('2019-01-16T15:13:32.551Z'),
);
