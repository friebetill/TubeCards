import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/locale.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/deck.dart';
import '../../../../data/models/deck_member.dart';
import '../../../../data/models/unsplash_image.dart';
import '../../../../data/models/user.dart';
import '../../../../data/repositories/deck_member_repository.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/permission.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../deck/component/delete_dialog.dart';
import '../../../deck/deck_page.dart';
import '../../../home/component/leave_dialog.dart';
import '../../../home/home_page.dart';
import '../../../home/util/error_util.dart';
import '../../../text_to_speech/service/on_device_text_to_speech_service.dart';
import '../language_picker_dialog.dart';
import 'upsert_deck_component.dart';
import 'upsert_deck_view_model.dart';

/// BLoC for the [UpsertDeckComponent].
///
/// Exposes a [UpsertDeckViewModel] for that component to use.
@injectable
class UpsertDeckBloc with ComponentBuildContext, ComponentLifecycleListener {
  UpsertDeckBloc(
    this._userRepository,
    this._deckRepository,
    this._deckMemberRepository,
    this._tts,
  );

  final UserRepository _userRepository;
  final DeckRepository _deckRepository;
  final DeckMemberRepository _deckMemberRepository;
  final OnDeviceTextToSpeechService _tts;

  final _logger = Logger((UpsertDeckBloc).toString());

  Deck? _existingDeck;

  final BehaviorSubject<Deck> _deck = BehaviorSubject();
  final _showUpsertLoadingIndicator = BehaviorSubject<bool>.seeded(false);
  final _showDeleteLoadingIndicator = BehaviorSubject.seeded(false);
  final _showLeaveLoadingIndicator = BehaviorSubject.seeded(false);

  Stream<UpsertDeckViewModel>? _viewModel;
  Stream<UpsertDeckViewModel>? get viewModel => _viewModel;

  Stream<UpsertDeckViewModel> createViewModel(String? deckId) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    if (deckId != null) {
      _deck.addStream(
        _deckRepository
            .get(deckId)
            .take(1)
            .doOnData((deck) => _existingDeck = deck),
      );
    } else {
      _deck.add(
        Deck(
          name: '',
          description: '',
          coverImage: defaultCoverImage,
          createMirrorCard: false,
        ),
      );
    }

