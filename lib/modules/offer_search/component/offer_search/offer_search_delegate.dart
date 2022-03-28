import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import '../../../../data/models/offer.dart';
import '../../../../data/models/review_summary.dart';
import '../../../../i18n/i18n.dart';
import '../../../../main.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../../../../widgets/visual_element.dart';
import '../../../home/component/utils/error_indicator.dart';
import '../../../offer/offer_page.dart';
import 'offer_search_bloc.dart';
import 'offer_search_view_model.dart';

/// This delegate defines the content of the offer search page.
class OfferSearchDelegate extends SearchDelegate {
  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(
      key: const ValueKey('back-button'),
      onPressed: () => close(context, null),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_outlined),
        onPressed: () => query = '',
        tooltip: S.of(context).clearQuery,
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildComponent(
      builder: (viewModel) {
        if (query.isEmpty) {
          return Container();
        }

        viewModel.addSearchTerm(query);

        if (viewModel.offerConnection == null) {
          return const Center(
            child: SizedBox(
              height: 72,
              width: 72,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (viewModel.offerConnection!.totalCount == 0) {
          return _buildNoResults(context);
        }
        final offerTiles = viewModel.offerConnection!.nodes!
            .map((o) => _buildOfferTile(context, o))
            .toList();

        if (viewModel.offerConnection!.nodes!.length <
            viewModel.offerConnection!.totalCount!) {
          offerTiles.add(const SizedBox(
            // Height of the ListTile is 72.
            height: 72,
            width: 200,
            child: Center(child: CircularProgressIndicator()),
          ));
        }

        return LazyLoadScrollView(
          onEndOfPage: viewModel.fetchMoreOffers,
          scrollOffset: 400,
          child: ListView(children: offerTiles),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildComponent(
      builder: (viewModel) {
        return ListView(
          children: viewModel.recentSearchTerms
              .map((st) => _buildRecentSearchTermTile(context, st))
              .toList(),
        );
      },
    );
  }

  Widget _buildComponent({
    required Widget Function(OfferSearchViewModel) builder,
  }) {
    return Component<OfferSearchBloc>(
      key: const ValueKey('OfferSearchComponent'),
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<OfferSearchViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: ErrorIndicator(snapshot.error!));
            }
            if (snapshot.data == null) {
              return Container();
            }

            return builder(snapshot.data!);
          },
        );
      },
    );
  }

  Widget _buildNoResults(BuildContext context) {
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.grey.shade300;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.assignment_outlined,
            color: iconColor,
            size: 128,
          ),
          Text(
            S.of(context).noResultsFound,
            style: TextStyle(
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOfferTile(BuildContext context, Offer offer) {
    return VisualElement(
      id: VEs.offerTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: ListTile(
            leading: SizedBox(
              height: 52,
              width: 52,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  fadeInDuration: const Duration(milliseconds: 200),
                  cacheManager: getIt<BaseCacheManager>(),
                  imageUrl: offer.deck!.coverImage!.regularUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(offer.deck!.name!),
            subtitle: Row(
              children: [
                _buildRating(context, offer.reviewSummary!),
                const Text(' · '),
                Text(
                  S
                      .of(context)
                      .numberOfCards(offer.deck!.cardConnection!.totalCount),
                ),
              ],
            ),
            onTap: () {
              controller.logTap();
              CustomNavigator.getInstance().pushNamed(
                OfferPage.routeName,
                args: offer.id,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRating(BuildContext context, ReviewSummary reviewSummary) {
    return reviewSummary.averageRating == null
        ? Text(
            S.of(context).noRating,
          )
        : Row(
            textBaseline: TextBaseline.alphabetic,
            children: [
              RatingBarIndicator(
                rating: reviewSummary.averageRating!,
                itemSize: 16,
                itemBuilder: (_, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${reviewSummary.averageRating!.toStringAsFixed(1)} '
                '(${reviewSummary.totalCount})',
              ),
            ],
          );
  }

  Widget _buildRecentSearchTermTile(BuildContext context, String searchTerm) {
    return ListTileAdapter(
      child: ListTile(
        title: Text(
          searchTerm,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: const Icon(Icons.access_time_outlined),
        onTap: () {
          query = searchTerm;
          showResults(context);
        },
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);
}
