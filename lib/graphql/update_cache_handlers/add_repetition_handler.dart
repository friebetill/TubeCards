import 'package:ferry/typed_links.dart';

import '../fragments/__generated__/card_fragment.data.gql.dart';
import '../fragments/__generated__/card_fragment.req.gql.dart';
import '../fragments/__generated__/deck_fragment.req.gql.dart';
import '../mutations/__generated__/add_repetition.data.gql.dart';
import '../mutations/__generated__/add_repetition.var.gql.dart';
import 'helpers/due_cards_helper.dart';
import 'helpers/due_cards_of_deck_helper.dart';

const String addRepetitionHandlerKey = 'addRepetitionHandler';

void addRepetitionHandler(
  CacheProxy proxy,
  OperationResponse<GAddRepetitionData, GAddRepetitionVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  const updateMethods = [
    _updateDueCardsRequest,
    _updateDueCardsOfDeckRequest,
    _updateCardFragment,
    _updateDeckFragment,
  ];

  final isDue = response.data!.addRepetition.learningState.nextDueDate
      .isBefore(DateTime.now());

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, response.data!.addRepetition, isDue);
  }
}

void _updateDueCardsRequest(
  CacheProxy proxy,
  GAddRepetitionData_addRepetition addRepetition,
  bool isDue,
) {
  final card = GCardFragmentData.fromJson(addRepetition.toJson())!;
  final helper = DueCardsHelper(proxy)..removeCard(card.id);

  if (isDue) {
    helper.insertCardToCorrectPage(card);
  } else {
    helper.changeTotalCountBy(-1);
  }
}

void _updateDueCardsOfDeckRequest(
  CacheProxy proxy,
  GAddRepetitionData_addRepetition addRepetition,
  bool isDue,
) {
  final card = GCardFragmentData.fromJson(addRepetition.toJson())!;
  final helper = DueCardsOfDeckHelper(proxy, card.deck.id)
    ..removeCard(addRepetition.id);

  if (isDue) {
    helper.insertCardToCorrectPage(card);
  } else {
    helper.changeTotalCountBy(-1);
  }
}

void _updateCardFragment(
  CacheProxy proxy,
  GAddRepetitionData_addRepetition addRepetition,
  bool _,
) {
  final request = GCardFragmentReq(
    (u) => u.idFields = {'id': addRepetition.id},
  );

  final cachedResponse = proxy.readFragment(request);

  if (cachedResponse == null) {
    return;
  }

  final updatedResponse = cachedResponse.rebuild((b) {
    b.learningState
      ..nextDueDate = addRepetition.learningState.nextDueDate
      ..streakKnown = addRepetition.learningState.streakKnown
      ..ease = addRepetition.learningState.ease
      ..strength = addRepetition.learningState.strength
      ..stability = addRepetition.learningState.stability
      ..createdAt = addRepetition.learningState.createdAt;
  });

  proxy.writeFragment(request, updatedResponse);
}

void _updateDeckFragment(
  CacheProxy proxy,
  GAddRepetitionData_addRepetition addRepetition,
  bool isDue,
) {
  if (isDue) {
    // Don't change the totalCount of the due cards.
    return;
  }

  final request = GDeckFragmentReq(
    (u) => u.idFields = {'id': addRepetition.deck.id},
  );

  final cachedResponse = proxy.readFragment(request);

  if (cachedResponse == null) {
    return;
  }

  final updatedResponse = cachedResponse.rebuild((b) {
    b.dueCardConnection.totalCount = b.dueCardConnection.totalCount! - 1;
  });

  proxy.writeFragment(request, updatedResponse);
}
