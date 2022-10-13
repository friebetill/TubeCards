import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';

/// The widget that displays a dialog that allows the user to select a number.
class NumberPicker extends StatefulWidget {
  /// Creates an instance of [NumberPicker].
  const NumberPicker({
    required this.title,
    this.explanation,
    this.min = 1,
    this.max = 200,
    int? initialValue,
    this.hasOffOption = false,
    this.offValue = -1,
    Key? key,
  })  : initialValue = initialValue ?? min,
        super(key: key);

  /// The title of the dialogue.
  final String title;

  /// The explanation of the dialogue.
  final String? explanation;

  /// The minimum value that can be selected with this widget.
  final int min;

  /// The maximum value that can be selected with this widget.
  final int max;

  /// The initial value, defaults to [min].
  final int initialValue;

  /// Whether there is at the start of the list a selection for 'Off'.
  final bool hasOffOption;

  /// The value that will be returned if the 'Off' option is selected.
  final int offValue;

  @override
  NumberPickerState createState() => NumberPickerState();
}

class NumberPickerState extends State<NumberPicker> {
  late int _selectedIndex;
  late int _offOffset;

  @override
  void initState() {
    super.initState();
    _offOffset = widget.hasOffOption ? 1 : 0;
    _selectedIndex = widget.initialValue == widget.offValue
        ? 0
        : _valueToIndex(widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.bodyText2!.color,
          ),
          onPressed: _handleCancel,
          child: Text(S.of(context).cancel.toUpperCase()),
        ),
        TextButton(
          onPressed: _handleOk,
          child: Text(S.of(context).ok.toUpperCase()),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.explanation != null) Text(widget.explanation!),
          SizedBox(
            height: 150,
            child: CupertinoPicker(
              itemExtent: 28,
              onSelectedItemChanged: (index) => _selectedIndex = index,
              scrollController: FixedExtentScrollController(
                initialItem: _selectedIndex,
              ),
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                background: ElevationOverlay.overlayColor(context, 4),
              ),
              children: _buildNumberList(),
            ),
          ),
        ],
      ),
    );
  }

  int _valueToIndex(int value) => value - widget.min + _offOffset;

  int _indexToValue(int index) {
    if (widget.hasOffOption && index == 0) {
      return widget.offValue;
    }

    return index + widget.min - _offOffset;
  }

  void _handleOk() => Navigator.pop(context, _indexToValue(_selectedIndex));

  void _handleCancel() => Navigator.pop(context);

  List<Widget> _buildNumberList() {
    final textStyle = TextStyle(
      fontSize: 20,
      color: Theme.of(context).textTheme.bodyText2!.color,
    );
    final numbers = List<Widget>.generate(widget.max + 1 - widget.min, (index) {
      return Center(
        child: Text((widget.min + index).toString(), style: textStyle),
      );
    });
    if (widget.hasOffOption) {
      numbers.insert(
        0,
        Center(child: Text(S.of(context).off, style: textStyle)),
      );
    }

    return numbers;
  }
}
