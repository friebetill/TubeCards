import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/deck.dart';
import '../../../../data/models/role.dart';
import '../../../../data/models/user.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/permission.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../offer/offer_page.dart';
import '../../../offer_preview/offer_preview_page.dart';
import '../share_invite_dialog/share_invite_dialog_component.dart';
import 'invites_component.dart';
import 'invites_view_model.dart';

/// BLoC for the [InvitesComponent].
///
/// Exposes a [InvitesViewModel] for that component to use.
@injectable
class InvitesBloc with ComponentBuildContext {
  InvitesBloc(this._userRepository);

  final UserRepository _userRepository;

  Stream<InvitesViewModel>? _viewModel;
  Stream<InvitesViewModel>? get viewModel => _viewModel;

  Stream<InvitesViewModel> createViewModel(Deck deck) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest2(
      Stream.value(deck),
      _userRepository.viewer(),
      _createViewModel,
    );
  }

  InvitesViewModel _createViewModel(Deck deck, User? viewer) {
    final existViewerLink =
        deck.deckInvites!.any((di) => di.inviteeRole == Role.viewer);
    final existEditorLink =
        deck.deckInvites!.any((di) => di.inviteeRole == Role.editor);

    return InvitesViewModel(
      existViewerLink: existViewerLink,
      existEditorLink: existEditorLink,
      hasViewerLinkViewAccess:
          deck.viewerDeckMember!.role!.hasPermission(Permission.viewerLinkView),
      hasViewerLinkUpsertAccess: deck.viewerDeckMember!.role!
          .hasPermission(Permission.viewerLinkUpsert),
      hasEditorLinkViewAccess:
          deck.viewerDeckMember!.role!.hasPermission(Permission.editorLinkView),
      hasEditorLinkUpsertAccess: deck.viewerDeckMember!.role!
          .hasPermission(Permission.editorLinkUpsert),
      hasPublishPermission: !viewer!.isAnonymous! &&
          deck.viewerDeckMember!.role!.hasPermission(Permission.offerAdd),
      onInviteViewerTap: () => _openShareInviteDialog(deck.id!, Role.viewer),
      onInviteEditorTap: () => _openShareInviteDialog(deck.id!, Role.editor),
      onStoreTap:
          deck.offer?.id != null ? () => _openOfferPage(deck.offer!.id!) : null,
      onPublishTap: () => _openPreviewPage(deck.id!),
    );
  }

  void _openShareInviteDialog(String deckId, Role role) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ShareInviteDialogComponent(deckId: deckId, role: role),
    );
  }

  void _openOfferPage(String offerId) {
    CustomNavigator.getInstance().pushNamed(OfferPage.routeName, args: offerId);
  }

  void _openPreviewPage(String deckId) {
    CustomNavigator.getInstance()
        .pushNamed(OfferPreviewPage.routeName, args: deckId);
  }
}
