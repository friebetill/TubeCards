import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../utils/text_size.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/adaptive_list_tile.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/cover_image.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/visual_element.dart';
import '../../../text_to_speech/utils/locales_match_util.dart';
import 'upsert_deck_bloc.dart';
import 'upsert_deck_skeleton.dart';
import 'upsert_deck_view_model.dart';

class UpsertDeckComponent extends StatelessWidget {
  const UpsertDeckComponent({this.deckId, Key? key}) : super(key: key);

  final String? deckId;

  @override
  Widget build(BuildContext context) {
    return Component<UpsertDeckBloc>(
      createViewModel: (bloc) => bloc.createViewModel(deckId),
      builder: (context, bloc) {
        return StreamBuilder<UpsertDeckViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const UpsertDeckSkeleton();
            }

            return _UpsertDeckView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _UpsertDeckView extends StatefulWidget {
  const _UpsertDeckView({required this.viewModel, Key? key}) : super(key: key);

  final UpsertDeckViewModel viewModel;

  @override
  _UpsertDeckViewState createState() => _UpsertDeckViewState();
}

class _UpsertDeckViewState extends State<_UpsertDeckView> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  LocalizedTtsLanguages? _ttsLanguages;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.viewModel.name);
    _descriptionController =
        TextEditingController(text: widget.viewModel.description);
  }

