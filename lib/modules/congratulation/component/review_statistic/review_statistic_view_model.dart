class ReviewStatisticViewModel {
  const ReviewStatisticViewModel({
    required this.showIncreaseStatistic,
    required this.strengthIncrease,
    required this.isLoading,
    required this.knownCardsCount,
    required this.unknownCardsCount,
  });

  /// True if the increase statistic should be shown.
  final bool showIncreaseStatistic;

  /// The increase of the strength in percent.
  final double? strengthIncrease;

  /// True if the increase is calculating.
  final bool isLoading;

  /// Number of known cards in the learn session.
  final int knownCardsCount;

  /// Number of unknown cards in the learn session.
  final int unknownCardsCount;
}
