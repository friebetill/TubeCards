import 'package:injectable/injectable.dart';

import '../image_search_cache.dart';
import 'azure_image_search_result.dart';

@singleton
class AzureImageResultCache extends ImageSearchCache<AzureImageSearchResult> {}
