import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../i18n/i18n.dart';
import '../../utils/custom_navigator.dart';

class TextSizePicker extends StatefulWidget {
  const TextSizePicker({required this.initialSize, Key? key}) : super(key: key);

  /// The initially selected size.
  final double initialSize;

  @override
  State<StatefulWidget> createState() => TextSizePickerState();
}

class TextSizePickerState extends State<TextSizePicker> {
  late double _size;

  @override
  void initState() {
    super.initState();
    _size = widget.initialSize;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).pickTextSize),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildPreview(),
            _buildSlider(),
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
          onPressed: () => CustomNavigator.getInstance().pop(_size),
          child: Text(S.of(context).setSize.toUpperCase()),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          S.of(context).size,
          style: TextStyle(fontSize: _size, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Padding(
      // The padding is needed, otherwise the label will overlap with the
      // preview.
      padding: const EdgeInsets.only(top: 40),
      child: Slider(
        value: _size,
        onChanged: (value) {
          HapticFeedback.selectionClick();
          setState(() => _size = value);
        },
        min: 6,
        max: 40,
        label: _size.toStringAsFixed(0),
        divisions: 19,
      ),
    );
  }
}
