import 'package:flutter/material.dart';

class SearchStatus extends StatelessWidget {
  const SearchStatus(
    this.text,
    this.iconData, {
    Key? key,
  }) : super(key: key);

  final String text;

  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(iconData, color: iconColor, size: 128),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(color: Theme.of(context).hintColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
