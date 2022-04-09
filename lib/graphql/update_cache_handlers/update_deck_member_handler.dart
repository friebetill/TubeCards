import 'package:ferry/typed_links.dart';

import '../fragments/__generated__/card_fragment.data.gql.dart';
import '../fragments/__generated__/deck_fragment.data.gql.dart';
import '../fragments/__generated__/deck_fragment.req.gql.dart';
import '../fragments/__generated__/deck_member_fragment.data.gql.dart';
import '../fragments/__generated__/deck_member_fragment.req.gql.dart';
import '../mutations/__generated__/update_deck_member.data.gql.dart';
import '../mutations/__generated__/update_deck_member.var.gql.dart';
import '../queries/__generated__/viewer.data.gql.dart';
import '../queries/__generated__/viewer.req.gql.dart';
import 'helpers/cards_helper.dart';
import 'helpers/decks_helper.dart';
import 'helpers/due_cards_helper.dart';

const String updateDeckMemberHandlerKey = 'updateDeckMemberHandler';

void updateDeckMemberHandler(
  CacheProxy proxy,
  OperationResponse<GUpdateDeckMemberData, GUpdateDeckMemberVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  final viewerResponse = proxy.readQuery(GViewerReq());

  final oldDeck = proxy.readFragment(GDeckFragmentReq(
    (u) => u.idFields = {
      'id': response.data!.updateDeckMember.receivingDeckMember.deck.id,
    },
  ));

  final updateMethods = [
    _updateReceivingDeckMemberFragment,
    _updateAssigningDeckMemberFragment,
    _updateReceivingDeckFragment,
    _updateAssigningDeckFragment,
    _updateDecksRequest,
    _updateCardsRequest,
    _updateDueCardsRequest,
  ];

  for (final updateMethod in updateMethods) {
    updateMethod(
      proxy,
      response.data!.updateDeckMember,
      viewerResponse!.viewer,
      oldDeck!,
    );
  }
}

void _updateReceivingDeckMemberFragment(
  CacheProxy proxy,
  GUpdateDeckMemberData_updateDeckMember updateDeckMember,
  GViewerData_viewer viewer,
  GDeckFragmentData oldDeck,
) {
  final request = GDeckMemberFragmentReq(
    (u) => u.idFields = {
      'deckId': updateDeckMember.receivingDeckMember.deck.id,
      'userId': updateDeckMember.receivingDeckMember.user.id,
    },
  );

  final updatedResponse = GDeckMemberFragmentData.fromJson(
    updateDeckMember.receivingDeckMember.toJson(),
  );

  proxy.writeFragment(request, updatedResponse);
}

void _updateAssigningDeckMemberFragment(
  CacheProxy proxy,
  GUpdateDeckMemberData_updateDeckMember updateDeckMember,
  GViewerData_viewer viewer,
  GDeckFragmentData oldDeck,
) {
  if (updateDeckMember.assigningDeckMember.user.id ==
      updateDeckMember.receivingDeckMember.user.id) {
    // This case is already handled by _updateReceivingDeckMemberFragment.
    return;
  }

  final request = GDeckMemberFragmentReq(
    (u) => u.idFields = {
      'deckId': updateDeckMember.assigningDeckMember.deck.id,
      'userId': updateDeckMember.assigningDeckMember.user.id,
    },
  );

  final updatedResponse = GDeckMemberFragmentData.fromJson(
    updateDeckMember.assigningDeckMember.toJson(),
  );

  proxy.writeFragment(request, updatedResponse);
}

void _updateReceivingDeckFragment(
  CacheProxy proxy,
  GUpdateDeckMemberData_updateDeckMember updateDeckMember,
  GViewerData_viewer viewer,
  GDeckFragmentData oldDeck,
) {
  final request = GDeckFragmentReq(
    (u) => u.idFields = {'id': updateDeckMember.receivingDeckMember.deck.id},
  );

  final cachedResponse = proxy.readFragment(request);
  if (cachedResponse == null) {
    return;
  }

  final response = cachedResponse.rebuild((b) {
    b.viewerDeckMember
      ..role.id = updateDeckMember.receivingDeckMember.role.id
      ..isActive = updateDeckMember.receivingDeckMember.isActive;
  });

  proxy.writeFragment(request, response);
}

