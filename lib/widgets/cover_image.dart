import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:uuid/uuid.dart';

import '../data/models/unsplash_image.dart';
import '../i18n/i18n.dart';
import '../main.dart';
import '../modules/unsplash_image_search/unsplash_image_search_delegate.dart';
import '../services/image_search_services/unsplash/unsplash_image_search_result_item.dart';
import 'image_placeholder.dart';
import 'scalable_widgets/horizontal_scalable_box.dart';

/// Cover image for a deck.
class CoverImage extends StatefulWidget {
  const CoverImage({
    required this.imageUrl,
    this.tag,
    this.borderRadius = BorderRadius.zero,
    this.onCoverImageChange,
    this.minHeight = 140,
    Key? key,
  }) : super(key: key);

  /// Url to the image that should be displayed.
  ///
  /// The url can also link to a local file.
  final String? imageUrl;

  /// Tag used to identify the cover image for hero transitions.
  final String? tag;

  /// Border radius applied to the cover image.
  ///
  /// Defaults to [BorderRadius.zero] in case no border radius is provided.
  final BorderRadius borderRadius;

  /// Callback that is called when the user has changed the image.
  ///
  /// If no callback is given, the image is not editable.
  final ValueChanged<UnsplashImage>? onCoverImageChange;

  /// The minimum size of the image
  ///
  /// Depending on the widget width, a height is added to the minimum height.
  final int minHeight;

  @override
  CoverImageState createState() => CoverImageState();
}

class CoverImageState extends State<CoverImage> {
  late String? imageUrl;
  late String tag;

  @override
  void initState() {
    super.initState();
    imageUrl = widget.imageUrl;
    tag = widget.tag ?? const Uuid().v4();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        _buildImage(),
        if (widget.onCoverImageChange != null)
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildEditOverlay(),
          ),
      ],
    );
  }

  @override
  void didUpdateWidget(CoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.imageUrl != oldWidget.imageUrl) {
      setState(() => imageUrl = widget.imageUrl);
    }
  }

  Widget _buildImage() {
    const placeHolder = ImagePlaceholder(duration: Duration(seconds: 2));

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Hero(
        tag: tag,
        child: HorizontalScalableBox(
          minHeight: widget.minHeight,
          child: imageUrl != null
              ? GestureDetector(
                  onTap: widget.onCoverImageChange != null ? onPickImage : null,
                  child: CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 200),
                    cacheManager: getIt<BaseCacheManager>(),
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => placeHolder,
                  ),
                )
              : placeHolder,
        ),
      ),
    );
  }

  Widget _buildEditOverlay() {
    return TextButton(
      style: TextButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: Colors.black26,
        foregroundColor: Colors.white,
      ),
      onPressed: onPickImage,
      child: Text(S.of(context).changeImage.toUpperCase()),
    );
  }

  Future<void> onPickImage() async {
    final pickedImage = await showSearch<UnsplashImageSearchResultItem?>(
      context: context,
      delegate: UnsplashImageSearchDelegate(),
    );

    // Do not update the cover in case the user didn't select a photo.
    if (pickedImage == null) {
      return;
    }

    setState(() => imageUrl = pickedImage.regularUrl!);
    widget.onCoverImageChange!(
      UnsplashImage.fromUnsplashSearchResultItem(pickedImage),
    );
  }
}
