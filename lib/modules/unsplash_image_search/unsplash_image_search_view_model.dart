import 'package:flutter/foundation.dart';

import '../../services/image_search_services/unsplash/unsplash_image_search_result.dart';

class UnsplashImageImageSearchViewModel {
  const UnsplashImageImageSearchViewModel({
    required this.searchResult,
    required this.imagesPerPage,
    required this.addSearchTerm,
  });

  final UnsplashImageSearchResult? searchResult;
  final int imagesPerPage;

  final ValueChanged<String> addSearchTerm;
}
