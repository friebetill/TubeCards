import 'dart:io';

import 'package:flutter/material.dart';

import '../../../utils/icon_sized_loading_indicator.dart';
import '../../../utils/logging/visual_element_ids.dart';
import '../../../widgets/visual_element.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    required this.ignoreClicks,
    required this.userAvatar,
    required this.isRefreshLoading,
    required this.onRefreshTap,
    Key? key,
  }) : super(key: key);

  final bool ignoreClicks;
  final bool isRefreshLoading;
  final Widget userAvatar;
  final VoidCallback onRefreshTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return AppBar(
      // Necessary because the title is not centered by default on Android
      centerTitle: true,
      leading: isDesktop
          ? AbsorbPointer(
              absorbing: ignoreClicks,
              child: VisualElement(
                id: VEs.reloadButton,
                childBuilder: (controller) {
                  return IconButton(
                    onPressed: () {
                      controller.logTap();
                      onRefreshTap();
                    },
                    icon: isRefreshLoading
                        ? IconSizedLoadingIndicator(
                            color: Theme.of(context).colorScheme.onBackground,
                          )
                        : const Icon(Icons.refresh),
                  );
                },
              ),
            )
          : null,
      actions: <Widget>[
        AbsorbPointer(
          absorbing: ignoreClicks,
          child: userAvatar,
        ),
      ],
      elevation: 0,
    );
  }
}
