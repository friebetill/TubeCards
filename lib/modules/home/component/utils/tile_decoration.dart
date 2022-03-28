import 'package:flutter/material.dart';

class TileDecoration extends StatelessWidget {
  const TileDecoration({
    required this.child,
    this.background,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final Gradient? background;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: background),
        child: child,
      ),
    );
  }
}