    return _viewModel = Rx.combineLatest6(
      _userRepository.viewer(),
      _deck,
      _tts.getSupportedLocales().asStream(),
      _showUpsertLoadingIndicator,
      _showDeleteLoadingIndicator,
      _showLeaveLoadingIndicator,
      _createViewModel,
    );
  }

  UpsertDeckViewModel _createViewModel(
    User? user,
    Deck deck,
    List<Locale> ttsLocales,
    bool showUpsertLoadingIndicator,
    bool showDeleteLoadingIndicator,
    bool showLeaveLoadingIndicator,
  ) {
    final isEdit = _existingDeck != null;
    final hasDeckUpdatePermission = deck.viewerDeckMember != null &&
        deck.viewerDeckMember!.role!.hasPermission(Permission.deckUpdate);
    final hasDeletePermission = deck.viewerDeckMember != null &&
        deck.viewerDeckMember!.role!.hasPermission(Permission.deckDelete);
    final hasCardUpsertPermission = deck.viewerDeckMember != null &&
        deck.viewerDeckMember!.role!.hasPermission(Permission.cardUpsert);

    return UpsertDeckViewModel(
      name: deck.name!,
      description: deck.description!,
      isActive: deck.viewerDeckMember?.isActive ?? true,
      coverImage: deck.coverImage!,
      isBidirectionalDeck: deck.createMirrorCard!,
      showUpsertLoadingIndicator: showUpsertLoadingIndicator,
      showLeaveLoadingIndicator: showLeaveLoadingIndicator,
      showDeleteLoadingIndicator: showDeleteLoadingIndicator,
      isEdit: _existingDeck?.id != null,
      hasCardUpsertPermission: hasCardUpsertPermission,
      onNameChanged:
          !isEdit || hasDeckUpdatePermission ? _handleNameChange : null,
      onDescriptionChange:
          !isEdit || hasDeckUpdatePermission ? _handleDescriptionChange : null,
      onIsActiveChange: _handleIsActiveChange,
      onChangeImageTap:
          !isEdit || hasDeckUpdatePermission ? _handleImageChange : null,
      onCreateMirrorCardChange:
          !isEdit || hasDeckUpdatePermission ? _handleMirrorCardChange : null,
      onUpsertTap: () => _handleUpsertTap(user!),
      onBackTap: CustomNavigator.getInstance().pop,
      frontLocale: Locale.tryParse(deck.frontLanguage ?? ''),
      backLocale: Locale.tryParse(deck.backLanguage ?? ''),
      onTtsLanguagesTap:
          !isEdit || hasDeckUpdatePermission ? _handleTtsLanguagesTap : null,
      ttsLocales: ttsLocales,
      onLeaveTap:
          isEdit && !hasDeletePermission ? () => _handleLeaveTap(deck) : null,
      onDeleteTap:
          isEdit && hasDeletePermission ? () => _handleDeleteTap(deck) : null,
    );
  }

  @override
  Future<void> dispose() async {
    await _showUpsertLoadingIndicator.close();
    await _showDeleteLoadingIndicator.close();
    super.dispose();
  }

  void _handleNameChange(String name) {
    _deck.add(_deck.value.copyWith(name: name));
  }

  void _handleDescriptionChange(String description) {
    _deck.add(_deck.value.copyWith(description: description));
  }

  void _handleIsActiveChange(bool isActive) {
    _deck.add(
      _deck.value.copyWith(
        viewerDeckMember: _deck.value.viewerDeckMember!.copyWith(
          isActive: isActive,
        ),
      ),
    );
  }

  void _handleImageChange(UnsplashImage coverImage) {
    _deck.add(_deck.value.copyWith(coverImage: coverImage));
  }

  void _handleMirrorCardChange(bool createMirrorCard) {
    _deck.add(_deck.value.copyWith(createMirrorCard: createMirrorCard));
  }

  Future<void> _handleUpsertTap(User user) async {
    if (_showUpsertLoadingIndicator.value ||
        _showDeleteLoadingIndicator.value) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final isEdit = _existingDeck != null;
    final isDeckUpdateNecessary = !isEdit ||
        _existingDeck!.name != _deck.value.name ||
        _existingDeck!.description != _deck.value.description ||
        _existingDeck!.coverImage != _deck.value.coverImage ||
        _existingDeck!.createMirrorCard != _deck.value.createMirrorCard ||
        _existingDeck!.frontLanguage != _deck.value.frontLanguage ||
        _existingDeck!.backLanguage != _deck.value.backLanguage;
    final isDeckMemberUpdateNecessary = isEdit &&
        _existingDeck!.viewerDeckMember!.isActive !=
            _deck.value.viewerDeckMember!.isActive;

    if (!isDeckUpdateNecessary && !isDeckMemberUpdateNecessary) {
      // Exit if the deck is unchanged.
      return Navigator.pop(context);
    } else {
      _showUpsertLoadingIndicator.add(true);

      Deck? upsertedDeck;
      if (isDeckUpdateNecessary) {
        try {
          upsertedDeck = await _deckRepository.upsert(_deck.value.copyWith(
            name: _deck.value.name!.isNotEmpty
                ? _deck.value.name
                : S.of(context).untitled,
          ));
        } on OperationException catch (e) {
          _showUpsertLoadingIndicator.add(false);

          return messenger.showErrorSnackBar(
            theme: theme,
            text: e.isNoInternet
                ? i18n.errorNoInternetText
                : isEdit
                    ? i18n.errorUpdateDeckText
                    : i18n.errorAddDeckText,
          );
        }
      }

      if (isDeckMemberUpdateNecessary) {
        final deckMember = DeckMember(
          deck: Deck(id: _existingDeck!.id!),
          user: User(id: user.id!),
          isActive: _deck.value.viewerDeckMember!.isActive,
        );

        try {
          await _deckMemberRepository.update(deckMember);
        } on OperationException catch (e) {
          _showUpsertLoadingIndicator.add(false);

          return messenger.showErrorSnackBar(
            theme: theme,
            text: e.isNoInternet
                ? i18n.errorNoInternetText
                : isEdit
                    ? i18n.errorUpdateDeckText
                    : i18n.errorAddDeckText,
          );
        }
      }
      _showUpsertLoadingIndicator.add(false);

      if (isEdit) {
        CustomNavigator.getInstance().pop();
      } else {
        await CustomNavigator.getInstance().pushReplacementNamed(
          DeckPage.routeName,
          args: DeckArguments(
            deckId: upsertedDeck!.id!,
            hasCardUpsertPermission: upsertedDeck.viewerDeckMember!.role!
                .hasPermission(Permission.cardUpsert),
          ),
        );
      }
    }
  }

  void _handleTtsLanguagesTap() {
    showDialog<void>(
      context: context,
      builder: (context) => LanguagePickerDialog(
        frontLocale: Locale.tryParse(_deck.value.frontLanguage ?? ''),
        backLocale: Locale.tryParse(_deck.value.backLanguage ?? ''),
        onSave: (frontLocale, backLocale) {
          if (frontLocale != null) {
            _deck.add(
              _deck.value.copyWith(frontLanguage: frontLocale.toLanguageTag()),
            );
          }
          if (backLocale != null) {
            _deck.add(
              _deck.value.copyWith(backLanguage: backLocale.toLanguageTag()),
            );
          }
          CustomNavigator.getInstance().pop();
        },
      ),
    );
  }

  Future<void> _handleLeaveTap(Deck deck) async {
    if (_showUpsertLoadingIndicator.value || _showLeaveLoadingIndicator.value) {
      return;
    }

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

    CustomNavigator.getInstance().popUntil(
      ModalRoute.withName(HomePage.routeName),
    );
  }

  Future<void> _handleDeleteTap(Deck deck) async {
    if (_showUpsertLoadingIndicator.value ||
        _showDeleteLoadingIndicator.value) {
      return;
    }

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

    CustomNavigator.getInstance().popUntil(
      ModalRoute.withName(HomePage.routeName),
    );
  }
}
