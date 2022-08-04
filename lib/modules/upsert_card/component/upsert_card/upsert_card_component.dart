import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../utils/logging/interaction_logger.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../utils/pop_menu_choice.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/editor/card_side_editor.dart';
import '../../../../widgets/editor/editor_shortcuts.dart';
import '../../../../widgets/editor/toolbar.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/visual_element.dart';
import 'upsert_card_bloc.dart';
import 'upsert_card_skeleton.dart';
import 'upsert_card_view_model.dart';

const elevation = 4.0;
const tabControlHeight = 56.0;

class UpsertCardComponent extends StatelessWidget {
  const UpsertCardComponent({
    required this.deckId,
    this.cardId,
    this.isFrontSide = true,
    Key? key,
  }) : super(key: key);

  final String deckId;
  final String? cardId;
  final bool isFrontSide;

  @override
  Widget build(BuildContext context) {
    return Component<UpsertCardBloc>(
      createViewModel: (bloc) => bloc.createViewModel(
        deckId: deckId,
        cardId: cardId,
        isFrontSide: isFrontSide,
      ),
      builder: (context, bloc) {
        return StreamBuilder<UpsertCardViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return UpsertCardSkeleton(isFrontSide: isFrontSide);
            }

            return _UpsertCardView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _UpsertCardView extends StatefulWidget {
  const _UpsertCardView(this.viewModel);

  final UpsertCardViewModel viewModel;

  @override
  _UpsertCardViewState createState() => _UpsertCardViewState();
}

class _UpsertCardViewState extends State<_UpsertCardView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late FocusNode _frontFocus;
  late FocusNode _backFocus;

  // Prefer a separate variable, because _tabController.index is only
  // updated when the swipe animation is finished. This is too late,
  // because we call the setState as soon as the animation value is above
  // or below 0.5.
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _frontFocus = FocusNode()
      ..addListener(() => setState(() => _currentTabIndex = 0));
    _backFocus = FocusNode()
      ..addListener(() => setState(() => _currentTabIndex = 1));

    _tabController = TabController(
      initialIndex:
          widget.viewModel.forcedActiveCardSide.or(CardSide.front).index,
      vsync: this,
      length: 2,
    )..animation!.addListener(() {
        if (!mounted) {
          return;
        }

        if (_tabController.animation!.value > 0.5) {
          setState(() => _currentTabIndex = 1);
          if (_frontFocus.hasFocus) {
            _backFocus.requestFocus();
          }
        } else if (_tabController.animation!.value < 0.5) {
          setState(() => _currentTabIndex = 0);
          if (_backFocus.hasFocus) {
            _frontFocus.requestFocus();
          }
        }
      });
  }

  @override
  void didUpdateWidget(_UpsertCardView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.viewModel.forcedActiveCardSide.isPresent && mounted) {
      _tabController
          .animateTo(widget.viewModel.forcedActiveCardSide.value.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        LogicalKeySet(LogicalKeyboardKey.escape): () {
          if (_frontFocus.hasFocus || _backFocus.hasFocus) {
            _frontFocus.unfocus(
              disposition: UnfocusDisposition.previouslyFocusedChild,
            );
            _backFocus.unfocus(
              disposition: UnfocusDisposition.previouslyFocusedChild,
            );
          } else {
            CustomNavigator.getInstance().pop();
          }
        },
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  EditorShortcuts(
                    controller: widget.viewModel.frontController,
                    onSwitchCardSideShortcut: () => _tabController.animateTo(1),
                    onUpsertShortcut: widget.viewModel.onUpsertTap,
                    child: CardSideEditor(
                      key: const ValueKey('front-editor'),
                      readOnly: !widget.viewModel.hasEditPermission,
                      focusNode: _frontFocus,
                      placeholder: !widget.viewModel.isMirrorCard
                          ? S.of(context).question
                          : '${S.of(context).question} / ${S.of(context).answer}',
                      controller: widget.viewModel.frontController,
                    ),
                  ),
                  EditorShortcuts(
                    controller: widget.viewModel.backController,
                    onSwitchCardSideShortcut: () => _tabController.animateTo(0),
                    onUpsertShortcut: widget.viewModel.onUpsertTap,
                    child: CardSideEditor(
                      key: const ValueKey('back-editor'),
                      readOnly: !widget.viewModel.hasEditPermission,
                      focusNode: _backFocus,
                      placeholder: !widget.viewModel.isMirrorCard
                          ? S.of(context).answer
                          : '${S.of(context).answer} / ${S.of(context).question}',
                      controller: widget.viewModel.backController,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.viewModel.hasEditPermission)
              Toolbar(
                controller: _currentTabIndex == 0
                    ? widget.viewModel.frontController
                    : widget.viewModel.backController,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _frontFocus.dispose();
    _backFocus.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    final title = widget.viewModel.isEdit
        ? (widget.viewModel.hasEditPermission
            ? S.of(context).editCard
            : S.of(context).viewCard)
        : S.of(context).addCard;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: _buildLeadingIcon(context),
      title: _frontFocus.hasFocus || _backFocus.hasFocus
          ? _buildTabControl(context)
          : Text(title),
      elevation: elevation,
      actions: _buildActions(context),
      bottom: _frontFocus.hasFocus || _backFocus.hasFocus
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(tabControlHeight),
              child: _buildTabControl(context),
            ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    return _frontFocus.hasFocus || _backFocus.hasFocus
        ? IconButton(
            key: const ValueKey('close-button'),
            icon: const BackButtonIcon(),
            tooltip: backTooltip(context),
            onPressed: () {
              _frontFocus.unfocus(
                disposition: UnfocusDisposition.previouslyFocusedChild,
              );
              _backFocus.unfocus(
                disposition: UnfocusDisposition.previouslyFocusedChild,
              );
            },
          )
        : VisualElement(
            id: VEs.backButton,
            childBuilder: (controller) {
              return IconButton(
                icon: const BackButtonIcon(),
                onPressed: () {
                  controller.logTap();
                  CustomNavigator.getInstance().pop();
                },
                tooltip: backTooltip(context),
              );
            },
          );
  }

  List<Widget> _buildActions(BuildContext context) {
    final choices = <PopupMenuChoice>[
      if (widget.viewModel.onMoveTap != null)
        PopupMenuChoice(
            title: S.of(context).moveTo,
            action: () {
              InteractionLogger.getInstance().logTap(VEs.moveCardMenuChoice);
              widget.viewModel.onMoveTap!();
            }),
      if (widget.viewModel.onDeleteTap != null)
        PopupMenuChoice(
          title: S.of(context).delete,
          action: () {
            InteractionLogger.getInstance().logTap(VEs.deleteCardMenuChoice);
            widget.viewModel.onDeleteTap!();
          },
        ),
    ];

    final addCardTooltip = buildTooltipMessage(
      message: S.of(context).addCard,
      windowsShortcut: 'Ctrl + Enter',
      macosShortcut: '⌘ + Enter',
      linuxShortcut: 'Ctrl + Enter',
    );
    final saveChangesTooltip = buildTooltipMessage(
      message: S.of(context).saveChanges,
      windowsShortcut: 'Ctrl + Enter',
      macosShortcut: '⌘ + Enter',
      linuxShortcut: 'Ctrl + Enter',
    );

    return <Widget>[
      VisualElement(
        id: VEs.upsertCardButton,
        childBuilder: (controller) {
          return IconButton(
            icon: widget.viewModel.isLoading
                ? const IconSizedLoadingIndicator()
                : const Icon(Icons.done_outlined),
            tooltip: widget.viewModel.isEdit
                ? widget.viewModel.hasEditPermission
                    ? saveChangesTooltip.toString()
                    : S.of(context).noPermission
                : addCardTooltip.toString(),
            onPressed: widget.viewModel.onUpsertTap != null
                ? () {
                    controller.logTap();
                    widget.viewModel.onUpsertTap!();
                  }
                : null,
            color: Theme.of(context).colorScheme.primary,
          );
        },
      ),
      if (widget.viewModel.isEdit && widget.viewModel.hasEditPermission)
        PopupMenuButton<PopupMenuChoice>(
          onSelected: (choice) => choice.action(),
          itemBuilder: (context) {
            return choices.map((choice) {
              return PopupMenuItem<PopupMenuChoice>(
                value: choice,
                child: Text(choice.title),
              );
            }).toList();
          },
        ),
    ];
  }

  Widget _buildTabControl(BuildContext context) {
    return TabBar(
      labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      controller: _tabController,
      tabs: <Widget>[
        Tab(
          key: const Key('front-tab'),
          text: !widget.viewModel.isMirrorCard
              ? S.of(context).question
              : '${S.of(context).question} / ${S.of(context).answer}',
        ),
        Tab(
          key: const Key('back-tab'),
          text: !widget.viewModel.isMirrorCard
              ? S.of(context).answer
              : '${S.of(context).answer} / ${S.of(context).question}',
        ),
      ],
    );
  }
}
