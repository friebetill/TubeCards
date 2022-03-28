import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../../../i18n/i18n.dart';
import '../../../main.dart';
import '../../../utils/card_media_handler.dart';
import '../../../utils/snackbar.dart';
import '../editor_utils.dart';

class PickImageIntent extends Intent {
  const PickImageIntent(this.context, this.controller);

  final BuildContext context;
  final QuillController controller;

  static Map<Type, Action<Intent>> getAction() {
    return {
      PickImageIntent: CallbackAction<PickImageIntent>(
        onInvoke: (i) => i.onInvoke(),
      ),
    };
  }

  Map<LogicalKeySet, Intent> getShortCut() {
    return {
      LogicalKeySet(
        Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyP,
      ): this,
    };
  }

  Future<void> onInvoke() async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    final imageUrl = await pickImage();
    if (imageUrl == null) {
      return;
    }

    final cachedImageUrl = await _storeInCacheManager(imageUrl);
    controller.replaceText(
      index,
      length,
      BlockEmbed.image(cachedImageUrl),
      null,
    );
  }

  Future<String?> pickImage() async {
    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final result = await FilePicker.platform.pickFiles(
      dialogTitle: S.of(context).pickImage,
      type: FileType.custom,
      allowedExtensions: CardMediaHandler.supportedImageFormats,
    );

    if (result == null) {
      return null;
    } else if (result.files.length > 1) {
      // We allow only one file to be selected. If the result consists of
      // several files, it means that the file contains special characters,
      // e.g. commas. Unfortunately, the file name cannot be reassembled
      // automatically, so we have to show an error message to the user.
      messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorFileSpecialCharactersText,
      );

      return null;
    }

    return result.files.first.path;
  }

  Future<String> _storeInCacheManager(String filePath) async {
    final file = File(filePath);
    final fileExtension =
        extension(file.path).toLowerCase().replaceAll('.', '');
    final uriPath = buildUriPath('${const Uuid().v1()}.$fileExtension');

    await getIt<BaseCacheManager>().putFile(
      uriPath,
      file.readAsBytesSync(),
      fileExtension: fileExtension,
    );

    return uriPath;
  }
}
