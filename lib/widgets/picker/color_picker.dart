import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as cp;

import '../../i18n/i18n.dart';
import '../../utils/custom_navigator.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    required this.initialColor,
    this.suggestionColors,
    Key? key,
  }) : super(key: key);

  /// The initially selected color.
  final Color initialColor;

  /// The color suggestions under the color picker.
  final List<Color>? suggestionColors;

  @override
  State<StatefulWidget> createState() => ColorPickerState();
}

class ColorPickerState extends State<ColorPicker> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).pickAColor),
      content: SizedBox(
        width: 300,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            cp.ColorPicker(
              pickerColor: _color,
              onColorChanged: (color) => _color = color,
              labelTypes: const [],
              portraitOnly: true,
              pickerAreaHeightPercent: 0.8,
            ),
            if (widget.suggestionColors != null) _buildSuggestionColors(),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.bodyText2!.color,
          ),
          onPressed: CustomNavigator.getInstance().pop,
          child: Text(S.of(context).cancel.toUpperCase()),
        ),
        TextButton(
          onPressed: () => CustomNavigator.getInstance().pop(_color),
          child: Text(S.of(context).setColor.toUpperCase()),
        ),
      ],
    );
  }

  Widget _buildSuggestionColors() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: widget.suggestionColors!
          .map((c) => _CircleButton(
                color: c,
                onTap: () => CustomNavigator.getInstance().pop(c),
              ))
          .toList(),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.onTap, required this.color, Key? key})
      : super(key: key);

  final GestureTapCallback onTap;

  final Color color;

  @override
  Widget build(BuildContext context) {
    const size = 32.0;

    return InkResponse(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
