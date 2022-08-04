import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../main.dart';
import '../../services/image_search_services/image_search_result_item.dart';
import '../../utils/custom_navigator.dart';
import '../image_placeholder.dart';

class ImageSearchResultTile extends StatefulWidget {
  const ImageSearchResultTile({
    required this.item,
    required this.showThumbnail,
    Key? key,
  }) : super(key: key);

  final ImageSearchResultItem item;
  final bool showThumbnail;

  @override
  ImageSearchResultTileState createState() => ImageSearchResultTileState();
}

class ImageSearchResultTileState extends State<ImageSearchResultTile> {
  bool _isShowingImage = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(widget.item),
      onVisibilityChanged: _onVisibilityChanged,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: _isShowingImage
            ? CachedNetworkImage(
                imageUrl: widget.showThumbnail
                    ? widget.item.thumbnailUrl!
                    : widget.item.imageUrl!,
                fit: BoxFit.cover,
                cacheManager: getIt<BaseCacheManager>(),
                fadeInDuration: const Duration(milliseconds: 200),
                errorWidget: (_, __, error) => const Icon(Icons.error_outlined),
                placeholder: (_, __) => const ImagePlaceholder(),
                imageBuilder: (context, image) {
                  return GestureDetector(
                    onTap: () => CustomNavigator.getInstance().pop(widget.item),
                    child: _buildImage(image),
                  );
                },
              )
            : const ImagePlaceholder(),
      ),
    );
  }

  Widget _buildImage(ImageProvider image) {
    return ExtendedImage(
      image: image,
      fit: BoxFit.cover,
      beforePaintImage: (canvas, rect, image, paint) {
        // Needed to color the background of transparent images white.
        canvas.drawRect(rect, Paint()..color = Colors.white);

        return false;
      },
    );
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_isShowingImage || info.visibleFraction == 0) {
      return;
    }
    setState(() => _isShowingImage = true);
  }
}
