import '../image_search_result.dart';
import 'azure_image_search_result_item.dart';

/// An image search result from Azure Cognitive Service.
class AzureImageSearchResult implements ImageSearchResult {
  const AzureImageSearchResult(this.items);

  AzureImageSearchResult.fromJson(Map<String, dynamic> json)
      : items = (json['value'] as List<dynamic>)
            .map((item) => AzureImageSearchResultItem.fromJson(
                  item as Map<String, dynamic>,
                ))
            .toList();

  @override
  final List<AzureImageSearchResultItem> items;
}
