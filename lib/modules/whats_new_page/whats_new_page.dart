import 'package:flutter/cupertino.dart';

import '../../utils/release_notes.dart';
import 'component/whats_new_component.dart';

class WhatsNewPage extends StatelessWidget {
  WhatsNewPage(this.args) : super(key: args.key);

  /// The name of the route to the [WhatsNewPage] screen.
  static const String routeName = '/whats-new';

  /// The arguments this class can get.
  final WhatsNewPageArguments args;

  @override
  Widget build(BuildContext context) => WhatsNewComponent(args: args);
}

/// Bundles the arguments of [WhatsNewPage] into one object.
///
/// This allows us to use multiple parameters on Named Routes.
/// See more about this here https://bit.ly/3ifEOpa.
class WhatsNewPageArguments {
  /// Returns an instance of [WhatsNewPageArguments].
  WhatsNewPageArguments({
    required this.releaseNote,
    required this.onContinueTap,
    this.key,
  });

  /// Controls how one widget replaces another widget in the tree.
  final Key? key;

  final ReleaseNote releaseNote;

  final VoidCallback onContinueTap;
}
