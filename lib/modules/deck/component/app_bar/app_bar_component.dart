import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../utils/pop_menu_choice.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/visual_element.dart';
import 'app_bar_bloc.dart';
import 'app_bar_view_model.dart';

class AppBarComponent extends StatefulWidget implements PreferredSizeWidget {
  const AppBarComponent(
    this.deckId,
    this.onEditTap,
    this.onBackTap,
    this.onManageMembersTap, {
    Key? key,
  }) : super(key: key);

  final VoidCallback onBackTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onManageMembersTap;
  final String deckId;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  AppBarComponentState createState() => AppBarComponentState();
}

class AppBarComponentState extends State<AppBarComponent> {
  @override
  Widget build(BuildContext context) {
    return Component<AppBarBloc>(
      createViewModel: (bloc) => bloc.createViewModel(
        widget.deckId,
        widget.onEditTap,
        widget.onManageMembersTap,
      ),
      builder: (context, bloc) {
        return StreamBuilder<AppBarViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _AppBarSkeleton();
            }

            return snapshot.data!.markedCardsIds.isEmpty
                ? _AppBarView(snapshot.data!)
                : _MarkedCardsAppBarView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _AppBarView extends StatelessWidget {
  const _AppBarView(this.viewModel);

  final AppBarViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final onSettingsTapTooltip = buildTooltipMessage(
      message: S.of(context).settings,
      windowsShortcut: 'Ctrl + e',
      macosShortcut: '⌘ + e',
      linuxShortcut: 'Ctrl + e',
    );
    final onManageMemberTapToolTip = buildTooltipMessage(
      message: S.of(context).manageMembers,
      windowsShortcut: 'Ctrl + m',
      macosShortcut: '⌘ + m',
      linuxShortcut: 'Ctrl + m',
    );

    return AppBar(
      title: Text(viewModel.deckName),
      elevation: 0,
      leading: IconButton(
        icon: const BackButtonIcon(),
        onPressed: viewModel.onBackTap,
        tooltip: backTooltip(context),
      ),
      actions: [
        if (viewModel.onManageMembersTap != null)
          VisualElement(
            id: VEs.manageMembersButton,
            childBuilder: (controller) {
              return IconButton(
                icon: const Icon(Icons.group_outlined),
                onPressed: () {
                  controller.logTap();
                  viewModel.onManageMembersTap!();
                },
                tooltip: onManageMemberTapToolTip.toString(),
              );
            },
          )
        else if (viewModel.onOfferTap != null)
          VisualElement(
            id: VEs.offerButton,
            childBuilder: (controller) {
              return IconButton(
                icon: const Icon(Icons.store_outlined),
                onPressed: () {
                  controller.logTap();
                  viewModel.onOfferTap!();
                },
                tooltip: S.of(context).store,
              );
            },
          ),
        VisualElement(
          id: VEs.deckSettingsButton,
          childBuilder: (controller) {
            return IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: viewModel.onSettingsTap != null
                  ? () {
                      controller.logTap();
                      viewModel.onSettingsTap!();
                    }
                  : null,
              tooltip: viewModel.onSettingsTap != null
                  ? onSettingsTapTooltip.toString()
                  : S.of(context).noPermission,
            );
          },
        ),
      ],
    );
  }
}

class _MarkedCardsAppBarView extends StatelessWidget {
  const _MarkedCardsAppBarView(this.viewModel);

  final AppBarViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: viewModel.onWillPop,
      child: AppBar(
        title: Text(
          viewModel.markedCardsIds.length.toString(),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const BackButtonIcon(),
          color: Theme.of(context).colorScheme.primary,
          onPressed: viewModel.onBackTap,
          tooltip: backTooltip(context),
        ),
        actions: [
          _buildDeleteIcon(context),
          if (viewModel.hasEditCardPermission) _buildPopupMenu(context),
        ],
      ),
    );
  }

  Widget _buildDeleteIcon(BuildContext context) {
    return IconButton(
      icon: !viewModel.showDeleteLoadingIndicator
          ? const Icon(Icons.delete_outlined)
          : const IconSizedLoadingIndicator(),
      color: Theme.of(context).colorScheme.primary,
      onPressed:
          viewModel.hasDeleteCardPermission ? viewModel.onDeleteTap : null,
      tooltip: S.of(context).delete,
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    final choices = <PopupMenuChoice>[
      if (viewModel.decksCount > 1)
        PopupMenuChoice(
          title: S.of(context).moveTo,
          action: viewModel.onMoveTap,
        ),
    ];

    if (choices.isEmpty) {
      return Container();
    }

    return PopupMenuButton<PopupMenuChoice>(
      icon: !viewModel.showPopupMenuLoadingIndicator
          ? Icon(
              Icons.more_vert_outlined,
              color: Theme.of(context).colorScheme.primary,
            )
          : const IconSizedLoadingIndicator(),
      onSelected: (choice) => choice.action(),
      itemBuilder: (context) => choices
          .map((choice) => PopupMenuItem<PopupMenuChoice>(
                value: choice,
                child: Text(choice.title),
              ))
          .toList(),
    );
  }
}

class _AppBarSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onSettingsTapTooltip = buildTooltipMessage(
      message: S.of(context).settings,
      windowsShortcut: 'Ctrl + e',
      macosShortcut: '⌘ + e',
      linuxShortcut: 'Ctrl + e',
    );

    return AppBar(
      title: const Text(''),
      elevation: 0,
      leading: IconButton(
        onPressed: CustomNavigator.getInstance().pop,
        icon: const BackButtonIcon(),
        tooltip: backTooltip(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: null,
          tooltip: onSettingsTapTooltip.toString(),
        ),
      ],
    );
  }
}
