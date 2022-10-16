import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/connection.dart';
import '../../data/models/deck_member.dart';
import '../../graphql/graph_ql_runner.dart';
import '../../graphql/mutations/__generated__/delete_deck_member.req.gql.dart';
import '../../graphql/mutations/__generated__/update_deck_member.req.gql.dart';
import '../../graphql/operation_exception.dart';
import '../../graphql/queries/__generated__/deck_member.req.gql.dart';
import '../../graphql/queries/__generated__/deck_members.data.gql.dart';
import '../../graphql/queries/__generated__/deck_members.req.gql.dart';
import '../../graphql/update_cache_handlers/deck_members_handler.dart';
import '../../graphql/update_cache_handlers/delete_deck_member_handler.dart';
import '../../graphql/update_cache_handlers/update_deck_member_handler.dart';

part 'deck_member_service/get_all.dart';

@singleton
class DeckMemberService {
  DeckMemberService(this._graphQLRunner);

  final GraphQLRunner _graphQLRunner;

  Stream<DeckMember> get(String deckId, String userId) {
    DeckMember? deckMember;

    return _graphQLRunner
        .request(GDeckMemberReq(
          (b) => b
            ..vars.deckId = deckId
            ..vars.userId = userId,
        ))
        .distinct()
        .map((response) {
      if (response.data != null) {
        deckMember = DeckMember.fromJson(response.data!.deckMember.toJson());
      }
      if (deckMember == null && response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }

      return deckMember!;
    });
  }

  Future<void> update(DeckMember deckMember) {
    return _graphQLRunner
        .request(GUpdateDeckMemberReq((b) => b
          ..fetchPolicy = FetchPolicy.NoCache
          ..vars.deckId = deckMember.deck!.id!
          ..vars.userId = deckMember.user!.id!
          ..vars.roleId = deckMember.role?.id
          ..vars.isActive = deckMember.isActive
          ..updateCacheHandlerKey = updateDeckMemberHandlerKey))
        .map((response) {
      if (response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }
    }).first;
  }

  Future<void> delete(DeckMember deckMember) {
    return _graphQLRunner
        .request(GDeleteDeckMemberReq((b) => b
          ..fetchPolicy = FetchPolicy.NoCache
          ..vars.deckId = deckMember.deck!.id!
          ..vars.userId = deckMember.user!.id!
          ..updateCacheHandlerKey = deleteDeckMemberHandlerKey))
        .map((response) {
      if (response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }
    }).first;
  }
}
