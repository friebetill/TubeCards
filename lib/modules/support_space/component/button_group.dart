import 'package:flutter/material.dart';

class ButtonGroup extends StatelessWidget {
  const ButtonGroup({
    required this.current,
    required this.titles,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    Key? key,
  }) : super(key: key);

  static const double _radius = 10;

  final int current;
  final List<String?> titles;
  final ValueChanged<int> onTap;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activeColor,
      borderRadius: BorderRadius.circular(_radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _buttonList(context),
        ),
      ),
    );
  }

  List<Widget> _buttonList(BuildContext context) {
    final buttons = <Widget>[];
    for (var i = 0; i < titles.length; i++) {
      if (titles[i] == null) {
        continue;
      }

      buttons
        ..add(_button(i, context))
        ..add(
          VerticalDivider(
            width: 1,
            color: (i == current || i + 1 == current)
                ? activeColor
                : inactiveColor,
            thickness: 1.5,
            indent: 5,
            endIndent: 5,
          ),
        );
    }
    buttons.removeLast();

    return buttons;
  }

  Widget _button(int index, BuildContext context) {
    return index == current
        ? _activeButton(index)
        : _inActiveButton(index, context);
  }

  Widget _activeButton(int index) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: inactiveColor,
        backgroundColor: activeColor,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const RoundedRectangleBorder(),
      ),
      onPressed: () => onTap(index),
      child: Text(titles[index]!.toUpperCase()),
    );
  }

  Widget _inActiveButton(int index, BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).disabledColor,
        backgroundColor: inactiveColor,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const RoundedRectangleBorder(),
      ),
      onPressed: () => onTap(index),
      child: Text(titles[index]!.toUpperCase()),
    );
  }
}
