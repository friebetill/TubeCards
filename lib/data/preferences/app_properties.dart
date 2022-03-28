import 'package:injectable/injectable.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

@singleton
class AppProperties {
  AppProperties(StreamingSharedPreferences preferences)
      : whatsNewModalShownBuildNumber = preferences.getInt(
          'whats_new_modal_shown_build_number',
          defaultValue: 0,
        );

  /// The build number when the "What's new" modal was shown the last time.
  ///
  /// Is 0 if it has never been set before. CFBundleVersion on iOS and
  /// versionCode on Android.
  final Preference<int> whatsNewModalShownBuildNumber;
}
