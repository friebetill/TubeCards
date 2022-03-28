import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../utils/config.dart';
import '../image_search_service.dart';
import 'unsplash_image_search_result.dart';

/// Service to search for images for the cover image of the decks.
@singleton
class UnsplashImageSearchService
    implements ImageSearchService<UnsplashImageSearchResult> {
  /// Creates a service to search for images for the cover image of the decks.
  UnsplashImageSearchService();

  /// Base url used to access the Unsplash API.
  static const String baseURL = 'api.unsplash.com';

  @override
  final int imagesPerPage = 30;

  final http.Client _client = http.Client();

  @override
  Future<UnsplashImageSearchResult> search(
    String searchTerm, {
    int page = 1,
  }) async {
    const resource = '/search/photos';
    final params = {
      'query': searchTerm,
      'page': page.toString(),
      'per_page': imagesPerPage.toString(),
      'client_id': unplashAccessToken,
    };

    final response = await _client.get(Uri.https(baseURL, resource, params));

    return _handleReponse(response, searchTerm);
  }

  UnsplashImageSearchResult _handleReponse(
    http.Response response,
    String searchTerm,
  ) {
    switch (response.statusCode) {
      case 200:
        return UnsplashImageSearchResult.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      case 400:
        throw HttpException(
          '400: Bad request during search for Unsplash image $searchTerm.\n'
          '${response.body}',
        );
      case 401:
        throw HttpException(
          '401: Unauthorized request during search for Unsplash image '
          '$searchTerm.\n${response.body}',
        );
      case 403:
        throw HttpException(
          '403: Forbidden request during search for Unsplash image '
          '$searchTerm.\n${response.body}',
        );
      default:
        throw HttpException(
          '${response.statusCode}: Unexpected statuscode during search for '
          'Unsplash image $searchTerm.\n${response.body}',
        );
    }
  }
}
