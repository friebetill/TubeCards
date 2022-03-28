import '../image_search_result.dart';
import 'unsplash_image_search_result_item.dart';

class UnsplashImageSearchResult implements ImageSearchResult {
  const UnsplashImageSearchResult(this.items);

  UnsplashImageSearchResult.fromJson(Map<String, dynamic> json)
      : items = (json['results'] as List<dynamic>)
            .map((item) => UnsplashImageSearchResultItem.fromJson(
                  item as Map<String, dynamic>,
                ))
            .toList();

  @override
  final List<UnsplashImageSearchResultItem> items;
}
