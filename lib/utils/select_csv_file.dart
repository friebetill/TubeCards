import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../../i18n/i18n.dart';
import 'snackbar.dart';

Future<String?> selectCSVFile(BuildContext context) async {
  final i18n = S.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final theme = Theme.of(context);

  String? filePath;
  final result = await FilePicker.platform.pickFiles(
    dialogTitle: S.of(context).pickACSVFile,
  );

  if (result == null) {
    return null;
  } else if (extension(result.files.first.path!) == '.csv') {
    filePath = result.files.first.path;
  } else if (result.files.length > 1) {
    // We allow only one file to be selected. If the result consists of several
    // files, it means that the file contains special characters, e.g. commas.
    // Unfortunately, the file name cannot be reassembled automatically, so we
    // have to show an error message to the user.
    messenger.showErrorSnackBar(
      theme: theme,
      text: i18n.errorFileSpecialCharactersText,
    );
  } else {
    messenger.showErrorSnackBar(
      theme: theme,
      text: i18n.errorSelectExtensionText('.csv'),
    );
  }

  return filePath;
}
