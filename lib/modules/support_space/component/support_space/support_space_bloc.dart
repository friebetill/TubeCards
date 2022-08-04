import 'dart:io';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/config.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import 'support_space_view_model.dart';

@injectable
class SupportSpaceBloc with ComponentBuildContext {
  Stream<SupportSpaceViewModel>? _viewModel;
  Stream<SupportSpaceViewModel>? get viewModel => _viewModel;

  Stream<SupportSpaceViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Stream.value(_createViewModel());
  }

  SupportSpaceViewModel _createViewModel() {
    return SupportSpaceViewModel(
      hasSubscriptions: Platform.isAndroid,
      onPayPalButtonTap: _handlePayPalButtonTap,
    );
  }

  Future<void> _handlePayPalButtonTap() async {
    final url = Uri.https(
        'paypal.com', '/donate', {'hosted_button_id': payPalButtonId});

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).errorOpenPageText(url),
      );
      throw Exception(S.of(context).couldNotLaunchURL(url));
    }
  }
}
