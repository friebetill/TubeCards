import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/deck_member.dart';
import '../../../../data/models/role.dart';
import '../../../../data/repositories/deck_member_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../home/util/error_util.dart';
import '../make_owner_dialog.dart';
import '../remove_dialog.dart';
import 'deck_member_options_component.dart';
import 'deck_member_options_view_model.dart';

/// BLoC for the [DeckMemberOptionsComponent].
///
/// Exposes a [DeckMemberOptionsViewModel] for that component to use.
@injectable
class DeckMemberOptionsBloc
    with ComponentBuildContext, ComponentLifecycleListener {
  DeckMemberOptionsBloc(this._deckMemberRepository);

  final DeckMemberRepository _deckMemberRepository;
  final _logger = Logger((DeckMemberOptionsBloc).toString());

  Stream<DeckMemberOptionsViewModel>? _viewModel;
  Stream<DeckMemberOptionsViewModel>? get viewModel => _viewModel;

  final _showOwnerLoadingIndicator = BehaviorSubject.seeded(false);
  final _showEditorLoadingIndicator = BehaviorSubject.seeded(false);
  final _showViewerLoadingIndicator = BehaviorSubject.seeded(false);
  final _showDeleteLoadingIndicator = BehaviorSubject.seeded(false);

  Stream<DeckMemberOptionsViewModel> createViewModel(
    String deckId,
    String userId,
  ) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest5(
      _deckMemberRepository.get(deckId, userId),
      _showOwnerLoadingIndicator,
      _showEditorLoadingIndicator,
      _showViewerLoadingIndicator,
      _showDeleteLoadingIndicator,
      _createViewModel,
    );
  }

  DeckMemberOptionsViewModel _createViewModel(
    DeckMember deckMember,
    bool showOwnerLoadingIndicator,
    bool showEditorLoadingIndicator,
    bool showViewerLoadingIndicator,
    bool showDeleteLoadingIndicator,
  ) {
    return DeckMemberOptionsViewModel(
      deckMember: deckMember,
      showMakeEditorButton: deckMember.role != Role.editor,
      showMakeViewerButton: deckMember.role != Role.viewer,
      showOwnerLoadingIndicator: showOwnerLoadingIndicator,
      showDeleteLoadingIndicator: showDeleteLoadingIndicator,
      showViewerLoadingIndicator: showViewerLoadingIndicator,
      showEditorLoadingIndicator: showEditorLoadingIndicator,
      onMakeOwnerTap: () => _handleMakeOwnerTap(deckMember),
      onMakeEditorTap: () => _handleMakeEditorTap(deckMember),
      onMakeViewerTap: () => _handleMakeViewerTap(deckMember),
      onDeleteTap: () => _handleDeleteTap(deckMember),
    );
  }

  @override
  void dispose() {
    _showOwnerLoadingIndicator.close();
    _showEditorLoadingIndicator.close();
    _showViewerLoadingIndicator.close();
    _showDeleteLoadingIndicator.close();
    super.dispose();
  }

  Future<void> _handleMakeOwnerTap(DeckMember member) async {
    if (_showOwnerLoadingIndicator.value) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final isMakeOwnerConfirmed = await showDialog<bool?>(
      context: context,
      builder: (_) => MakeOwnerDialog(
        fullName: '${member.user!.firstName} ${member.user!.lastName}',
      ),
    );

    if (isMakeOwnerConfirmed == null || !isMakeOwnerConfirmed) {
      return;
    }

    await _showLoadingIndicator(_showOwnerLoadingIndicator, () async {
      try {
        await _deckMemberRepository.update(member.copyWith(role: Role.owner));
      } on OperationException catch (e, s) {
        _handleOperationException(i18n, messenger, theme, e, s);
      } on TimeoutException {
        _handleTimeoutException(i18n, messenger, theme);
      } on Exception catch (e, s) {
        _logger.severe('Unexpected exception during make owner.', e, s);
        messenger.showErrorSnackBar(theme: theme, text: getErrorText(i18n, e));
      }
    });

    CustomNavigator.getInstance().pop();
  }

  Future<void> _handleMakeEditorTap(DeckMember deckMember) async {
    if (_showEditorLoadingIndicator.value) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    await _showLoadingIndicator(_showEditorLoadingIndicator, () async {
      try {
        await _deckMemberRepository
            .update(deckMember.copyWith(role: Role.editor));
      } on OperationException catch (e, s) {
        _handleOperationException(i18n, messenger, theme, e, s);
      } on TimeoutException {
        _handleTimeoutException(i18n, messenger, theme);
      } on Exception catch (e, s) {
        _logger.severe('Unexpected exception during make editor.', e, s);
        messenger.showErrorSnackBar(theme: theme, text: getErrorText(i18n, e));
      }
    });

    CustomNavigator.getInstance().pop();
  }

  Future<void> _handleMakeViewerTap(DeckMember deckMember) async {
    if (_showViewerLoadingIndicator.value) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    await _showLoadingIndicator(_showViewerLoadingIndicator, () async {
      try {
        await _deckMemberRepository
            .update(deckMember.copyWith(role: Role.viewer));
      } on OperationException catch (e, s) {
        _handleOperationException(i18n, messenger, theme, e, s);
      } on TimeoutException {
        _handleTimeoutException(i18n, messenger, theme);
      } on Exception catch (e, s) {
        _logger.severe('Unexpected exception during make viewer.', e, s);
        messenger.showErrorSnackBar(theme: theme, text: getErrorText(i18n, e));
      }
    });

    CustomNavigator.getInstance().pop();
  }

  Future<void> _handleDeleteTap(DeckMember member) async {
    if (_showDeleteLoadingIndicator.value) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final isDeletionConfirmed = await showDialog<bool?>(
      context: context,
      builder: (_) => RemoveDialog(
        title: S.of(context).removeFromDeck,
        content: S.of(context).removeFromDeckCautionText(
              '${member.user!.firstName} ${member.user!.lastName}',
              member.deck!.name,
            ),
      ),
    );

    if (isDeletionConfirmed == null || !isDeletionConfirmed) {
      return;
    }

    await _showLoadingIndicator(_showDeleteLoadingIndicator, () async {
      try {
        await _deckMemberRepository.remove(member);
      } on OperationException catch (e, s) {
        _handleOperationException(i18n, messenger, theme, e, s);
      } on TimeoutException {
        _handleTimeoutException(i18n, messenger, theme);
      } on Exception catch (e, s) {
        _logger.severe(
          'Unexpected exception during deck member removal.',
          e,
          s,
        );
        messenger.showErrorSnackBar(theme: theme, text: getErrorText(i18n, e));
      }
    });

    CustomNavigator.getInstance().pop();
  }

  Future<void> _showLoadingIndicator(
    BehaviorSubject<bool> loadingIndicator,
    Future<void> Function() operation,
  ) async {
    loadingIndicator.add(true);
    await operation();
    loadingIndicator.add(false);
  }

  void _handleOperationException(
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
    OperationException e,
    StackTrace s,
  ) {
    var exceptionText = i18n.errorUnknownText;
    if (e.isDeckPublic) {
      exceptionText = S.of(context).publicDeckTransferErrorText;
    } else if (e.isNoInternet) {
      exceptionText = i18n.errorNoInternetText;
    } else if (e.isServerOffline) {
      exceptionText = i18n.errorWeWillFixText;
    } else {
      _logger.severe('Operation exception during card moving/deletion', e, s);
    }

    messenger.showErrorSnackBar(theme: theme, text: exceptionText);
  }

  void _handleTimeoutException(
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
  ) {
    messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
  }
}
