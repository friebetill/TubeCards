import 'package:flutter/widgets.dart';

// Indicates on which side of a rectangle a notch should be placed.
enum RectangleNotchSide {
  left,
  right,
}

/// A Shape which consists of a rectangle with a circular notch inset on either
/// the left or right side.
@immutable
class CircularNotchedRectangleShape extends OutlinedBorder {
  const CircularNotchedRectangleShape({
    this.notchSide,
    this.notchDiameter = defaultNotchDiameter,
  });

  /// This value corresponds to the diameter of a [FloatingActionButton].
  static const double defaultNotchDiameter = 56;

  /// Indicates on which side of the rectangle the notch should be placed.
  final RectangleNotchSide? notchSide;

  /// Diameter of the circular notch.
  final double notchDiameter;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final translationMultiplier = notchSide == RectangleNotchSide.left ? -1 : 1;
    final xTranslation =
        translationMultiplier * (rect.width / 2 + notchDiameter / 4);

    return Path.combine(
      PathOperation.difference,
      // Add a regular outer border radius to the shape.
      Path()
        ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)))
        ..close(),
      // Here the notch is added and offset to the given side.
      Path()
        ..addOval(Rect.fromCenter(
          center: rect.center.translate(xTranslation, 0),
          height: notchDiameter,
          width: notchDiameter,
        ))
        ..close(),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    /* NO-OP */
  }

  @override
  ShapeBorder scale(double t) => this;

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return CircularNotchedRectangleShape(
      notchSide: notchSide,
      notchDiameter: notchDiameter,
    );
  }
}
