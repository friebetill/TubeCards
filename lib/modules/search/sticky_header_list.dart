import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';

/// List that has a sticky header at the top.
class StickyHeaderList extends StatelessWidget {
  /// Returns an instance of [StickyHeaderList].
  const StickyHeaderList({
    required this.title,
    required this.children,
    Key? key,
  }) : super(key: key);

  /// Children that are displayed below the sticky header.
  final List<Widget> children;

  /// The title displayed at the top of the list
  final String title;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Container();
    }

    final headerColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.grey.shade600;

    return StickyHeader(
      header: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: headerColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Column(
        children: children,
      ),
    );
  }
}
