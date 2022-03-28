import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/themes/custom_theme.dart';
import 'upsert_card_component.dart';

class UpsertCardSkeleton extends StatelessWidget {
  const UpsertCardSkeleton({
    required this.isFrontSide,
    Key? key,
  }) : super(key: key);

  final bool isFrontSide;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: _buildDummyTabBar(context),
      ),
    );
  }

  PreferredSizeWidget _buildDummyTabBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(tabControlHeight),
      child: Expanded(
        child: Row(
          children: [
            Expanded(
              child: _buildDummyTab(
                context,
                text: S.of(context).question,
                isEmphasized: isFrontSide,
              ),
            ),
            Expanded(
              child: _buildDummyTab(
                context,
                text: S.of(context).answer,
                isEmphasized: !isFrontSide,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDummyTab(
    BuildContext context, {
    required String text,
    required bool isEmphasized,
  }) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .color!
                    .withOpacity(isEmphasized ? 1 : 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Container(
            height: 2,
            color: isEmphasized
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).custom.elevation4DPColor),
      ],
    );
  }
}
