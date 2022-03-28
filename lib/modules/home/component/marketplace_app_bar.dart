import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/logging/visual_element_ids.dart';
import '../../../widgets/visual_element.dart';

class MarketplaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MarketplaceAppBar({
    required this.userAvatar,
    required this.onSearchTap,
    Key? key,
  }) : super(key: key);

  final Widget userAvatar;
  final VoidCallback onSearchTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).colorScheme.surface,
        child: VisualElement(
          id: VEs.offerSearchButton,
          childBuilder: (controller) {
            return GestureDetector(
              onTap: () {
                controller.logTap();
                onSearchTap();
              },
              child: Container(
                color: Colors.transparent,
                height: 48,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.search,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    Text(
                      S.of(context).search,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    const Spacer(),
                    userAvatar,
                  ],
                ),
              ),
            );
          },
        ),
      ),
      elevation: 0,
    );
  }
}
