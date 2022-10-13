import 'package:flutter/material.dart' hide Card;

import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../utils/logging/interaction_logger.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../../../widgets/snap_list.dart';
import '../../../../widgets/visual_element.dart';
import '../../../review/component/flashcard_component.dart';
import '../creator_component.dart';
import '../header_component.dart';
import '../rate_offer/rate_offer_component.dart';
import '../review_overview_component.dart';
import 'offer_bloc.dart';
import 'offer_view_model.dart';

class OfferComponent extends StatelessWidget {
  const OfferComponent({required this.offerId, Key? key}) : super(key: key);

  final String offerId;

  @override
  Widget build(BuildContext context) {
    return Component<OfferBloc>(
      createViewModel: (bloc) => bloc.createViewModel(offerId),
      builder: (context, bloc) {
        return StreamBuilder<OfferViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SimpleSkeleton();
            }

            return _OfferView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _OfferView extends StatelessWidget {
  const _OfferView(this.viewModel);

  final OfferViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    Widget? button;
    if (viewModel.onSubscribeTap != null) {
      button = _buildSubscribeButton(context);
    } else {
      button = _buildOpenButton(context);
    }

    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: ListView(
          padding: const EdgeInsets.all(16),
          clipBehavior: Clip.none,
          children: <Widget>[
            HeaderComponent(
              deckName: viewModel.deck.name!,
              totalRatings: viewModel.offer.reviewSummary!.totalCount!,
              coverImageUrl: viewModel.deck.coverImage!.regularUrl!,
              averageRating: viewModel.offer.reviewSummary!.averageRating,
              button: button,
            ),
            const SizedBox(height: 16),
            Text(viewModel.deck.description!.isNotEmpty
                ? viewModel.deck.description!
                : S.of(context).noDescription),
            const SizedBox(height: 8),
            _buildMetadata(context),
            const SizedBox(height: 12),
            CreatorComponent(creator: viewModel.creator),
            if (viewModel.showRateOffer) ...[
              const SizedBox(height: 24),
              RateOfferComponent(offerId: viewModel.offer.id!),
            ],
            if (viewModel.offer.reviewSummary!.averageRating != null) ...[
              const SizedBox(height: 24),
              ReviewOverviewComponent(
                reviewSummary: viewModel.offer.reviewSummary!,
                reviewConnection: viewModel.offer.reviewConnection!,
              ),
            ],
            if (viewModel.offer.cardSamples!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildExamplesSection(context),
            ],
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final popupMenuItems = [
      if (viewModel.onUnsubscribeTap != null)
        PopupMenuItem<int>(
          onTap: () {
            InteractionLogger.getInstance().logTap(VEs.unsubscribeButton);
            viewModel.onUnsubscribeTap!();
          },
          child: Text(S.of(context).remove),
        ),
      if (viewModel.onDeleteOfferTap != null)
        PopupMenuItem<int>(
          onTap: () {
            InteractionLogger.getInstance().logTap(VEs.deleteOfferButton);
            viewModel.onDeleteOfferTap!();
          },
          child: Text(S.of(context).makePrivate),
        ),
    ];

    final isLoading =
        viewModel.isUnsubscribeLoading || viewModel.isDeleteLoading;

    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const BackButtonIcon(),
        onPressed: CustomNavigator.getInstance().pop,
        tooltip: backTooltip(context),
      ),
      actions: [
        if (isLoading)
          IconButton(
            icon: const IconSizedLoadingIndicator(),
            onPressed: () {},
          )
        else if (popupMenuItems.isNotEmpty && !isLoading)
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_outlined),
            itemBuilder: (_) => popupMenuItems,
          ),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return VisualElement(
      id: VEs.subscribeButton,
      childBuilder: (controller) {
        return TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(8),
          ),
          onPressed: () {
            controller.logTap();
            viewModel.onSubscribeTap!();
          },
          child: !viewModel.isSubscribeLoading
              ? Text(S.of(context).get.toUpperCase())
              : IconSizedLoadingIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
        );
      },
    );
  }

  Widget _buildOpenButton(BuildContext context) {
    return VisualElement(
      id: VEs.openDeckButton,
      childBuilder: (controller) {
        return TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(8),
          ),
          onPressed: () {
            controller.logTap();
            viewModel.onOpenTap!();
          },
          child: Text(S.of(context).open.toUpperCase()),
        );
      },
    );
  }

  Widget _buildMetadata(BuildContext context) {
    final cardsCount = viewModel.deck.cardConnection!.totalCount!;
    final subscriberCount = viewModel.offer.subscriberCount;
    return Text(
      '${viewModel.deck.cardConnection!.totalCount!} '
      '${S.of(context).cards(cardsCount).toLowerCase()}'
      ' • '
      '${S.of(context).learners(subscriberCount).toLowerCase()}',
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildExamplesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExamplesTitle(context),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: SnapList(
            // If the item is wider than 345 pixels, the next item will be
            // hidden on 360 pixel screens.
            itemWidth: 359 - 16 /* Padding */,
            paddingWidth: 16,
            itemCount: viewModel.offer.cardSamples!.length,
            itemBuilder: (_, i) {
              return FlashcardComponent(
                frontText: viewModel.offer.cardSamples![i].front!,
                backText: viewModel.offer.cardSamples![i].back!,
                contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 359 - 45.5, // 45.5 is measured
          child: Center(child: Text(S.of(context).tapToFlipCard)),
        ),
      ],
    );
  }

  Widget _buildExamplesTitle(BuildContext context) {
    return Text(
      S.of(context).examples,
      style: Theme.of(context)
          .textTheme
          .headline5!
          .copyWith(fontWeight: FontWeight.bold),
    );
  }
}
