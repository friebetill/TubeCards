import 'image_search_result_item.dart';

/// The result of an image search.
abstract class ImageSearchResult {
  /// The URL of the image.
  List<ImageSearchResultItem> get items;
}
