import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/models/deck.dart';
import '../../../../data/models/deck_invite.dart';
import '../../../../data/models/role.dart';
import '../../../../data/repositories/deck_invite_repository.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import 'share_invite_dialog_view_model.dart';

@injectable
class ShareInviteDialogBloc
    with ComponentLifecycleListener, ComponentBuildContext {
  ShareInviteDialogBloc(this._deckRepository, this._deckInviteRepository);

  final _logger = Logger((ShareInviteDialogBloc).toString());

  final DeckRepository _deckRepository;
  final DeckInviteRepository _deckInviteRepository;

  Stream<ShareInviteDialogViewModel>? _viewModel;
  Stream<ShareInviteDialogViewModel>? get viewModel => _viewModel;

  final _showGenerateLinkLoadingIndicator = BehaviorSubject.seeded(false);
  final _showDeleteLinkLoadingIndicator = BehaviorSubject.seeded(false);
  final _showCopiedLinkIndicator = BehaviorSubject.seeded(false);

  Stream<ShareInviteDialogViewModel> createViewModel({
    required String deckId,
    required Role role,
  }) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest5(
      Stream.value(role),
      _deckRepository.get(deckId),
      _showGenerateLinkLoadingIndicator,
      _showDeleteLinkLoadingIndicator,
      _showCopiedLinkIndicator,
      _createViewModel,
    ).startWith(
      // Start with a placeholder view model, because it takes time to load the
      // deck from the isolate and otherwise it would lead to a jumping dialog.
      ShareInviteDialogViewModel(
        role: role,
        link: null,
        showLinkLoadingIndicator: true,
        showGenerateLinkButton: false,
        showDeleteLinkButton: false,
        showDeleteLinkLoadingIndicator: false,
        showCopiedLinkIndicator: false,
        onLinkTap: () {/* NO-OP */},
        onShare: () {/* NO-OP */},
        onDeleteTap: () {/* NO-OP */},
      ),
    );
  }

  ShareInviteDialogViewModel _createViewModel(
    Role role,
    Deck deck,
    bool showGenerateLinkLoadingIndicator,
    bool showDeleteLinkLoadingIndicator,
    bool showCopiedLinkIndicator,
  ) {
    final deckInvite =
        deck.deckInvites!.singleWhereOrNull((l) => l.inviteeRole == role);

    // Wait for the updated deck until we adjust the loading indicator.
    if (showGenerateLinkLoadingIndicator && deckInvite != null) {
      _showGenerateLinkLoadingIndicator.add(false);
    } else if (showDeleteLinkLoadingIndicator && deckInvite == null) {
      _showDeleteLinkLoadingIndicator.add(false);
    }

    final showGenerateLinkButton = deckInvite == null;
    final isOwner = deck.viewerDeckMember!.role == Role.owner;
    final inviteUrl =
        deckInvite?.link != null ? Uri.tryParse(deckInvite!.link!) : null;

    return ShareInviteDialogViewModel(
      role: role,
      link: inviteUrl,
      showGenerateLinkButton: showGenerateLinkButton,
      showLinkLoadingIndicator: showGenerateLinkLoadingIndicator,
      showDeleteLinkButton: isOwner,
      showDeleteLinkLoadingIndicator: showDeleteLinkLoadingIndicator,
      showCopiedLinkIndicator: showCopiedLinkIndicator,
      onLinkTap: () => showGenerateLinkButton
          ? _insertDeckInvite(deck.id!, role)
          : _copyLinkToClipboard(deckInvite!.link!),
      onShare: () => _handleShare(deckInvite!.link!),
      onDeleteTap: () =>
          deckInvite != null ? _deleteDeckInvite(deckInvite) : null,
    );
  }

  @override
  void dispose() {
    _showGenerateLinkLoadingIndicator.close();
    _showDeleteLinkLoadingIndicator.close();
    _showCopiedLinkIndicator.close();
    super.dispose();
  }

  Future<void> _insertDeckInvite(String deckId, Role role) async {
    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    _showGenerateLinkLoadingIndicator.add(true);
    try {
      await _deckInviteRepository.insert(deckId, role);
    } on OperationException catch (e, s) {
      _handleOperationException(e, s, i18n, messenger, theme);
    } on TimeoutException {
      final exceptionText = i18n.errorUnknownText;
      messenger.showErrorSnackBar(
        theme: theme,
        text: exceptionText,
      );
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during deck invite insert', e, s);
      messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorUnknownText,
      );
    } finally {
      _showGenerateLinkLoadingIndicator.add(false);
    }
  }

  Future<void> _copyLinkToClipboard(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    _showCopiedLinkIndicator.add(true);
    await Future.delayed(const Duration(seconds: 3));
    if (!_showCopiedLinkIndicator.isClosed) {
      _showCopiedLinkIndicator.add(false);
    }
  }

  void _handleShare(String link) => Share.share(link);

  Future<void> _deleteDeckInvite(DeckInvite deckInvite) async {
    _showDeleteLinkLoadingIndicator.add(true);
    await _deckInviteRepository.remove(deckInvite);
  }

  void _handleOperationException(
    OperationException e,
    StackTrace s,
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
  ) {
    var exceptionText = i18n.errorUnknownText;
    if (e.isNoInternet) {
      exceptionText = i18n.errorNoInternetText;
    } else if (e.isServerOffline) {
      exceptionText = i18n.errorWeWillFixText;
    } else if (e.isIncorrectEmailPassword) {
      exceptionText = i18n.errorIncorrectEmailPasswordText;
    } else {
      _logger.severe('Unexpected operation exception during log in', e, s);
    }

    messenger.showErrorSnackBar(
      theme: theme,
      text: exceptionText,
    );
  }
}
