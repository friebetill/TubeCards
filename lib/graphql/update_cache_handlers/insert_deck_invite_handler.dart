import 'package:ferry/typed_links.dart';

import '../fragments/__generated__/deck_fragment.data.gql.dart';
import '../fragments/__generated__/deck_fragment.req.gql.dart';
import '../mutations/__generated__/insert_deck_invite.data.gql.dart';
import '../mutations/__generated__/insert_deck_invite.var.gql.dart';

const String insertDeckInviteHandlerKey = 'insertDeckInviteHandler';

void insertDeckInviteHandler(
  CacheProxy proxy,
  OperationResponse<GInsertDeckInviteData, GInsertDeckInviteVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  const updateMethods = [
    _updateDeckFragment,
  ];

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, response.data!.insertDeckInvite.deckInvite);
  }
}

void _updateDeckFragment(
  CacheProxy proxy,
  GInsertDeckInviteData_insertDeckInvite_deckInvite deckInvite,
) {
  final request =
      GDeckFragmentReq((u) => u.idFields = {'id': deckInvite.deck.id});
  final fragment = proxy.readFragment(request)!;

  final response = fragment.rebuild((b) => b.deckInvites
      .add(GDeckFragmentData_deckInvites.fromJson(deckInvite.toJson())!));

  proxy.writeFragment(request, response);
}
