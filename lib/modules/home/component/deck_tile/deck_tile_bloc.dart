import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/models/deck.dart';
import '../../../../data/models/role.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/permission.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../deck/deck_page.dart';
import '../deck_options/deck_options_component.dart';
import 'deck_tile_component.dart';
import 'deck_tile_view_model.dart';

/// BLoC for the [DeckTileComponent].
///
/// Exposes a [DeckTileViewModel] for that component to use.
@injectable
class DeckTileBloc with ComponentBuildContext {
  Stream<DeckTileViewModel>? _viewModel;
  Stream<DeckTileViewModel>? get viewModel => _viewModel;

  Stream<DeckTileViewModel> createViewModel(Stream<Deck> deck) {
    return _viewModel = deck.map((deck) {
      return DeckTileViewModel(
        deckId: deck.id!,
        deckName: deck.name!,
        isOwner: deck.viewerDeckMember!.role == Role.owner,
        cardCount: deck.cardConnection!.totalCount!,
        dueCardsCount: deck.dueCardConnection!.totalCount!,
        coverImageUrl: deck.coverImage!.regularUrl!,
        createMirrorCard: deck.createMirrorCard!,
        onTap: () => _openDeckPage(deck),
        onLongPress: () => _handleLongPress(deckId: deck.id!),
      );
    });
  }

  void _openDeckPage(Deck deck) {
    CustomNavigator.getInstance().pushNamed(
      DeckPage.routeName,
      args: DeckArguments(
        deckId: deck.id!,
        hasCardUpsertPermission: deck.viewerDeckMember!.role!.hasPermission(
          Permission.cardUpsert,
        ),
      ),
    );
  }

  void _handleLongPress({required String deckId}) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => DeckOptionsComponent(deckId),
    );
  }
}
