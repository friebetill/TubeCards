import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../../../widgets/sliver_sized_box.dart';
import '../../../../widgets/visual_element.dart';
import '../../../home/component/learn_button.dart';
import '../../../home/component/statistics.dart';
import '../../../home/component/strength_indicator.dart';
import '../../deck_page.dart';
import '../add_card_button/add_card_button_component.dart';
import '../app_bar/app_bar_component.dart';
import '../card_item_list/card_item_list_component.dart';
import '../card_search_button/card_search_button_component.dart';
import '../card_sort_button/card_sort_button_component.dart';
import '../deck_cover_image/deck_cover_image_component.dart';
import '../empty_deck.dart';
import '../practice_button.dart';
import 'deck_bloc.dart';
import 'deck_view_model.dart';

class DeckComponent extends StatelessWidget {
  const DeckComponent(this.args, {Key? key}) : super(key: key);

  final DeckArguments args;

  @override
  Widget build(BuildContext context) {
    return Component<DeckBloc>(
      createViewModel: (bloc) => bloc.createViewModel(args),
      builder: (context, bloc) {
        return StreamBuilder<DeckViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SimpleSkeleton();
            }

            return _DeckView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _DeckView extends StatefulWidget {
  const _DeckView(this.viewModel, [Key? key]) : super(key: key);

  final DeckViewModel viewModel;

  @override
  State<StatefulWidget> createState() => _DeckViewState();
}

class _DeckViewState extends State<_DeckView> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        LogicalKeySet(LogicalKeyboardKey.escape): widget.viewModel.onBackTap,
        LogicalKeySet(
          Platform.isMacOS
              ? LogicalKeyboardKey.meta
              : LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyE,
        ): widget.viewModel.onEditTap,
        if (widget.viewModel.onManageMembersTap != null)
          LogicalKeySet(
            Platform.isMacOS
                ? LogicalKeyboardKey.meta
                : LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyM,
          ): widget.viewModel.onManageMembersTap!,
      },
      child: Scaffold(
        floatingActionButtonLocation: !widget.viewModel.hasCards
            ? FloatingActionButtonLocation.centerDocked
            : FloatingActionButtonLocation.centerFloat,
        floatingActionButton: widget.viewModel.hasCardUpsertPermission
            ? AddCardButtonComponent(deckId: widget.viewModel.id)
            : null,
        appBar: AppBarComponent(
          widget.viewModel.id,
          widget.viewModel.onEditTap,
          widget.viewModel.onBackTap,
          widget.viewModel.onManageMembersTap,
        ),
        bottomNavigationBar: !widget.viewModel.hasCards
            ? const BottomAppBar(child: SizedBox(height: 56))
            : null,
        // We only use CustomScrollView to use SliverFillRemaining.
        body: !widget.viewModel.hasCards
            ? EmptyDeck(deckId: widget.viewModel.id)
            : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: DeckCoverImageComponent(deckId: widget.viewModel.id),
                  ),
                  const SliverSizedBox(height: 20),
                  _buildInformation(context),
                  const SliverSizedBox(height: 20),
                  _buildCardsTitle(),
                  // The adapter has to be in the CartItemListComponent, because
                  // it depends on whether items are in the list.
                  CardItemListComponent(
                    deckId: widget.viewModel.id,
                    scrollController: _scrollController,
                    showAddCardButtonPadding:
                        widget.viewModel.hasCardUpsertPermission,
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildInformation(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 132,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 132,
              child: StrengthIndicator(strength: widget.viewModel.strength),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Statistics(
                    totalDueCardsCount: widget.viewModel.totalDueCardsCount,
                    totalCardsCount: widget.viewModel.totalCardsCount,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 180,
                    height: 40,
                    child: widget.viewModel.totalDueCardsCount > 0
                        ? _buildLearnButton()
                        : _buildPracticeButton(),
                  ),
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
      id: VEs.learnButton,
      childBuilder: (controller) {
        return LearnButton(
          onTap: widget.viewModel.onLearnTap != null
              ? () {
                  controller.logTap();
                  widget.viewModel.onLearnTap!();
                }
              : null,
          strength: widget.viewModel.strength,
        );
      },
    );
  }

  Widget _buildPracticeButton() {
    return VisualElement(
      id: VEs.practiceButton,
      childBuilder: (controller) {
        return PracticeButton(
          onTap: widget.viewModel.onPracticeTap != null
              ? () {
                  controller.logTap();
                  widget.viewModel.onPracticeTap!();
                }
              : null,
        );
      },
    );
  }

  Widget _buildCardsTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            Text(S.of(context).cards(2).toUpperCase()),
            const Spacer(),
            CardSearchButtonComponent(deckId: widget.viewModel.id),
            const CardSortButtonComponent(),
          ],
        ),
      ),
    );
  }
}
