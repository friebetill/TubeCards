import 'package:flutter/material.dart';

class BottomNavigationButton extends StatelessWidget {
  const BottomNavigationButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).iconTheme.color;
    final labelStyle =
        Theme.of(context).textTheme.bodyText2!.copyWith(color: color);

    return InkResponse(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          Text(label, style: labelStyle),
        ],
      ),
    );
  }
}
