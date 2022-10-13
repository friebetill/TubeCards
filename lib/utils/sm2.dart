import 'dart:math';

import '../data/models/confidence.dart';

/// The initial value of the ease for the SM2 algorithm.
///
/// Indicates how difficult it is for the user to review a card. The value
/// ranges from [1.3 to 2.5]. The higher the value the easier it is for the
/// user.
const double initialEase = 2.5;

const int initialStreakKnown = 0;

/// The maximum number of days with which [Duration] can be created.
///
/// If a [Duration] is created with a higher value, a negative [Duration] is
/// returned. See more here https://github.com/dart-lang/sdk/issues/39619.
const int _upperDaysInDurationLimit = 106751991;

/// The maximum date that is returned, since dates above it throw
/// ArgumentErrors.
///
/// See here https://dartpad.dev/2d48b8bc99f9f046c1175d8f3f1d18e1 and
/// https://api.dartlang.org/stable/2.6.1/dart-core/DateTime-class.html.
final DateTime _upperLimitDateTime = DateTime.parse('275760-09-13T00:00:00Z');

/// Returns the results of the SM2 algorithm in a SM2Result.
///
/// The [dueDate] is the date on which the card was due and the [confidence]
/// indicates how well the user knew the card.
///
/// The [reviewDate] is the date on which the review was done and
/// [lastReviewDate] is the date of the previous review, if there was one.
/// If [lastReviewDate] is not given, it is assumed that it's the first review.
/// [streakKnown] indicates how many times the card has been correctly
/// reviewed in a row. The [ease] indicates how difficult it is for the
/// user to review the card and is a value from [1.3 to 2.5].
///
/// All DateTime objects are expected in UTC.
///
/// This algorithm is based on this blog post: https://bit.ly/2LnfNrg.
/// In two places changes have been made to the SM2 algorithm:
/// 1. Instead of Quality, the algorithm accepts Confidence, where Confidence
///    KNOWN corresponds to Quality 5 and UNKNOWN corresponds to ~2.
/// 2. If the given confidence is UNKNOWN, the next due date is calculated
///    at 40% of the previous time interval instead of 0%.
SM2Result run(
  DateTime dueDate,
  Confidence confidence, {
  required int streakKnown,
  required double ease,
  DateTime? reviewDate,
  DateTime? lastReviewDate,
}) {
  final dueDateUtc = dueDate.toUtc();
  final reviewDateUtc = reviewDate?.toUtc();
  final lastReviewDateUtc = lastReviewDate?.toUtc();

  assert(streakKnown >= 0 && ease >= 1.3 && ease <= 2.5);
  assert(lastReviewDateUtc == null && streakKnown == 0 ||
      lastReviewDateUtc != null);

  final clampedEase = ease.clamp(1.3, 2.5).toDouble();
  final positiveStreakKnown = max(streakKnown, 0);
  final updatedStreakKnown =
      confidence == Confidence.known ? positiveStreakKnown + 1 : 0;

  return SM2Result._(
    _getNextDueDate(
      dueDateUtc,
      lastReviewDateUtc,
      clampedEase,
      updatedStreakKnown,
      confidence,
      reviewDateUtc ?? DateTime.now().toUtc(),
    ),
    updatedStreakKnown,
    _getUpdatedEase(confidence, clampedEase),
  );
}

/// The result of the SM2 algorithm.
class SM2Result {
  SM2Result._(this.dueDate, this.streakKnown, this.ease);

  /// The "optimal" date at which the next review should be made.
  ///
  /// It is in UTC.
  final DateTime dueDate;

  /// An SM2 user specific value corresponding to the difficulty of the fact.
  final double ease;

  /// The number of times the user has known the card in a row.
  final int streakKnown;
}

DateTime _getNextDueDate(
  DateTime nextDueDate,
  DateTime? lastReviewDate,
  double ease,
  int updatedStreaKnown,
  Confidence confidence,
  DateTime reviewTime,
) {
  if (confidence == Confidence.known) {
    final streakKnownDuration = Duration(
      days: updatedStreaKnown == 1
          ? 1
          : min(
              4 * pow(ease, updatedStreaKnown - 2).round(),
              _upperDaysInDurationLimit,
            ),
    );
    final scheduledDayDiffDuration =
        Duration(days: reviewTime.difference(nextDueDate).inDays);

    if (!_isDateTimeAdditionAllowed(
      reviewTime,
      scheduledDayDiffDuration + streakKnownDuration,
    )) {
      return _upperLimitDateTime;
    }

    return reviewTime.add(streakKnownDuration).add(scheduledDayDiffDuration);
  } else if (confidence == Confidence.unknown) {
    // Diverge from SM2 Algorithm. Instead of starting from the beginning,
    // after the card was not known, learning time is reduced to 40% of the
    // last.
    final hasEverBeenReviewed = lastReviewDate != null;
    final daysLastTime = hasEverBeenReviewed
        ? nextDueDate.difference(lastReviewDate!).inDays
        : 0;

    return reviewTime.add(Duration(days: (daysLastTime * 0.4).round()));
  } else {
    throw ArgumentError('Unrecognized state of confidence occured.');
  }
}

/// Checks whether the addition of the [duration] to [dateTime] throws an
/// ArgumentError.
///
/// Prevents that ArgumentErrors are thrown, when DateTime is out of range.
bool _isDateTimeAdditionAllowed(DateTime dateTime, Duration duration) {
  if (duration.isNegative || duration.inDays > _upperDaysInDurationLimit) {
    return false;
  }
  final sumOfMillisecondsSinceEpoch =
      dateTime.millisecondsSinceEpoch + duration.inMilliseconds;

  return sumOfMillisecondsSinceEpoch <
      _upperLimitDateTime.millisecondsSinceEpoch;
}

double _getUpdatedEase(Confidence confidence, double ease) {
  // Removes inaccuracies from calculating with floating point numbers.
  // Method comes from https://stackoverflow.com/a/32205216/6169345.
  double toDoubleWithFixed(int fractionDigits, double n) =>
      double.parse(n.toStringAsFixed(fractionDigits));

  // Diverge from SM-2 algorithm, as there are currently only KNOWN and UNKNOWN.
  // The original SM2 algorithm has the parameter quality, which indicates from
  // 0 - 5 how well the user knew the answer. The calculation of the ease value
  // would look like this in the original SM2 algorithm:
  // newEase = ease + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
  // KNOWN corresponds to a quality of 5 and UNKNOWN to ~2.
  final newEase = ease + (confidence == Confidence.known ? 0.1 : -0.3);

  return toDoubleWithFixed(2, newEase.clamp(1.3, 2.5).toDouble());
}
