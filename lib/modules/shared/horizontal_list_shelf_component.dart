import 'package:flutter/material.dart';

@immutable
class HorizontalListShelfComponent extends StatelessWidget {
  const HorizontalListShelfComponent({
    required this.children,
    required this.title,
    this.button,
    Key? key,
  }) : super(key: key);

  final List<Widget> children;
  final String title;
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // Always ensure a height of 48dp which matches the height of the
          // optional button.
          height: 48,
          // Compensate for the button padding at the end.
          padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
              if (button != null) button!,
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Use instead of ListBuilder since we don't want to make assumptions
        // about the height of the children widgets.
        SingleChildScrollView(
          // Make sure items are not clipped when there is horizontal space left
          // next to the last item and the user scrolls.
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _joinWithPadding(children),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _joinWithPadding(List<Widget> widgets) {
    final result = <Widget>[];

    for (var i = 0; i < widgets.length; ++i) {
      result.add(widgets[i]);

      if (i < widgets.length - 1) {
        result.add(const SizedBox(width: 8));
      }
    }

    return result;
  }
}
