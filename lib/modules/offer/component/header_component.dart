import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../i18n/i18n.dart';
import '../../../main.dart';
import '../../../utils/responsiveness/breakpoints.dart';
import '../../../widgets/image_placeholder.dart';

class HeaderComponent extends StatelessWidget {
  const HeaderComponent({
    required this.deckName,
    required this.coverImageUrl,
    this.totalRatings = 0,
    this.averageRating,
    this.button,
    Key? key,
  }) : super(key: key);

  final String deckName;
  final String coverImageUrl;
  final int totalRatings;
  final double? averageRating;
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: Row(
        children: [
          SizedBox(width: 128, child: _buildCoverImage(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDeckName(context),
                _buildRating(context),
                const Spacer(),
                if (button != null)
                  SizedBox(
                    width: Breakpoint.mobileToLarge - 32 - 128 - 12,
                    height: 40,
                    child: button!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    const placeholder = ImagePlaceholder(duration: Duration(seconds: 2));
    final imageUrl = coverImageUrl;
    final borderRadius = BorderRadius.circular(8);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
        ),
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          fadeInDuration: const Duration(milliseconds: 200),
          cacheManager: getIt<BaseCacheManager>(),
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => placeholder,
        ),
      ),
    );
  }

  Widget _buildDeckName(BuildContext context) {
    return Text(
      deckName,
      style: Theme.of(context).textTheme.headline6,
      maxLines: 2,
    );
  }

  Widget _buildRating(BuildContext context) {
    return averageRating == null
        ? Text(
            S.of(context).noRating,
            style: Theme.of(context).textTheme.bodyText2,
          )
        : Row(
            textBaseline: TextBaseline.alphabetic,
            children: [
              RatingBarIndicator(
                rating: averageRating!,
                itemSize: 16,
                itemBuilder: (_, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${averageRating!.toStringAsFixed(1)} ($totalRatings)',
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Theme.of(context).textTheme.headline4!.color,
                    ),
              ),
            ],
          );
  }
}
