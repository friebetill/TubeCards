import 'package:ferry/ferry.dart';
import 'package:ferry/typed_links.dart';
import 'package:injectable/injectable.dart';

import '../../graphql/operation_exception.dart';
import '../../services/tubecards/deck_service.dart';
import '../models/average_learning_state.dart';
import '../models/connection.dart';
import '../models/deck.dart';

/// Repository for the [Deck] model.
@singleton
class DeckRepository {
  DeckRepository(this._service);

  final DeckService _service;

  Stream<Deck> get(String id, {FetchPolicy? fetchPolicy}) =>
      _service.get(id, fetchPolicy: fetchPolicy);

  Stream<Connection<Deck>> getAll({
    FetchPolicy? fetchPolicy,
    bool? isActive = true,
    String? roleID,
    bool? isPublic,
  }) {
    return _service.getAll(
      fetchPolicy: fetchPolicy,
      isActive: isActive,
      roleID: roleID,
      isPublic: isPublic,
    );
  }

  /// Upserts the given [deck].
  ///
  /// Throws an [OperationException] if the deck is not uploaded successfully.
  Future<Deck> upsert(Deck deck) => _service.upsert(deck);

  /// Removes the given [deck].
  ///
  /// Throws an [OperationException] if the deck is not removed successfully.
  Future<void> remove(Deck deck) => _service.remove(deck);

  /// Transfers all decks to the user with the given auth token and returns
  /// true if the operation succeeded.
  ///
  /// The ownership transfer of the decks will be conducted on the server.
  Future<void> transferDecks(String recipientAccountAuthToken) {
    return _service.transferDecksOwnership(recipientAccountAuthToken);
  }

  Stream<Connection<Deck>> search(String searchTerm) {
    return _service.search(searchTerm: searchTerm);
  }

  Stream<AverageLearningState> getLearningState(
    String deckId, {
    FetchPolicy? fetchPolicy,
  }) {
    return _service.getLearningState(deckId, fetchPolicy: fetchPolicy);
  }

  /// Exports all decks of the user and sends a link to [toEmail].
  Future<void> exportDecks(String toEmail) => _service.exportDecks(toEmail);
}
