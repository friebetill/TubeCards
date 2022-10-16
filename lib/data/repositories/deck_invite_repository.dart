import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';

import '../../services/tubecards/deck_invite_service.dart';
import '../models/deck_invite.dart';
import '../models/role.dart';

/// Repository for the [DeckInvite] model.
@singleton
class DeckInviteRepository {
  DeckInviteRepository(this._service);

  final DeckInviteService _service;

  Stream<DeckInvite> get(String deckInviteId, {FetchPolicy? fetchPolicy}) =>
      _service.get(deckInviteId, fetchPolicy: fetchPolicy);

  Future<DeckInvite> insert(String deckId, Role role) =>
      _service.insert(deckId, role);

  /// Adds the current user to the deck via the deck invite [deckInviteId].
  Future<void> joinDeck(String deckInviteId) => _service.joinDeck(deckInviteId);

  Future<void> remove(DeckInvite deckInvite) => _service.remove(deckInvite);
}
