import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../widgets/list_tile_adapter.dart';
import '../weekday.dart';

/// The widget that displays a dialog that allows the user to select weekdays.
class WeekdayPicker extends StatefulWidget {
  /// Creates an instance of [WeekdayPicker].
  const WeekdayPicker({required this.weekdayStates, Key? key})
      : super(key: key);

  /// The initial settings for the weekdays.
  final Map<Weekday, bool> weekdayStates;

  @override
  WeekdayPickerState createState() => WeekdayPickerState();
}

class WeekdayPickerState extends State<WeekdayPicker> {
  late Map<Weekday, bool> weekdayStates;

  @override
  void initState() {
    super.initState();
    weekdayStates = widget.weekdayStates;
  }

  bool _isMoreThanOneWeekdayEnabled() {
    return weekdayStates.values.where((v) => v).length > 1;
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    Navigator.pop(context, weekdayStates);
  }

  @override
  Widget build(BuildContext context) {
    final sortedWeekdayStates = weekdayStates.keys.toList()
      ..sort((w1, w2) => w1.value.compareTo(w2.value));

    return AlertDialog(
      title: Text(S.of(context).repeatWeeklyOn),
      actions: <Widget>[
        TextButton(
          onPressed: _handleCancel,
          child: Text(
            S.of(context).cancel.toUpperCase(),
            style: Theme.of(context).textTheme.button,
          ),
        ),
        TextButton(
          onPressed: _handleOk,
          child: Text(S.of(context).ok.toUpperCase()),
        ),
      ],
      content: SizedBox(
        /// A width is required see https://stackoverflow.com/a/56355962/6169345
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: sortedWeekdayStates.length,
          itemBuilder: (context, index) {
            return ListTileAdapter(
              child: CheckboxListTile(
                title: Text(sortedWeekdayStates[index].toLocaleString(context)),
                checkColor: Theme.of(context).colorScheme.onPrimary,
                value: weekdayStates[sortedWeekdayStates[index]],
                dense: true,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  if (_isMoreThanOneWeekdayEnabled() || value) {
                    setState(() {
                      weekdayStates[sortedWeekdayStates[index]] = value;
                    });
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
