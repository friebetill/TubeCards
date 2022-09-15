import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../modules/draw_image/draw_image_page.dart';
import '../../modules/interactiv_image/interactive_image_page.dart';
import '../../utils/custom_navigator.dart';
import '../../utils/socket_exception_extension.dart';
import 'editor_utils.dart';

final _logger = Logger((EmbedImageBuilder).toString());

class EmbedImageBuilder implements EmbedBuilder {
  @override
  String get key => BlockEmbed.imageType;

  /// Builds a widget for the given image embed.
  ///
  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed embed,
    bool readOnly,
  ) {
    final imageUrl = embed.value.data as String;

    return Center(
      child: FutureBuilder<File>(
        // The key is important so that the same FutureBuilder is not used for
        // two cards. Otherwise an exception can occur if for example a png
        // image was shown on the first page and an svg image on the second.
        // In this case the png image could be displayed for a moment in the
        // SVGPicture and a decoding error occurs.
        key: ValueKey(imageUrl),
        future: getIt<BaseCacheManager>().getSingleFile(imageUrl),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            _handleError(snapshot.error!, snapshot.stackTrace!, imageUrl);

            return const Icon(Icons.error_outlined);
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              // In case the card is read-only, a long-press will open the image
              // in a fullscreen mode whereas a single tap will open the image
              // editor.
              //
              // This allows the card to be flipped in read-only mode with a
              // single tap on the image.
              onTap: readOnly
                  ? null
                  : () => _openImageEditor(imageUrl, controller),
              onLongPress: readOnly ? () => _openAsFullscreen(imageUrl) : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                // Disable the Hero widget until the cards are clickable again
                // and the tag is more specific, so the same image can be
                // displayed on multiple cards. This is important for the offer
                // page. child: Hero( tag: '$imageUrl-hero',
                child: Container(
                  // Always color the SVG background white, even in dark mode.
                  color: Colors.white,
                  child: imageUrl.endsWith('svg')
                      ? SvgPicture.file(snapshot.data!)
                      : Image.file(snapshot.data!),
                ),
                // ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openAsFullscreen(String imageUrl) {
    CustomNavigator.getInstance()
        .pushNamed(InteractiveImagePage.routeName, args: imageUrl);
  }

  Future<void> _openImageEditor(
    String imageUrl,
    QuillController controller,
  ) async {
    final imageBytes = await CustomNavigator.getInstance()
        .pushNamed<Uint8List>(DrawImagePage.routeName, args: imageUrl);
    if (imageBytes == null) {
      return;
    }

    const fileExtension = 'png';
    final uriPath = buildUriPath('${const Uuid().v1()}.$fileExtension');

    await getIt<BaseCacheManager>().putFile(
      uriPath,
      imageBytes,
      fileExtension: fileExtension,
    );

    var position = 0;
    for (final operation in controller.document.toDelta().toList()) {
      if (operation.isInsert &&
          operation.data is Map &&
          // ignore: cast_nullable_to_non_nullable
          (operation.data as Map)[BlockEmbed.imageType] == imageUrl) {
        controller.replaceText(position, 1, BlockEmbed.image(uriPath), null);
      }

      position += operation.length!;
    }
  }

  void _handleError(Object error, StackTrace stackTrace, String imageUrl) {
    if (error is SocketException &&
        (error.isNoInternet || error.isServerOffline)) {
      return;
    }
    _logger.severe(
      'Unexpected exception when the image $imageUrl was shown.',
      error,
      stackTrace,
    );
  }
}
