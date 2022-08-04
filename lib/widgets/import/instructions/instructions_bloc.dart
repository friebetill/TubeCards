import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import 'instructions_component.dart';
import 'instructions_view_model.dart';

/// BLoC for the [InstructionsComponent].
@injectable
class InstructionsBloc with ComponentBuildContext {
  InstructionsBloc();

  Stream<InstructionsViewModel>? _viewModel;
  Stream<InstructionsViewModel>? get viewModel => _viewModel;

  Stream<InstructionsViewModel> createViewModel({
    required String appBarTitle,
    required String markdownBody,
    required VoidCallback handleSelectFileTap,
  }) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Stream.value(InstructionsViewModel(
      appBarTitle: appBarTitle,
      markdownBody: markdownBody,
      onLinkTap: _handleLinkTap,
      onSelectFileTap: handleSelectFileTap,
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
}
