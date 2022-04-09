import 'package:ferry/typed_links.dart';

import '../../data/models/role.dart';
import '../fragments/__generated__/deck_fragment.data.gql.dart';
import '../fragments/__generated__/deck_fragment.req.gql.dart';
import '../mutations/__generated__/upsert_deck.data.gql.dart';
import '../mutations/__generated__/upsert_deck.var.gql.dart';
import '../queries/__generated__/deck.data.gql.dart';
import '../queries/__generated__/deck.req.gql.dart';
import 'helpers/decks_helper.dart';

const String upsertDeckHandlerKey = 'upsertDeckHandler';

void upsertDeckHandler(
  CacheProxy proxy,
  OperationResponse<GUpsertDeckData, GUpsertDeckVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  const updateMethods = [
    _updateDecksRequest,
    _updateDeckRequest,
    _updateDeckFragment,
  ];

  final oldDeck = proxy.readFragment(
    GDeckFragmentReq((u) => u.idFields = {'id': response.data!.upsertDeck.id}),
  );

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, response.data!.upsertDeck, oldDeck);
  }
}

void _updateDecksRequest(
  CacheProxy proxy,
  GUpsertDeckData_upsertDeck upsertDeck,
  GDeckFragmentData? oldDeck,
) {
  final isUpdate = oldDeck != null;
  if (isUpdate) {
    // Do nothing, as this is already handled by updating the deck fragment.
    return;
  }

  DecksHelper(proxy, isActive: upsertDeck.viewerDeckMember!.isActive)
    ..addDeck(upsertDeck.toJson())
    ..changeTotalCountBy(1);

  DecksHelper(proxy, isActive: null, isPublic: false, roleId: Role.owner.id)
    ..addDeck(upsertDeck.toJson())
    ..changeTotalCountBy(1);
}

void _updateDeckRequest(
  CacheProxy proxy,
  GUpsertDeckData_upsertDeck upsertDeck,
  GDeckFragmentData? _,
) {
  final request = GDeckReq((b) => b..vars.id = upsertDeck.id);
  final cachedResponse = proxy.readQuery(request);

  final deck = GDeckData_deck.fromJson(upsertDeck.toJson())!;
  final response = cachedResponse != null
      ? cachedResponse.rebuild((b) => b.deck.replace(deck))
      : GDeckData((b) => b.deck.replace(deck));

  proxy.writeQuery(request, response);
}

void _updateDeckFragment(
  CacheProxy proxy,
  GUpsertDeckData_upsertDeck upsertDeck,
  GDeckFragmentData? _,
) {
  final request = GDeckFragmentReq((u) => u.idFields = {'id': upsertDeck.id});

  final response = GDeckFragmentData.fromJson(upsertDeck.toJson());

  proxy.writeFragment(request, response);
}
