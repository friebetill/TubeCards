import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../modules/azure_image_search/azure_image_search_delegate.dart';
import '../../../services/image_search_services/azure/azure_image_search_result_item.dart';

class SearchImageIntent extends Intent {
  const SearchImageIntent(this.context, this.controller);

  final BuildContext context;
  final QuillController controller;

  static Map<Type, Action<Intent>> getAction() {
    return {
      SearchImageIntent: CallbackAction<SearchImageIntent>(
        onInvoke: (i) => i.onInvoke(),
      ),
    };
  }

  Map<LogicalKeySet, Intent> getShortCut() {
    return {
      LogicalKeySet(
        Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyS,
      ): this,
    };
  }

  Future<void> onInvoke() async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;
    final imageUrl = await _getSearchImage(context);

    if (imageUrl != null) {
      controller.replaceText(
        index,
        length,
        BlockEmbed.image(imageUrl),
        null,
      );
    }
  }

  Future<String?> _getSearchImage(BuildContext context) async {
    final pickedImage = await showSearch<AzureImageSearchResultItem?>(
      context: context,
      delegate: AzureImageSearchDelegate(),
    );

    return pickedImage?.imageUrl;
  }
}
