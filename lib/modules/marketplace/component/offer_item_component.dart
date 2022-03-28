import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../data/models/offer.dart';
import '../../../i18n/i18n.dart';
import '../../../main.dart';
import '../../../widgets/image_placeholder.dart';

@immutable
class OfferItemComponent extends StatelessWidget {
  const OfferItemComponent({required this.offer, required this.onTap, Key? key})
      : super(key: key);

  final Offer offer;
  final VoidCallback onTap;

  // The height is measured.
  static const double height = 144;

  static const double _maxWidth = 112;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context),
            const SizedBox(height: 4),
            _buildTitle(context),
            _buildRating(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    const placeholder = ImagePlaceholder(duration: Duration(seconds: 2));
    final imageUrl = offer.deck!.coverImage!.regularUrl;
    final borderRadius = BorderRadius.circular(8);

    return Container(
      width: _maxWidth,
      height: _maxWidth,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
        ),
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: imageUrl != null
            ? CachedNetworkImage(
                fadeInDuration: const Duration(milliseconds: 200),
                cacheManager: getIt<BaseCacheManager>(),
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => placeholder,
              )
            : placeholder,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return SizedBox(
      width: _maxWidth,
      child: Text(
        offer.deck!.name!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.caption?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildRating(BuildContext context) {
    final ratingCount = offer.reviewSummary!.totalCount!;
    final textStyle = Theme.of(context).textTheme.caption;

    if (ratingCount == 0) {
      return Text(S.of(context).noRatings, style: textStyle);
    }

    final truncatedAvgRating =
        offer.reviewSummary!.averageRating!.toStringAsFixed(1);

    return Row(
      children: [
        Icon(
          Icons.star,
          color: Colors.yellow.shade800,
          size: 13,
        ),
        const SizedBox(width: 2),
        Text(
          '$truncatedAvgRating ($ratingCount)',
          style: textStyle,
        ),
      ],
    );
  }
}
