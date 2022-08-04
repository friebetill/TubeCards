import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/custom_navigator.dart';
import '../../../utils/snackbar.dart';
import '../../../widgets/component/component_build_context.dart';
import '../../interactiv_image/interactive_image_page.dart';
import '../whats_new_page.dart';
import 'whats_new_component.dart';
import 'whats_new_view_model.dart';

/// BLoC for the [WhatsNewComponent].
///
/// Exposes a [WhatsNewViewModel] for that component to use.
@injectable
class WhatsNewBloc with ComponentBuildContext {
  Stream<WhatsNewViewModel>? _viewModel;
  Stream<WhatsNewViewModel>? get viewModel => _viewModel;

  Stream<WhatsNewViewModel> createViewModel({
    required WhatsNewPageArguments args,
  }) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Stream.value(WhatsNewViewModel(
      text: args.releaseNote.whatsNewText!,
      onContinueTap: args.onContinueTap,
      onImageTap: _handleImageTap,
      onLinkTap: _handleLinkTap,
    ));
  }

  Future<void> _handleLinkTap(String text, String? url, String title) async {
    if (url == null) {
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    if (!(await canLaunchUrl(uri))) {
      return ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).errorOpenPageText(url),
      );
    }
    await launchUrl(uri);
  }

  void _handleImageTap(String imageUrl) {
    CustomNavigator.getInstance().pushNamed(
      InteractiveImagePage.routeName,
      args: imageUrl,
    );
  }
}
