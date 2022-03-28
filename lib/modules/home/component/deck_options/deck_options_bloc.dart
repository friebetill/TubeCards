import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/deck.dart';
import '../../../../data/models/deck_member.dart';
import '../../../../data/models/user.dart';
import '../../../../data/repositories/deck_member_repository.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/permission.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../deck/component/delete_dialog.dart';
import '../../util/error_util.dart';
import '../leave_dialog.dart';
import 'deck_options_component.dart';
import 'deck_options_view_model.dart';

/// BLoC for the [DeckOptionsComponent].
///
/// Exposes a [DeckOptionsViewModel] for that component to use.
@injectable
class DeckOptionsBloc with ComponentBuildContext, ComponentLifecycleListener {
  DeckOptionsBloc(
    this._userRepository,
    this._deckRepository,
    this._deckMemberRepository,
  );

  final UserRepository _userRepository;
  final DeckRepository _deckRepository;
  final DeckMemberRepository _deckMemberRepository;
  final _logger = Logger((DeckOptionsBloc).toString());

  Stream<DeckOptionsViewModel>? _viewModel;
  Stream<DeckOptionsViewModel>? get viewModel => _viewModel;

  final _showIsActiveLoadingIndicator = BehaviorSubject.seeded(false);
  final _showDeleteLoadingIndicator = BehaviorSubject.seeded(false);
  final _showLeaveLoadingIndicator = BehaviorSubject.seeded(false);

  Stream<DeckOptionsViewModel> createViewModel(String deckId) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest5(
      _deckRepository.get(deckId),
      _userRepository.viewer(),
      _showIsActiveLoadingIndicator,
      _showDeleteLoadingIndicator,
      _showLeaveLoadingIndicator,
      _createViewModel,
    );
  }

  DeckOptionsViewModel _createViewModel(
    Deck deck,
    User? user,
    bool showIsActiveLoadingIndicator,
    bool showDeleteLoadingIndicator,
    bool showLeaveLoadingIndicator,
  ) {
    final hasDeletePermission =
        deck.viewerDeckMember!.role!.hasPermission(Permission.deckDelete);

    return DeckOptionsViewModel(
      deckName: deck.name!,
      isActive: deck.viewerDeckMember!.isActive!,
      showIsActiveLoadingIndicator: showIsActiveLoadingIndicator,
      showDeleteLoadingIndicator: showDeleteLoadingIndicator,
      showLeaveLoadingIndicator: showLeaveLoadingIndicator,
      hasDeletePermission: hasDeletePermission,
      onIsActiveTap: () => _handleIsActiveTap(deck, user!),
      onDeleteTap: () => _handleDeleteTap(deck),
      onLeaveTap: () => _handleLeaveTap(deck),
    );
  }

  @override
  void dispose() {
    _showIsActiveLoadingIndicator.close();
    _showLeaveLoadingIndicator.close();
    _showDeleteLoadingIndicator.close();
    super.dispose();
  }

  Future<void> _handleIsActiveTap(Deck deck, User user) async {
    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    _showIsActiveLoadingIndicator.add(true);
    try {
      await _deckMemberRepository.update(DeckMember(
        user: user,
        deck: deck,
        isActive: !deck.viewerDeckMember!.isActive!,
      ));
    } on Exception catch (e, s) {
      final activationState =
          deck.viewerDeckMember!.isActive! ? 'activation' : 'deactivation';
      _logger.severe('Unexpected exception during $activationState.', e, s);

      messenger.showErrorSnackBar(theme: theme, text: getErrorText(i18n, e));
    }
    _showIsActiveLoadingIndicator.add(false);

    CustomNavigator.getInstance().pop();
  }

  Future<void> _handleDeleteTap(Deck deck) async {
    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final isDeletionConfirmed = await showDialog<bool?>(
      context: context,
      builder: (_) => DeleteDialog(
        title: S.of(context).deleteDeck,
        content: deck.deckMemberConnection!.totalCount == 1
            ? S.of(context).deleteDeckCautionText(deck.name)
            : S.of(context).deleteDeckWithMemberCautionText(
                  deck.name,
                  deck.deckMemberConnection!.totalCount,
                ),
      ),
    );
    if (isDeletionConfirmed == null || !isDeletionConfirmed) {
      return;
    }

    _showDeleteLoadingIndicator.add(true);
    try {
      await _deckRepository.remove(deck);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during deck removal.', e, s);

      messenger.showErrorSnackBar(theme: theme, text: getErrorText(i18n, e));
    }
    _showDeleteLoadingIndicator.add(false);

    CustomNavigator.getInstance().pop();
  }

  Future<void> _handleLeaveTap(Deck deck) async {
    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final isLeavingConfirmed = await showDialog<bool?>(
      context: context,
      builder: (_) => LeaveDialog(deckName: deck.name!),
    );

    if (isLeavingConfirmed == null || !isLeavingConfirmed) {
      return;
    }

    _showLeaveLoadingIndicator.add(true);
    try {
      await _deckRepository.remove(deck);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during deck leaving.', e, s);

      messenger.showErrorSnackBar(theme: theme, text: getErrorText(i18n, e));
    }
    _showLeaveLoadingIndicator.add(false);

    CustomNavigator.getInstance().pop();
  }
}
