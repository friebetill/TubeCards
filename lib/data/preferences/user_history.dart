import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

@singleton
class UserHistory {
  UserHistory(StreamingSharedPreferences preferences)
      : recentDeckAndCardsSearchTerms = preferences.getStringList(
          'recent_search_terms',
          defaultValue: [],
        ),
        recentOfferSearchTerms = preferences.getStringList(
          'recent_offer_search_terms',
          defaultValue: [],
        ),
        brushSize = preferences.getDouble(
          'most_recent_brush_size',
          defaultValue: 5,
        ),
        recentBrushColors = preferences.getCustomValue<List<Color>>(
          'recent_brush_colors',
          defaultValue: [Colors.black],
          adapter: JsonAdapter(
            serializer: (v) => v.map((r) => r.value.toString()).toList(),
            deserializer: (v) => (v as List<dynamic>)
                .map((v) => Color(int.parse(v as String)))
                .toList(),
          ),
        ),
        appLaunchCount = preferences.getInt(
          'app_launches',
          defaultValue: 0,
        ),
        nextShowRateAppDialogDate = preferences.getCustomValue<DateTime>(
          'nextShowRateAppDialogDate',
          defaultValue: DateTime.now(),
          adapter: DateTimeAdapter.instance,
        ),
        textSize = preferences.getDouble(
          'drawing_text_size',
          defaultValue: 14,
        ),
        recentTextColors = preferences.getCustomValue<List<Color>>(
          'drawing_recent_text_colors',
          defaultValue: [Colors.black],
          adapter: JsonAdapter(
            serializer: (v) => v.map((r) => r.value.toString()).toList(),
            deserializer: (v) => (v as List<dynamic>)
                .map((v) => Color(int.parse(v as String)))
                .toList(),
          ),
        ),
        recentShapeColors = preferences.getCustomValue<List<Color>>(
          'drawing_recent_shape_colors',
          defaultValue: [Colors.black],
          adapter: JsonAdapter(
            serializer: (v) => v.map((r) => r.value.toString()).toList(),
            deserializer: (v) => (v as List<dynamic>)
                .map((v) => Color(int.parse(v as String)))
                .toList(),
          ),
        ),
        shapeStrokeSize = preferences.getDouble(
          'drawing_shape_stroke__size',
          defaultValue: 14,
        ),
        hasUserSeenMarketplaceWelcomeDialog = preferences.getBool(
          'has_user_seen_marketplace_welcome_dialog',
          defaultValue: false,
        );

  /// Search terms that have been recently used to search for decks or cards.
  ///
  /// The number of search terms stored is limited by 5.
  final Preference<List<String>> recentDeckAndCardsSearchTerms;

  /// Search terms that have been recently used to search for decks or cards.
  ///
  /// The number of search terms stored is limited by 5.
  final Preference<List<String>> recentOfferSearchTerms;

  /// Last used brush size on the drawing page.
  final Preference<double> brushSize;

  /// List of recently used brush colors.
  ///
  /// The number of colors stored is limited by 5.
  final Preference<List<Color>> recentBrushColors;

  /// The number of times the user has launched the app.
  final Preference<int> appLaunchCount;

  /// The date after which the rate app dialog is allowed to be displayed.
  final Preference<DateTime> nextShowRateAppDialogDate;

  /// Last used text size on the drawing page.
  final Preference<double> textSize;

  /// Colors that have been recently used for the text on the drawing page.
  final Preference<List<Color>> recentTextColors;

  /// Colors that have been recently used for the shapes on the drawing page.
  final Preference<List<Color>> recentShapeColors;

  /// Last used stroke size of the shapes on the drawing page
  final Preference<double> shapeStrokeSize;

  /// Adds a new recently used search term.
  /// True when the user saw the marketplace welcome dialog.
  final Preference<bool> hasUserSeenMarketplaceWelcomeDialog;

  /// Adds a new recently used deck and cards search term.
  ///
  /// As a side effect the least recently used search term might be permanently
  /// removed.
  void addRecentSearchTerm(String searchTerm) {
    _addAndClamp(recentDeckAndCardsSearchTerms, searchTerm);
  }

  /// Adds a new recently used offer search term.
  ///
  /// As a side effect the least recently used search term might be permanently
  /// removed.
  void addRecentOfferSearchTerm(String searchTerm) {
    _addAndClamp(recentOfferSearchTerms, searchTerm);
  }

  /// Adds a new recently used brush color.
  ///
  /// As a side effect the least recently used search term might be permanently
  /// removed.
  void addRecentBrushColor(Color brushColor) {
    _addAndClamp(recentBrushColors, brushColor);
  }

  /// Adds a new recently used text color.
  ///
  /// As a side effect the least recently used search term might be permanently
  /// removed.
  void addRecentTextColor(Color textColor) {
    _addAndClamp(recentTextColors, textColor);
  }

  /// Adds a new recently used shape color.
  ///
  /// As a side effect the least recently used search term might be permanently
  /// removed.
  void addRecentShapeColor(Color shapeColor) {
    _addAndClamp(recentShapeColors, shapeColor);
  }

  void incrementLaunchCounterByOne() {
    appLaunchCount.setValue(appLaunchCount.getValue() + 1);
  }

  Future<void> clear() async {
    await recentDeckAndCardsSearchTerms
        .setValue(recentDeckAndCardsSearchTerms.defaultValue);
  }

  void _addAndClamp<E>(Preference<List<E>> preference, E value) {
    final values = preference.getValue();

    /// Make sure we don't have duplicates in the recently used colors.
    if (values.contains(value)) {
      values.remove(value);
    }

    values.insert(0, value);
    while (values.length > 5) {
      values.removeLast();
    }

    preference.setValue(values);
  }
}
