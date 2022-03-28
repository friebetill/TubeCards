import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/logging/interaction_logger.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../utils/themes/custom_theme.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/sliver_sized_box.dart';
import '../../../../widgets/visual_element.dart';
import '../../util/bottom_navigation_bar_height.dart';
import '../deck_tile_grid.dart';
import '../empty_home.dart';
import '../learn_button.dart';
import '../statistics.dart';
import '../strength_indicator.dart';
import '../utils/error_indicator.dart';
import 'home_bloc.dart';
import 'home_view_model.dart';

class HomeComponent extends StatelessWidget {
  const HomeComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<HomeBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<HomeViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingIndicator(context);
            } else if (snapshot.hasError) {
              return ErrorIndicator(snapshot.error!);
            } else if (snapshot.data!.activeDecks.isEmpty &&
                snapshot.data!.inactiveDecks.isEmpty) {
              return const EmptyHome();
            } else {
              return _HomeView(snapshot.data!);
            }
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Padding(
      // Add a padding to the bottom to offset the navigation bar.
      padding: EdgeInsets.only(bottom: getBottomNavigationBarHeight(context)),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView(this.viewModel);

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LazyLoadScrollView(
      onEndOfPage: viewModel.fetchMore,
      scrollOffset: 400,
      child: RefreshIndicator(
        onRefresh: () async {
          InteractionLogger.getInstance().logDrag(VEs.reloadButton);
          await viewModel.refresh();
        },
        // We only use CustomScrollView to use SliverFillRemaining.
        child: CustomScrollView(
          // We can't give the ListView padding, because the shadow of the
          // tiles would be clipped.
          slivers: [
            _buildGeneralInfo(context),
            const SliverSizedBox(height: 12),
            _buildDecksTitle(context),
            _buildDecks(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInfo(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: Platform.isWindows ? 140 : 132,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 132,
              child: StrengthIndicator(strength: viewModel.strength),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Statistics(
                    totalDueCardsCount: viewModel.totalDueCardsCount,
                    totalCardsCount: viewModel.totalCardsCount,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(width: 180, height: 40, child: _buildLearnButton()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnButton() {
    return VisualElement(
      id: VEs.reviewButton,
      childBuilder: (controller) {
        return LearnButton(
          onTap: viewModel.onReviewTap != null
              ? () {
                  controller.logTap(
                    eventProperties: {
                      'strength': viewModel.strength.toString()
                    },
                  );
                  viewModel.onReviewTap!();
                }
              : null,
          strength: viewModel.strength,
        );
      },
    );
  }

  Widget _buildDecksTitle(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        // Compensate for the dropdown button padding at the end.
        padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
        child: Row(
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).decks(2),
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            _buildActiveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDecks(BuildContext context) {
    if (viewModel.activeDeckState == ActiveState.active &&
        viewModel.activeDecks.isEmpty) {
      return _buildNoActiveDecks(context);
    } else if (viewModel.activeDeckState == ActiveState.inactive &&
        viewModel.inactiveDecks.isEmpty) {
      return _buildNoInactiveDecks(context);
    } else {
      return SliverToBoxAdapter(
        child: DeckTileGrid(
          decks: viewModel.activeDeckState == ActiveState.active
              ? viewModel.activeDecks
              : viewModel.inactiveDecks,
          showLoadingIndicator: viewModel.showLoadingIndicator,
        ),
      );
    }
  }

  Widget _buildNoActiveDecks(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          64,
          0,
          64,
          getBottomNavigationBarHeight(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).noDecksYet,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              S.of(context).emptyDeckListSubtitleText,
              style: TextStyle(color: Theme.of(context).hintColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInactiveDecks(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          64,
          0,
          64,
          getBottomNavigationBarHeight(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).noInactiveDecksYet,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              S.of(context).noInactivesDecksSubtitleText,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveButton(BuildContext context) {
    return VisualElement(
      id: VEs.activeDropdownButton,
      childBuilder: (controller) {
        return DropdownButton<ActiveState>(
          value: viewModel.activeDeckState,
          items: [
            DropdownMenuItem(
              value: ActiveState.active,
              onTap: () {
                InteractionLogger.getInstance().logTap(VEs.activeMenuItem);
              },
              child: Text(S.of(context).active),
            ),
            DropdownMenuItem(
              value: ActiveState.inactive,
              onTap: () {
                InteractionLogger.getInstance().logTap(VEs.inactiveMenuItem);
              },
              child: Text(S.of(context).inactive),
            ),
          ],
          onTap: controller.logTap,
          onChanged: viewModel.onActiveStateChanged,
          icon: const Icon(Icons.arrow_drop_down),
          underline: Container(),
          dropdownColor: Theme.of(context).custom.elevation8DPColor,
          style: Theme.of(context).textTheme.bodyText2,
        );
      },
    );
  }
}
