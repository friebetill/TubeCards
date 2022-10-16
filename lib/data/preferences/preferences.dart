import 'package:injectable/injectable.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../models/cards_sort_order.dart';

@singleton
class Preferences {
  Preferences(StreamingSharedPreferences preferences)
      : cardsSortOrder = preferences.getCustomValue<CardsSortOrder>(
          'cards_sort_order',
          defaultValue: CardsSortOrder.defaultValue,
          adapter: CardsSortOrder.jsonAdapter,
        ),
        isDataSaverModeEnabled = preferences.getBool(
          'is_data_saver_mode_enabled',
          defaultValue: false,
        ),
        cardsPerSessionLimit = preferences.getInt(
          'cards_per_session_limit',
          defaultValue: offValue,
        ),
        cardsWithNoReviewDailyLimit = preferences.getInt(
          'cards_with_no_review_daily_limit',
          defaultValue: offValue,
        ),
        _cardsWithNoReviewLearnedTodayCount = preferences.getInt(
          'cards_with_no_review_learned_today_count',
          defaultValue: 0,
        ),
        _newCardsPerDayResetDayString = preferences.getString(
          'daily_settings_last_reset_day',
          defaultValue: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ).toIso8601String(),
        ),
        isTextToSpeechEnabled = preferences.getBool(
          'is_text_to_speech_enabled',
          defaultValue: false,
        );

  /// The value of a number setting when it's turned off.
  ///
  /// [cardsWithNoReviewDailyLimit] and [cardsPerSessionLimit] use this value.
  static const int offValue = -1;

  final Preference<CardsSortOrder> cardsSortOrder;

  /// If [isDataSaverModeEnabled] is active, TubeCards syncs also without wifi
  /// connection.
  final Preference<bool> isDataSaverModeEnabled;

  /// The maximum number of cards that can be learned in one session.
  ///
  /// If [cardsPerSessionLimit] is [offValue], there is no card limit for a
  /// session.
  final Preference<int> cardsPerSessionLimit;

  /// The maximum number of cards with no review the user can learn per day.
  final Preference<int> cardsWithNoReviewDailyLimit;

  final Preference<int> _cardsWithNoReviewLearnedTodayCount;
  final Preference<String> _newCardsPerDayResetDayString;

  /// Indicates whether text-to-speech should be used during review to read out
  /// load the visible content of the current card.
  final Preference<bool> isTextToSpeechEnabled;

  /// The current number of cards with no review that the user has learned
  /// today.
  Stream<int> get cardsWithNoReviewLearnedTodayCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final resetDay = DateTime.parse(_newCardsPerDayResetDayString.getValue());

    if (resetDay != today) {
      _newCardsPerDayResetDayString.setValue(today.toIso8601String());
      _cardsWithNoReviewLearnedTodayCount.setValue(0);
    }

    return _cardsWithNoReviewLearnedTodayCount;
  }

  /// Increase the number of cards with no review the user has learned today.
  void increaseCardsWithNoReviewLearnedTodayCount() {
    _cardsWithNoReviewLearnedTodayCount.setValue(
      _cardsWithNoReviewLearnedTodayCount.getValue() + 1,
    );
  }

  Future<void> clear() async {
    await cardsSortOrder.setValue(cardsSortOrder.defaultValue);
    await isDataSaverModeEnabled.setValue(isDataSaverModeEnabled.defaultValue);
    await cardsPerSessionLimit.setValue(cardsPerSessionLimit.defaultValue);
    await cardsWithNoReviewDailyLimit
        .setValue(cardsWithNoReviewDailyLimit.defaultValue);
    await _cardsWithNoReviewLearnedTodayCount
        .setValue(_cardsWithNoReviewLearnedTodayCount.defaultValue);
    await _newCardsPerDayResetDayString
        .setValue(_newCardsPerDayResetDayString.defaultValue);
    await isTextToSpeechEnabled.setValue(isTextToSpeechEnabled.defaultValue);
  }
}
