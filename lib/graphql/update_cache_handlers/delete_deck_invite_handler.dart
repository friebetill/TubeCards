import 'package:ferry/typed_links.dart';

import '../fragments/__generated__/deck_invite_fragment.req.gql.dart';
import '../mutations/__generated__/delete_deck_invite.data.gql.dart';
import '../mutations/__generated__/delete_deck_invite.var.gql.dart';

const String deleteDeckInviteHandlerKey = 'deleteDeckInviteHandler';

void deleteDeckInviteHandler(
  CacheProxy proxy,
  OperationResponse<GDeleteDeckInviteData, GDeleteDeckInviteVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  final deckInvite = proxy.readFragment(GDeckInviteFragmentReq(
    (u) => u.idFields = {'id': response.data!.deleteDeckInvite.id},
  ));

  proxy
    ..evict(proxy.identify(deckInvite)!)
    ..gc();
}