  @override
  void didChangeDependencies() {
    _ttsLanguages ??=
        LocalizedTtsLanguages(context, widget.viewModel.ttsLocales);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        LogicalKeySet(LogicalKeyboardKey.escape): widget.viewModel.onBackTap,
        LogicalKeySet(
          Platform.isMacOS
              ? LogicalKeyboardKey.meta
              : LogicalKeyboardKey.control,
          LogicalKeyboardKey.enter,
        ): widget.viewModel.onUpsertTap,
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Center(
          child: ListView(
            children: [
              _buildCoverImage(),
              const SizedBox(height: 16),
              _buildTitle(),
              _buildDescription(),
              const SizedBox(height: 16),
              if (widget.viewModel.hasCardUpsertPermission)
                _buildBidirectionalLearningTile(),
              _buildLanguagesListTile(),
              const SizedBox(height: 16),
              if (widget.viewModel.isEdit) _buildIsActiveTile(),
              if (widget.viewModel.onDeleteTap != null)
                _buildDeleteTile()
              else if (widget.viewModel.onLeaveTap != null)
                _buildLeaveTile(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final createDeckToolTip = buildTooltipMessage(
      message: S.of(context).createDeck,
      windowsShortcut: 'Ctrl + Enter',
      macosShortcut: '⌘ + Enter',
      linuxShortcut: 'Ctrl + Enter',
    );

    return AppBar(
      elevation: 0,
      title: Text(widget.viewModel.isEdit
          ? S.of(context).settings
          : S.of(context).createDeck),
      actions: <Widget>[
        VisualElement(
          id: VEs.upsertDeckButton,
          childBuilder: (controller) {
            return IconButton(
              icon: widget.viewModel.showUpsertLoadingIndicator
                  ? const IconSizedLoadingIndicator()
                  : const Icon(Icons.done_outlined),
              tooltip: widget.viewModel.isEdit
                  ? saveTooltip(context)
                  : createDeckToolTip.toString(),
              onPressed: () {
                controller.logTap();
                widget.viewModel.onUpsertTap();
              },
              color: Theme.of(context).colorScheme.primary,
            );
          },
        ),
      ],
      leading: VisualElement(
        id: VEs.backButton,
        childBuilder: (controller) {
          return IconButton(
            icon: const BackButtonIcon(),
            onPressed: () {
              controller.logTap();
              widget.viewModel.onBackTap();
            },
            tooltip: backTooltip(context),
          );
        },
      ),
    );
  }

  Widget _buildCoverImage() {
    return CoverImage(
      imageUrl: widget.viewModel.coverImage.regularUrl,
      onCoverImageChange: widget.viewModel.onChangeImageTap,
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: TextField(
          controller: _nameController,
          onChanged: widget.viewModel.onNameChanged,
          style: Theme.of(context).textTheme.headline4,
          decoration: InputDecoration(
            hintText: S.of(context).untitled,
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
            border: InputBorder.none,
          ),
          autofocus: !widget.viewModel.isEdit,
          autocorrect: false,
          readOnly: widget.viewModel.onNameChanged == null,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: widget.viewModel.onUpsertTap,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final readOnly = widget.viewModel.onDescriptionChange == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: TextField(
          controller: _descriptionController,
          onChanged: widget.viewModel.onDescriptionChange,
          decoration: InputDecoration(
            hintText: S.of(context).describeYourDeck,
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
            isDense: true,
            border: InputBorder.none,
          ),
          autocorrect: false,
          readOnly: readOnly,
          maxLength: !readOnly ? 150 : null,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
    );
  }

  var _isActiveTileThreeLine = true;
  Widget _buildIsActiveTile() {
    return ListTileAdapter(
      child: SwitchListTile.adaptive(
        title: Text(S.of(context).activeDeck),
        subtitle: LayoutBuilder(builder: (context, constraints) {
          final subtitle = S.of(context).activeDecksSubtitleText;
          final subtitleSize = textSize(subtitle);
          final isThreeLine = subtitleSize.width > constraints.maxWidth;
          if (isThreeLine != _isActiveTileThreeLine) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _isActiveTileThreeLine = isThreeLine);
            });
          }

          return Text(subtitle);
        }),
        value: widget.viewModel.isActive,
        onChanged: widget.viewModel.onIsActiveChange,
        isThreeLine: _isActiveTileThreeLine,
        secondary: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Icon(Icons.visibility_outlined),
        ),
      ),
    );
  }

  var _isBidirectionalLearningTileThreeLine = true;
  Widget _buildBidirectionalLearningTile() {
    return ListTileAdapter(
      child: SwitchListTile.adaptive(
        title: Text(S.of(context).bidirectionalLearning),
        subtitle: LayoutBuilder(builder: (context, constraints) {
          final subtitle = S.of(context).twoCardsWithReversedSides;
          final subtitleSize = textSize(subtitle);
          final isThreeLine = subtitleSize.width > constraints.maxWidth;
          if (isThreeLine != _isBidirectionalLearningTileThreeLine) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _isBidirectionalLearningTileThreeLine = isThreeLine;
              });
            });
          }

          return Text(subtitle);
        }),
        value: widget.viewModel.isBidirectionalDeck,
        onChanged: widget.viewModel.onCreateMirrorCardChange,
        isThreeLine: _isBidirectionalLearningTileThreeLine,
        secondary: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Icon(Icons.compare_arrows_outlined),
        ),
      ),
    );
  }

  Widget _buildLanguagesListTile() {
    return ListTileAdapter(
      child: ListTile(
        title: Text(S.of(context).readAloudLanguage),
        subtitle: Text(
          _getLanguagesListTileSubtitle(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: widget.viewModel.onTtsLanguagesTap,
        enabled: widget.viewModel.onTtsLanguagesTap != null,
        // Ensure the icon is vertically centered.
        leading: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Icon(Icons.language),
        ),
      ),
    );
  }

  String _getLanguagesListTileSubtitle() {
    final frontLanguage =
        _ttsLanguages!.getDisplayName(widget.viewModel.frontLocale);
    final backLanguage =
        _ttsLanguages!.getDisplayName(widget.viewModel.backLocale);

    if (frontLanguage == null && backLanguage == null) {
      return S.of(context).noLanguagesSelected;
    }

    return [
      frontLanguage ?? S.of(context).missing,
      backLanguage ?? S.of(context).missing,
    ].join(', ');
  }

  Widget _buildLeaveTile() {
    return ListTileAdapter(
      child: AdaptiveListTile(
        title: S.of(context).leave,
        subtitle: S.of(context).leaveDeckSubtitle,
        leadingIcon: widget.viewModel.showLeaveLoadingIndicator
            ? IconSizedLoadingIndicator(
                color: Theme.of(context).iconTheme.color,
              )
            : const Icon(Icons.delete_outline),
        onTap: widget.viewModel.onLeaveTap!,
      ),
    );
  }

  Widget _buildDeleteTile() {
    return ListTileAdapter(
      child: AdaptiveListTile(
        title: S.of(context).delete,
        subtitle: S.of(context).deleteDeckSubtitle,
        leadingIcon: widget.viewModel.showDeleteLoadingIndicator
            ? IconSizedLoadingIndicator(
                color: Theme.of(context).iconTheme.color,
              )
            : const Icon(Icons.delete_outline),
        onTap: widget.viewModel.onDeleteTap!,
      ),
    );
  }
}
