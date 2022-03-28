import 'package:flutter/widgets.dart';

List<Widget> joinWidgets(List<Widget> widgets, {required Widget separator}) {
  final joinedList = <Widget>[];

  for (var i = 0; i < widgets.length; ++i) {
    joinedList.add(widgets[i]);

    if (i < widgets.length - 1) {
      joinedList.add(separator);
    }
  }

  return joinedList;
}
