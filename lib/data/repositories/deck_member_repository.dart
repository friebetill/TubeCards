import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';

import '../../services/tubecards/deck_member_service.dart';
import '../models/connection.dart';
import '../models/deck_member.dart';

/// Repository for the [DeckMember] model.
@singleton
class DeckMemberRepository {
  DeckMemberRepository(this._service);

  final DeckMemberService _service;

  Stream<DeckMember> get(String deckId, String userId) =>
      _service.get(deckId, userId);

  Stream<Connection<DeckMember>> getAll(String id, {FetchPolicy? fetchPolicy}) {
    return _service.getAll(id, fetchPolicy: fetchPolicy);
  }

  Future<void> update(DeckMember deckMember) => _service.update(deckMember);

  Future<void> remove(DeckMember deckMember) => _service.delete(deckMember);
}
