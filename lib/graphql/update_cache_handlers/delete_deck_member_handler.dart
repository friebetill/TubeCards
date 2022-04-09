import 'package:ferry/typed_links.dart';

import '../fragments/__generated__/deck_member_fragment.req.gql.dart';
import '../mutations/__generated__/delete_deck_member.data.gql.dart';
import '../mutations/__generated__/delete_deck_member.var.gql.dart';
import 'helpers/deck_members_helper.dart';

const String deleteDeckMemberHandlerKey = 'deleteDeckMemberHandler';

void deleteDeckMemberHandler(
  CacheProxy proxy,
  OperationResponse<GDeleteDeckMemberData, GDeleteDeckMemberVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  final deleteDeckMember = response.data!.deleteDeckMember;
  final deckMember = proxy.readFragment(GDeckMemberFragmentReq(
    (b) => b.idFields = {
      'deck': {'id': deleteDeckMember.deckMember.deck.id},
      'user': {'id': deleteDeckMember.deckMember.user.id},
    },
  ));

  DeckMembersHelper(proxy, deleteDeckMember.deckMember.deck.id)
      .changeTotalCountBy(-1);

  proxy
    ..evict(proxy.identify(deckMember)!)
    ..gc();
}
