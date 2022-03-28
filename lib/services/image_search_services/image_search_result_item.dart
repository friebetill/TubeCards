/// The result of an image search.
abstract class ImageSearchResultItem {
  /// The URL of the image.
  String? get imageUrl;

  // The URL to the reduced-size versions of the image.
  String? get thumbnailUrl;
}
