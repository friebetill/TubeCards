import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../i18n/i18n.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../home/component/deck_invitation/accept_deck_invite_component.dart';
import 'join_shared_deck_component.dart';
import 'join_shared_deck_view_model.dart';

/// BLoC for the [JoinSharedDeckComponent].
///
/// Exposes a [JoinSharedDeckViewModel] for that component to use.
@injectable
class JoinSharedDeckBloc
    with ComponentLifecycleListener, ComponentBuildContext {
  JoinSharedDeckBloc();

  Stream<JoinSharedDeckViewModel>? _viewModel;
  Stream<JoinSharedDeckViewModel>? get viewModel => _viewModel;

  final _linkErrorText = BehaviorSubject<String?>.seeded(null);
  final _isLoading = BehaviorSubject.seeded(false);
  final _emailTextController = TextEditingController();

  Stream<JoinSharedDeckViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest2(
      _linkErrorText,
      _isLoading,
      _createViewModel,
    );
  }

  JoinSharedDeckViewModel _createViewModel(
    String? linkErrorText,
    bool isLoading,
  ) {
    return JoinSharedDeckViewModel(
      linkErrorText: linkErrorText,
      isLoading: isLoading,
      onJoinTap: _handleJoinTap,
      onPasteLinkTap: _handlePasteLinkTap,
      emailTextController: _emailTextController,
    );
  }

  @override
  void dispose() {
    _linkErrorText.close();
    _isLoading.close();
    _emailTextController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinTap() async {
    final isUrl =
        Uri.tryParse(_emailTextController.text)?.hasAbsolutePath ?? false;
    if (!isUrl) {
      return _linkErrorText.add(S.of(context).deckInvitationNotValidText);
    }

    await showModalBottomSheet(
      context: context,
      builder: (_) => AcceptDeckInviteComponent(_emailTextController.text),
    );
  }

  Future<void> _handlePasteLinkTap() async {
    final clipboard = await Clipboard.getData('text/plain');
    if (clipboard?.text != null) {
      _emailTextController.text = clipboard!.text!;
    }
  }
}
