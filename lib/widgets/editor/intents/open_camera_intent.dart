import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../../../main.dart';
import '../editor_utils.dart';

class OpenCameraIntent extends Intent {
  const OpenCameraIntent();

  Future<void> onInvoke({
    required BuildContext context,
    required QuillController controller,
  }) async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    final imageUrl = await pickImage(ImageSource.camera);
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

  Future<String?> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      return pickedFile?.path;
    } on PlatformException {
      return null;
    }
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
