import '../image_search_result_item.dart';

/// An image search result from Azure Cognitive Service.
class AzureImageSearchResultItem implements ImageSearchResultItem {
  AzureImageSearchResultItem({this.imageUrl, this.thumbnailUrl});

  AzureImageSearchResultItem.fromJson(Map<String, dynamic> json)
      : imageUrl = json['contentUrl'] as String?,
        thumbnailUrl = json['thumbnailUrl'] as String?;

  @override
  final String? imageUrl;

  @override
  final String? thumbnailUrl;
}
