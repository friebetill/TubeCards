import 'package:flutter/foundation.dart';

import '../../services/image_search_services/azure/azure_image_search_result.dart';

class AzureImageSearchViewModel {
  const AzureImageSearchViewModel({
    required this.searchResult,
    required this.imagesPerPage,
    required this.addSearchTerm,
  });

  final AzureImageSearchResult? searchResult;
  final int imagesPerPage;

  final ValueChanged<String> addSearchTerm;
}
