import '../image_search_result_item.dart';

/// Class to manage the search result of Unsplash.
class UnsplashImageSearchResultItem implements ImageSearchResultItem {
  const UnsplashImageSearchResultItem({
    this.id,
    this.thumbnailUrl,
    this.smallUrl,
    this.regularUrl,
    this.fullUrl,
    this.authorName,
    this.authorUrl,
  });

  UnsplashImageSearchResultItem.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        smallUrl = json['urls']['small'] as String?,
        regularUrl = json['urls']['regular'] as String?,
        fullUrl = json['urls']['full'] as String?,
        thumbnailUrl = json['urls']['thumb'] as String?,
        authorName = json['user']['name'] as String?,
        authorUrl = json['user']['links']['html'] as String?;

  /// ID of the Unsplash image
  final String? id;

  @override
  final String? thumbnailUrl;

  /// Link to the Unsplash image in jpg format with a width of 400 pixels.
  final String? smallUrl;

  /// Link to the Unsplash image in jpg format with a width of 1080 pixels.
  final String? regularUrl;

  /// Link to the Unsplash image in jpg format with maximum dimensions.
  final String? fullUrl;

  /// Name of the author of the Unsplash image.
  final String? authorName;

  /// Link to the author's Unsplash website.
  final String? authorUrl;

  @override
  String? get imageUrl => smallUrl;
}
