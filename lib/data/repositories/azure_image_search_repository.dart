import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../services/image_search_services/azure/azure_image_result_cache.dart';
import '../../services/image_search_services/azure/azure_image_search_result.dart';
import '../../services/image_search_services/azure/azure_image_search_service.dart';

/// The repository used to search for images with Azure.
///
/// The images found are stored in a temporary cache.
@injectable
class AzureImageSearchRepository {
  /// Creates a new unsplash image search repository.
  ///
  /// [cache] is needed to temporarily store the images found by [service].
  AzureImageSearchRepository(this.service, this.cache);

  final AzureImageSearchService service;
  final AzureImageResultCache cache;

  /// Searches for a given search term using [service].
  ///
  /// The results of a search are cached and returned when searching again.
  Future<AzureImageSearchResult> search(String term) async {
    if (cache.contains(term)) {
      return cache.get(term)!;
    }

    final result = await service.search(term);
    cache.set(term, result);

    return result;
  }
}
