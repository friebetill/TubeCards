import 'package:flutter/material.dart' hide Card;
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import '../../../../data/models/card.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/card_utils.dart';
import '../../../../utils/custom_markdown_body.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../../../home/component/utils/error_indicator.dart';
import '../../../search/sticky_header_list.dart';
import '../../../upsert_card/upsert_card_page.dart';
import 'card_search_bloc.dart';
import 'card_search_view_model.dart';

/// This delegate defines the content of the card search page.
class CardSearchDelegate extends SearchDelegate {
  /// Returns a new [CardSearchDelegate] instance.
  CardSearchDelegate({required this.deckId});

  /// ID of the deck that will be searched.
  final String deckId;

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

        if (viewModel.cardConnection == null) {
          return const Center(
            child: SizedBox(
              height: 72,
              width: 72,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (viewModel.cardConnection!.totalCount == 0) {
          return _buildNoResults(context);
        }
        final cardWidgets = viewModel.cardConnection!.nodes!
            .map((c) => _buildCardTile(context, c))
            .toList();

        if (viewModel.cardConnection!.nodes!.length <
            viewModel.cardConnection!.totalCount!) {
          cardWidgets.add(const SizedBox(
            // Height of the ListTile is 72.
            height: 72,
            width: 200,
            child: Center(child: CircularProgressIndicator()),
          ));
        }

        return LazyLoadScrollView(
          onEndOfPage: viewModel.fetchMoreCards,
          scrollOffset: 400,
          child: ListView(
            children: [
              StickyHeaderList(
                title:
                    S.of(context).cards(viewModel.cardConnection!.totalCount),
                children: cardWidgets,
              ),
            ],
          ),
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
    required Widget Function(CardSearchViewModel) builder,
  }) {
    return Component<CardSearchBloc>(
      key: const ValueKey('CardSearchComponent'),
      createViewModel: (bloc) => bloc.createViewModel(deckId),
      builder: (context, bloc) {
        return StreamBuilder<CardSearchViewModel>(
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

  Widget _buildCardTile(BuildContext context, Card card) {
    return ListTileAdapter(
      child: ListTile(
        title: CustomMarkdownBody(
          // The text fades out to the bottom if there is a linebreak before the
          // end of line is reached. To prevent this we remove the linebreak.
          data: getPreview(card.front!).split('\n').first,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        subtitle: Text(card.deck!.name!),
        onTap: () => CustomNavigator.getInstance().pushNamed(
          UpsertCardPage.routeNameAdd,
          args: UpsertCardArguments(deckId: card.deck!.id!, cardId: card.id),
        ),
      ),
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
