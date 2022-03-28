import 'package:injectable/injectable.dart';

import '../image_search_cache.dart';
import 'unsplash_image_search_result.dart';

@singleton
class UnsplashImageResultCache
    extends ImageSearchCache<UnsplashImageSearchResult> {}
