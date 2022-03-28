import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../widgets/component/component.dart';
import '../../../home/component/utils/error_indicator.dart';
import '../card_item/card_item_component.dart';
import 'card_item_list_bloc.dart';
import 'card_item_list_view_model.dart';

class CardItemListComponent extends StatelessWidget {
  const CardItemListComponent({
    required this.deckId,
    required this.scrollController,
    required this.showAddCardButtonPadding,
    Key? key,
  }) : super(key: key);

  final String deckId;
  final ScrollController scrollController;

  /// True if padding for the "Add Card" FAB should be displayed
  ///
  /// Necessary because we need to know this before the view model is loaded.
  final bool showAddCardButtonPadding;

  @override
  Widget build(BuildContext context) {
    return Component<CardItemListBloc>(
      createViewModel: (bloc) => bloc.createViewModel(deckId),
      builder: (context, bloc) {
        return StreamBuilder<CardItemListViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorIndicator(snapshot.error!, showImage: false),
              );
            }
            if (!snapshot.hasData ||
                (snapshot.hasData &&
                    snapshot.data!.showInitialLoadingIndicator)) {
              return _LoadingIndicator(
                showAddCardButtonPadding: showAddCardButtonPadding,
              );
            }

            return snapshot.data!.cards.isEmpty
                ? _EmptyCardItemListView(
                    showAddCardButtonPadding: showAddCardButtonPadding,
                  )
                : _CardItemListView(
                    snapshot.data!,
                    scrollController,
                    showAddCardButtonPadding: showAddCardButtonPadding,
                  );
          },
        );
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({required this.showAddCardButtonPadding});

  final bool showAddCardButtonPadding;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        children: [
          const Spacer(),
          const CircularProgressIndicator(),
          const Spacer(),
          if (showAddCardButtonPadding)
            // Size of extended floating action button + padding
            const SizedBox(height: 48.0 + 16),
        ],
      ),
    );
  }
}

class _EmptyCardItemListView extends StatelessWidget {
  const _EmptyCardItemListView({required this.showAddCardButtonPadding});

  final bool showAddCardButtonPadding;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        children: [
          const Spacer(),
          Text(
            S.of(context).aFreshStart,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context).emptyCardListSubtitleText,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          const Spacer(),
          if (showAddCardButtonPadding)
            // Size of extended floating action button + padding
            const SizedBox(height: 48.0 + 16),
        ],
      ),
    );
  }
}

class _CardItemListView extends StatefulWidget {
  const _CardItemListView(
    this.viewModel,
    this.scrollController, {
    required this.showAddCardButtonPadding,
    Key? key,
  }) : super(key: key);

  final CardItemListViewModel viewModel;
  final ScrollController scrollController;
  final bool showAddCardButtonPadding;

  @override
  _CardItemListViewState createState() => _CardItemListViewState();
}

class _CardItemListViewState extends State<_CardItemListView> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.extentAfter < 50) {
        widget.viewModel.fetchMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int? getChildIndexFromKey(Key key) {
      final index = widget.viewModel.cards
          .indexWhere((c) => ValueKey('card-item-${c.id}-hero') == key);

      return index == -1 ? null : index;
    }

    final loadingIndicatorOffset =
        widget.viewModel.showContinuationsLoadingIndicator ? 1 : 0;
    final addCardButtonOffset = widget.showAddCardButtonPadding ? 1 : 0;

    return SliverFixedExtentList(
      delegate: SliverChildBuilderDelegate(
        _buildItem,
        childCount: widget.viewModel.cards.length +
            loadingIndicatorOffset +
            addCardButtonOffset,
        findChildIndexCallback: getChildIndexFromKey,
      ),
      // Height of the CardItem is 72.
      itemExtent: 72,
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    if (widget.viewModel.showContinuationsLoadingIndicator &&
        index == widget.viewModel.cards.length) {
      return const SizedBox(
        // Height of the CardItem is 72.
        height: 72,
        width: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.showAddCardButtonPadding &&
        index >= widget.viewModel.cards.length) {
      return const SizedBox(
        // Height of the CardItem is 72.
        height: 72,
        width: 200,
      );
    }

    final key = 'card-item-${widget.viewModel.cards[index].id}';

    return Hero(
      key: ValueKey('$key-hero'),
      tag: '$key-hero',
      child: CardItemComponent(
        card: widget.viewModel.cards[index],
        key: ValueKey(key),
      ),
    );
  }
}
