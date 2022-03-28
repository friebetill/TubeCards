import 'package:flutter/material.dart';

const BottomSheetThemeData bottomSheetTheme = BottomSheetThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
    ),
  ),
  elevation: 4,
  modalElevation: 4,
);
