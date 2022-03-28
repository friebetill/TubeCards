import 'package:flutter/material.dart';

import '../../../../utils/custom_navigator.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/cover_image.dart';
import '../../../../widgets/page_callback_shortcuts.dart';

class UpsertDeckSkeleton extends StatelessWidget {
  const UpsertDeckSkeleton({this.deckId, Key? key}) : super(key: key);

  final String? deckId;

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(''),
          elevation: 0,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: CustomNavigator.getInstance().pop,
            tooltip: backTooltip(context),
          ),
        ),
        body: Column(
          children: const [
            Center(child: CoverImage(imageUrl: null)),
          ],
        ),
      ),
    );
  }
}
