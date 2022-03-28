import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:injectable/injectable.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'custom_cache_manager.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<StreamingSharedPreferences> get prefs =>
      StreamingSharedPreferences.instance;

  InAppReview get inAppReview => InAppReview.instance;

  // Needs to be provided as a singleton here so that it's available early
  // enough. Using the @Singleton annotator leads to errors when accessing
  // getIt<BaseCacheManager>().
  BaseCacheManager get cacheManager => CustomCacheManager();
}
