import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../utils/config.dart';
import '../image_search_service.dart';
import 'azure_image_search_result.dart';

/// Service to search for images on the Azure Cognitive Service.
///
/// The returned images have a license that allows to modify, share,
/// and use them for personal or commercial purposes.
///
/// The documentation for the Azure Image Search API can be found
/// here: https://bit.ly/392ze1k.
@singleton
class AzureImageSearchService
    implements ImageSearchService<AzureImageSearchResult> {
  AzureImageSearchService() : _client = http.Client();

  @override
  final int imagesPerPage = 150;

  final http.Client _client;

  @override
  Future<AzureImageSearchResult> search(
    String searchTerm, {
    int page = 1,
  }) async {
    const resource = '/bing/v7.0/images/search';
    final headers = {'Ocp-Apim-Subscription-Key': azureSubscriptionKey};
    final parameters = {
      'q': searchTerm,
      'count': imagesPerPage.toString(),
      'offset': ((page - 1) * imagesPerPage).toString(),
      'license': 'ModifyCommercially',
      // Azure defaults to 'en', when the languageCode is not valid
      'setLang': ui.window.locale.languageCode,
    };

    final response = await _client
        .get(Uri.https(azureBaseURL, resource, parameters), headers: headers);

    return _handleResponse(response, searchTerm);
  }

  AzureImageSearchResult _handleResponse(
    http.Response response,
    String searchTerm,
  ) {
    switch (response.statusCode) {
      case 200:
        return AzureImageSearchResult.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      case 400:
        throw HttpException(
          '400: Bad request during search for Azure image $searchTerm.\n'
          '${response.body}',
        );
      case 401:
        throw HttpException(
          '401: Unauthorized request or queries per month quota is exceeded '
          'during search for Azure image $searchTerm.\n'
          '${response.body},',
        );
      case 403:
        throw HttpException(
          '403: Forbidden request during search for Azure image $searchTerm.\n'
          '${response.body}',
        );
      default:
        throw HttpException(
          '${response.statusCode}: Unexpected statuscode during search for '
          'Azure image $searchTerm.\n${response.body}',
        );
    }
  }
}
