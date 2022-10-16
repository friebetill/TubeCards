import 'package:test/test.dart';
import 'package:tubecards/data/models/confidence.dart';
import 'package:tubecards/utils/sm2.dart' as sm2;

void main() {
  test(
    'Returns next day as the due date when card is known at first review',
    () {
      final dueDate = DateTime.utc(2000);
      const confidence = Confidence.known;
      final reviewDate = DateTime.utc(2000);

      final sm2Result = sm2.run(
        dueDate,
        confidence,
        reviewDate: reviewDate,
        streakKnown: sm2.initialStreakKnown,
        ease: sm2.initialEase,
      );

      expect(sm2Result.dueDate, equals(DateTime.utc(2000, 1, 2)));
    },
  );

  test('Returns same day as due date when card is unknown at first review', () {
    final dueDate = DateTime.utc(2000);
    const confidence = Confidence.unknown;
    final reviewDate = DateTime.utc(2000);

    final sm2Result = sm2.run(
      dueDate,
      confidence,
      reviewDate: reviewDate,
      streakKnown: sm2.initialStreakKnown,
      ease: sm2.initialEase,
    );

    expect(sm2Result.dueDate, equals(DateTime.utc(2000)));
  });

  test(
    'Returns next due date in four days when card is known on second review',
    () {
      final dueDate = DateTime.utc(2000, 1, 2);
      const confidence = Confidence.known;
      final reviewDate = DateTime.utc(2000, 1, 2);
      final lastReviewDate = DateTime.utc(2000);
      const streakKnown = 1;

      final sm2Result = sm2.run(
        dueDate,
        confidence,
        streakKnown: streakKnown,
        lastReviewDate: lastReviewDate,
        reviewDate: reviewDate,
        ease: sm2.initialEase,
      );

      expect(sm2Result.dueDate, equals(DateTime.utc(2000, 1, 6)));
    },
  );

  test('Returns increased ease by 0.1 when card is known', () {
    final dueDate = DateTime.utc(2000);
    const confidence = Confidence.known;
    const ease = 2.0;

    final sm2Result = sm2.run(
      dueDate,
      confidence,
      ease: ease,
      streakKnown: sm2.initialStreakKnown,
    );

    expect(sm2Result.ease, equals(2.1));
  });

  test('Returns decreased ease by 0.3 when card is unknown', () {
    final dueDate = DateTime.utc(2000);
    const confidence = Confidence.unknown;
    const ease = 2.0;

    final sm2Result = sm2.run(
      dueDate,
      confidence,
      ease: ease,
      streakKnown: sm2.initialStreakKnown,
    );

    expect(sm2Result.ease, equals(1.7));
  });

  test('Returns maximum of 2.5 as an ease factor if the card was known.', () {
    final dueDate = DateTime.utc(2000);
    const confidence = Confidence.known;
    const ease = 2.5;

    final sm2Result = sm2.run(
      dueDate,
      confidence,
      ease: ease,
      streakKnown: sm2.initialStreakKnown,
    );

    expect(sm2Result.ease, equals(2.5));
  });

  test('Returns minimum of 1.3 as an ease factor if the card was unknown.', () {
    final dueDate = DateTime.utc(2000);
    const confidence = Confidence.unknown;
    const ease = 1.3;

    final sm2Result = sm2.run(
      dueDate,
      confidence,
      ease: ease,
      streakKnown: sm2.initialStreakKnown,
    );

    expect(sm2Result.ease, equals(1.3));
  });

  test('Returns future date when review date is much later than due date', () {
    final dueDate = DateTime.utc(2000);
    final reviewDate = DateTime.utc(2000, 5);
    const confidence = Confidence.known;

    final sm2Result = sm2.run(
      dueDate,
      confidence,
      reviewDate: reviewDate,
      ease: sm2.initialEase,
      streakKnown: sm2.initialStreakKnown,
    );

    expect(sm2Result.dueDate.isAfter(DateTime.utc(2000, 5)), isTrue);
  });

  test('Returns increased streak known when card was known', () {
    final dueDate = DateTime.utc(2000);
    const streakKnown = 0;
    const confidence = Confidence.known;

    final sm2Result = sm2.run(
      dueDate,
      confidence,
      ease: sm2.initialEase,
      streakKnown: streakKnown,
    );

    expect(sm2Result.streakKnown, equals(1));
  });

  test('Returns zero streak known when card was unknown', () {
    final dueDate = DateTime.utc(2000, 1, 10);
    final lastReviewDate = DateTime.utc(2000);
    const streakKnown = 5;

    final sm2Result = sm2.run(
      dueDate,
      Confidence.unknown,
      lastReviewDate: lastReviewDate,
      ease: sm2.initialEase,
      streakKnown: streakKnown,
    );

    expect(sm2Result.streakKnown, equals(0));
  });

  test('Returns never a date before reviewed time', () {
    sm2.SM2Result sm2Result;
    var dueDate = DateTime.utc(2000);
    var reviewDate = DateTime.utc(2000);
    DateTime? lastReviewDate;
    var streakKnown = 0;
    var ease = 2.5;

    for (var i = 0; i < 22; i++) {
      sm2Result = sm2.run(
        dueDate,
        Confidence.known,
        reviewDate: reviewDate,
        lastReviewDate: lastReviewDate,
        streakKnown: streakKnown,
        ease: ease,
      );

      lastReviewDate = reviewDate;
      dueDate = sm2Result.dueDate;
      reviewDate = sm2Result.dueDate;
      streakKnown = sm2Result.streakKnown;
      ease = sm2Result.ease;

      // From i = 21 the maximum DateTime is returned.
      expect(
        dueDate.isAfter(lastReviewDate) ||
            i == 21 && dueDate.isAtSameMomentAs(lastReviewDate),
        isTrue,
      );
    }
  });
}
