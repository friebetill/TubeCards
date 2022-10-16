import 'package:ferry/typed_links.dart';

import '../../services/tubecards/deck_member_service.dart';
import '../queries/__generated__/deck_member.data.gql.dart';
import '../queries/__generated__/deck_member.req.gql.dart';
import '../queries/__generated__/deck_members.data.gql.dart';
import '../queries/__generated__/deck_members.var.gql.dart';

const String deckMembersHandlerKey = 'deckMembersHandler';

void deckMembersHandler(
  CacheProxy proxy,
  OperationResponse<GDeckMembersData, GDeckMembersVars> response,
) {
  if (response.hasErrors || response.dataSource == DataSource.Cache) {
    return;
  }

  final deckMembers = response.data!.deck.deckMemberConnection.nodes;
  final lastPage = deckMembers.reversed.take(deckMembersPageSize);
  for (final deckMember in lastPage) {
    final request = GDeckMemberReq(
      (b) => b
        ..vars.deckId = deckMember.deck.id
        ..vars.userId = deckMember.user.id,
    );

    proxy.writeQuery(
      request,
      GDeckMemberData.fromJson(
        {'__typename': 'DeckMember', 'deckMember': deckMember.toJson()},
      ),
    );
  }
}
