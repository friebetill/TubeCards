import 'dart:io';

import 'image_search_result.dart';

/// Service for searching images online.
abstract class ImageSearchService<T extends ImageSearchResult> {
  /// To limit the number of images per request, the images are divided
  /// into pages. [imagesPerPage] defines how many images are requested per
  /// page.
  int get imagesPerPage;

  /// Returns the search results of an image search using [searchTerm].
  ///
  /// [page] defines which page is requested, where each page has
  /// [imagesPerPage] images.
  ///
  /// Throws [SocketException] in case there is no internet and
  /// [HttpException] if the status code is not 200.
  Future<T> search(String searchTerm, {int page = 1});
}
