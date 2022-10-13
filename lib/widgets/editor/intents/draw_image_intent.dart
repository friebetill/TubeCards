import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../../../main.dart';
import '../../../modules/draw_image/draw_image_page.dart';
import '../../../utils/custom_navigator.dart';
import '../editor_utils.dart';

class DrawImageIntent extends Intent {
  const DrawImageIntent(this.context, this.controller);

  final BuildContext context;
  final QuillController controller;

  static Map<Type, Action<Intent>> getAction() {
    return {
      DrawImageIntent: CallbackAction<DrawImageIntent>(
        onInvoke: (i) => i.onInvoke(),
      ),
    };
  }

  Map<LogicalKeySet, Intent> getShortCut() {
    return {
      LogicalKeySet(
        Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyD,
      ): this,
    };
  }

  Future<void> onInvoke() async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    final imageUploadUrl = await _getDoodle(context);
    if (imageUploadUrl != null) {
      controller.replaceText(
        index,
        length,
        BlockEmbed.image(imageUploadUrl),
        null,
      );
    }
  }

  Future<String?> _getDoodle(BuildContext context) async {
    final imageBytes = await CustomNavigator.getInstance()
        .pushNamed<Uint8List>(DrawImagePage.routeName);
    if (imageBytes == null) {
      return null;
    }

    const fileExtension = 'png';
    final uriPath = buildUriPath('${const Uuid().v1()}.$fileExtension');

    await getIt<BaseCacheManager>().putFile(
      uriPath,
      imageBytes,
      fileExtension: fileExtension,
    );

    return uriPath;
  }
}
