import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../../../widgets/visual_element.dart';
import '../../../offer/component/creator_component.dart';
import '../../../offer/component/header_component.dart';
import '../../../review/component/flashcard_component.dart';
import 'offer_preview_bloc.dart';
import 'offer_preview_view_model.dart';

class OfferPreviewComponent extends StatelessWidget {
  const OfferPreviewComponent({required this.deckId, Key? key})
      : super(key: key);

  final String deckId;

  @override
  Widget build(BuildContext context) {
    return Component<OfferPreviewBloc>(
      createViewModel: (bloc) => bloc.createViewModel(deckId),
      builder: (context, bloc) {
        return StreamBuilder<OfferPreviewViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SimpleSkeleton();
            }

            return _OfferPreviewView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _OfferPreviewView extends StatelessWidget {
  const _OfferPreviewView(this.viewModel);

  final OfferPreviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: _buildAppBar(context),
        floatingActionButton: _buildFAB(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: ListView(
          padding: const EdgeInsets.all(16),
          clipBehavior: Clip.none,
          children: <Widget>[
            HeaderComponent(
              deckName: viewModel.deckName,
              coverImageUrl: viewModel.coverImageUrl,
            ),
            const SizedBox(height: 16),
            Text(viewModel.description.isNotEmpty
                ? viewModel.description
                : S.of(context).noDescription),
            const SizedBox(height: 16),
            _buildMetaData(context),
            const SizedBox(height: 16),
            CreatorComponent(creator: viewModel.creator),
            if (viewModel.cardSamples.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildExamplesSection(context),
            ],
            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Text(S.of(context).preview),
      leading: IconButton(
        icon: const BackButtonIcon(),
        onPressed: CustomNavigator.getInstance().pop,
        tooltip: backTooltip(context),
      ),
      actions: [
        VisualElement(
          id: VEs.deckSettingsButton,
          childBuilder: (controller) {
            return IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                controller.logTap();
                viewModel.onEditTap();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return VisualElement(
      id: VEs.publishOfferButton,
      childBuilder: (controller) {
        return FloatingActionButton.extended(
          onPressed: () {
            controller.logTap();
            viewModel.onPublishTap();
          },
          label: !viewModel.isLoading
              ? Text(S.of(context).publish.toUpperCase())
              : IconSizedLoadingIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
        );
      },
    );
  }

  Widget _buildMetaData(BuildContext context) {
    return Text(
      '${viewModel.cardsCount} '
      '${S.of(context).cards(viewModel.cardsCount).toLowerCase()}',
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
          height: 375,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // Make sure items are not clipped when there is horizontal space
            // left next to the last item and the user scrolls.
            clipBehavior: Clip.none,
            itemCount: viewModel.cardSamples.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 360 - 32,
              child: FlashcardComponent(
                frontText: viewModel.cardSamples[i].front!,
                backText: viewModel.cardSamples[i].back!,
                contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: Text(S.of(context).tapToFlipCard)),
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