void _updateAssigningDeckFragment(
  CacheProxy proxy,
  GUpdateDeckMemberData_updateDeckMember updateDeckMember,
  GViewerData_viewer viewer,
  GDeckFragmentData oldDeck,
) {
  if (updateDeckMember.assigningDeckMember.user.id ==
      updateDeckMember.receivingDeckMember.user.id) {
    // This case is already handled by _updateReceivingDeckFragment.
    return;
  }

  final request = GDeckFragmentReq(
    (u) => u.idFields = {'id': updateDeckMember.assigningDeckMember.deck.id},
  );

  final cachedResponse = proxy.readFragment(request);
  if (cachedResponse == null) {
    return;
  }

  final response = cachedResponse.rebuild((b) {
    b.viewerDeckMember.role.id = updateDeckMember.assigningDeckMember.role.id;
  });

  proxy.writeFragment(request, response);
}

void _updateDecksRequest(
  CacheProxy proxy,
  GUpdateDeckMemberData_updateDeckMember updateDeckMember,
  GViewerData_viewer viewer,
  GDeckFragmentData oldDeck,
) {
  final isOldDeckActive = oldDeck.viewerDeckMember!.isActive;
  final isDeckActive = updateDeckMember.receivingDeckMember.isActive;
  if (updateDeckMember.assigningDeckMember.user.id ==
          updateDeckMember.receivingDeckMember.user.id &&
      isOldDeckActive != isDeckActive) {
    DecksHelper(proxy, isActive: isOldDeckActive)
      ..removeDeck(oldDeck.id)
      ..changeTotalCountBy(-1);
    DecksHelper(proxy, isActive: isDeckActive)
      ..addDeck(oldDeck
          .rebuild((b) => b.viewerDeckMember.isActive = isDeckActive)
          .toJson())
      ..changeTotalCountBy(1);
  }
}

void _updateCardsRequest(
  CacheProxy proxy,
  GUpdateDeckMemberData_updateDeckMember updateDeckMember,
  GViewerData_viewer viewer,
  GDeckFragmentData oldDeck,
) {
  if (updateDeckMember.assigningDeckMember.user.id ==
      updateDeckMember.receivingDeckMember.user.id) {
    final helper = CardsHelper(proxy);
    if (updateDeckMember.receivingDeckMember.isActive) {
      helper.changeTotalCountBy(
        updateDeckMember.receivingDeckMember.deck.cardConnection.totalCount,
      );
    } else {
      helper.changeTotalCountBy(-oldDeck.cardConnection.totalCount);
    }
  }
}

void _updateDueCardsRequest(
  CacheProxy proxy,
  GUpdateDeckMemberData_updateDeckMember updateDeckMember,
  GViewerData_viewer viewer,
  GDeckFragmentData oldDeck,
) {
  if (updateDeckMember.assigningDeckMember.user.id ==
      updateDeckMember.receivingDeckMember.user.id) {
    final helper = DueCardsHelper(proxy);
    if (updateDeckMember.receivingDeckMember.isActive) {
      final dueCardConnection =
          updateDeckMember.receivingDeckMember.deck.dueCardConnection;

      helper.changeTotalCountBy(dueCardConnection.totalCount);
      for (final card in dueCardConnection.nodes) {
        helper.insertCardToCorrectPage(
          GCardFragmentData.fromJson(card.toJson())!,
        );
      }
    } else {
      helper
        ..changeTotalCountBy(-oldDeck.dueCardConnection.totalCount)
        ..removeCardsOfDeck(oldDeck.id);
    }
  }
}
