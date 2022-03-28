import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../../data/models/deck.dart';
import '../../../../i18n/i18n.dart';
import '../../../../main.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../../../widgets/stadium_button.dart';
import '../../../../widgets/visual_element.dart';
import 'select_deck_bloc.dart';
import 'select_deck_view_model.dart';

class SelectDeckComponent extends StatelessWidget {
  const SelectDeckComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<SelectDeckBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<SelectDeckViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SimpleSkeleton(appBarTitle: S.of(context).selectDeck);
            }

            return _SelectDeckView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _SelectDeckView extends StatelessWidget {
  const _SelectDeckView(this.viewModel);

  final SelectDeckViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).selectDeck),
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: CustomNavigator.getInstance().pop,
            tooltip: backTooltip(context),
          ),
          elevation: 0,
        ),
        body: !viewModel.isAnonymous
            ? viewModel.decks.isNotEmpty
                ? ListView(
                    children: viewModel.decks
                        .map((d) => _buildDeckTile(context, d))
                        .toList())
                : _buildEmptyState(context)
            : _buildAnonymousState(context),
      ),
    );
  }

  Widget _buildDeckTile(BuildContext context, Deck deck) {
    return VisualElement(
      id: VEs.deckTile,
      childBuilder: (controller) {
        return ListTile(
          leading: SizedBox(
            height: 52,
            width: 52,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                fadeInDuration: const Duration(milliseconds: 200),
                cacheManager: getIt<BaseCacheManager>(),
                imageUrl: deck.coverImage!.regularUrl!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(deck.name!),
          subtitle: Text(
            '${S.of(context).numberOfCards(deck.cardConnection!.totalCount!)}'
            ' · '
            '${S.of(context).numberOfDue(deck.dueCardConnection!.totalCount!)}',
          ),
          onTap: () {
            controller.logTap();
            viewModel.onDeckSelect!(deck);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(64, 0, 64, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).noPrivateDecks,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).emptyPrivateDeckListSubtitleText,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).noPermission,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).anonymousUserPublishOfferSubtitleText,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: VisualElement(
                id: VEs.signUpButton,
                childBuilder: (controller) {
                  return StadiumButton(
                    text: S.of(context).createAccount.toUpperCase(),
                    onPressed: () {
                      controller.logTap();
                      viewModel.onCreateAccountTap();
                    },
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    boldText: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
