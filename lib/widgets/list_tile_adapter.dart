import 'package:flutter/material.dart';

/// An adapter used to wrap a [ListTile] or variants of it.
///
/// The adapter is used to dynamically style list tiles (e.g. adding a border
/// radius).
class ListTileAdapter extends StatelessWidget {
  /// Returns a new [ListTileAdapter] instance.
  const ListTileAdapter({
    required this.child,
    this.backgroundColor = Colors.transparent,
    Key? key,
  }) : super(key: key);

  /// The child that is wrapped with this adapter.
  ///
  /// Usually a [ListTile] or a variant of it is used.
  final Widget child;

  /// The background color of the list tile.
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
