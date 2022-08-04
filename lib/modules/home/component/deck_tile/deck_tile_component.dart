import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/deck.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/cover_image.dart';
import '../../../../widgets/scalable_widgets/horizontal_scalable_box.dart';
import '../../../../widgets/visual_element.dart';
import '../utils/tile_decoration.dart';
import 'deck_tile_bloc.dart';
import 'deck_tile_view_model.dart';

/// Compact visual representation of a [Deck].
///
/// A [DeckTileComponent] is usually used as part of a list of decks for a
/// given user.
class DeckTileComponent extends StatefulWidget {
  /// Constructs a new [DeckTileComponent] for the given [deck].
  const DeckTileComponent(this.deck, {Key? key}) : super(key: key);

  final Deck deck;

  @override
  DeckTileComponentState createState() => DeckTileComponentState();
}

class DeckTileComponentState extends State<DeckTileComponent> {
  // Needed to ensure DeckTileComponent is rebuilt when the given Deck changes
  late final _deck = BehaviorSubject<Deck>.seeded(widget.deck);

  @override
  Widget build(BuildContext context) {
    return Component<DeckTileBloc>(
      createViewModel: (bloc) => bloc.createViewModel(_deck),
      builder: (context, bloc) {
        return StreamBuilder<DeckTileViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _DeckTileView(snapshot.data!);
          },
        );
      },
    );
  }

  @override
  void didUpdateWidget(DeckTileComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.deck != oldWidget.deck) {
      _deck.add(widget.deck);
    }
  }

  @override
  void dispose() {
    _deck.close();
    super.dispose();
  }
}

class _DeckTileView extends StatelessWidget {
  const _DeckTileView(this.viewModel);

  final DeckTileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return VisualElement(
      id: VEs.deckTile,
      childBuilder: (controller) {
        return TileDecoration(
          child: GestureDetector(
            onSecondaryTap: () {
              controller.logSecondaryTap();
              viewModel.onLongPress();
            },
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                controller.logTap();
                viewModel.onTap();
              },
              onLongPress: () {
                controller.logLongPress();
                viewModel.onLongPress();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: CoverImage(
                      imageUrl: viewModel.coverImageUrl,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      tag: viewModel.deckId,
                    ),
                  ),
                  _buildMetadata(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return HorizontalScalableBox(
          minHeight: 30,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(context, constraints),
                const Spacer(),
                _buildDetails(context),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context, BoxConstraints constraints) {
    return SizedBox(
      width: constraints.maxWidth,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          viewModel.deckName,
          textAlign: TextAlign.start,
          maxLines: 1,
          softWrap: false,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: S.of(context).numberOfCards(viewModel.cardCount).titleCase,
          ),
          if (viewModel.dueCardsCount > 0) const TextSpan(text: ' · '),
          if (viewModel.dueCardsCount > 0)
            TextSpan(
              text:
                  S.of(context).numberOfDue(viewModel.dueCardsCount).titleCase,
            ),
          if (viewModel.createMirrorCard) const TextSpan(text: ' · '),
          if (viewModel.createMirrorCard)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.compare_arrows_outlined,
                color: Theme.of(context).hintColor,
                size: 16,
              ),
            ),
          if (!viewModel.isOwner) const TextSpan(text: ' · '),
          if (!viewModel.isOwner)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.people_outlined,
                color: Theme.of(context).hintColor,
                size: 16,
              ),
            ),
        ],
      ),
      style: Theme.of(context).textTheme.caption,
    );
  }
}
