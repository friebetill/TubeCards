/// Indicates whether the user knew the card or not.
enum Confidence {
  /// Indicates that the answer for a card was known during a review.
  known,

  /// Indicates that the answer for a card was not known during a review.
  unknown,
}
