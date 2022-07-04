import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/deck_invite.dart';
import '../../../../data/repositories/deck_invite_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../home_page.dart';
import 'accept_deck_invite_component.dart';
import 'accept_deck_invite_view_model.dart';

/// BLoC for the [AcceptDeckInviteComponent].
///
/// Exposes a [AcceptDeckInviteViewModel] for that component to use.
@injectable
class AcceptDeckInviteBloc with ComponentLifecycleListener {
  AcceptDeckInviteBloc(this._deckInviteRepository);

  final DeckInviteRepository _deckInviteRepository;

  final _logger = Logger((AcceptDeckInviteBloc).toString());

  Stream<AcceptDeckInviteViewModel>? _viewModel;
  Stream<AcceptDeckInviteViewModel>? get viewModel => _viewModel;

  final _isLoading = BehaviorSubject.seeded(false);
  Exception? _exception;

  Stream<AcceptDeckInviteViewModel> createViewModel(String deckInviteId) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest2(
      _deckInviteRepository.get(
        deckInviteId,
        fetchPolicy: FetchPolicy.CacheAndNetwork,
      ),
      _isLoading,
      _createViewModel,
    ).map((value) => _exception == null ? value : throw _exception!);
  }

  AcceptDeckInviteViewModel _createViewModel(
    DeckInvite invite,
    bool isLoading,
  ) {
    return AcceptDeckInviteViewModel(
      deckName: invite.deck!.name!,
      creatorFullName: '${invite.deck!.creator!.firstName} '
          '${invite.deck!.creator!.lastName}',
      coverImageUrl: invite.deck!.coverImage!.smallUrl!,
      isLoading: isLoading,
      onJoinTap: () => _handleJoinTap(invite.id!),
      onCancelTap: CustomNavigator.getInstance().pop,
    );
  }

  @override
  void dispose() {
    _isLoading.close();
    super.dispose();
  }

  Future<void> _handleJoinTap(String inviteId) async {
    if (_isLoading.value) {
      return;
    }

    _isLoading.add(true);

    try {
      await _deckInviteRepository.joinDeck(inviteId);
    } on OperationException catch (e) {
      _exception = e;

      return;
    } on TimeoutException catch (e, s) {
      _logger.severe('Timeout exception during join deck', e, s);
      _exception = e;

      return;
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during join deck', e, s);
      _exception = e;

      return;
    } finally {
      _isLoading.add(false);
    }

    CustomNavigator.getInstance()
        .popUntil(ModalRoute.withName(HomePage.routeName));
  }
}
