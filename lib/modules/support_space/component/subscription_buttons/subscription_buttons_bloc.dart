import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../repository/support_space_repository.dart';
import 'subscription_buttons_view_model.dart';

@injectable
class SubscriptionButtonsBloc {
  SubscriptionButtonsBloc(this._supportUsRepository);

  final SupportSpaceRepository _supportUsRepository;

  Stream<SubscriptionButtonsViewModel>? _viewModel;
  Stream<SubscriptionButtonsViewModel>? get viewModel => _viewModel;

  Stream<SubscriptionButtonsViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = _supportUsRepository.customerInfo.map(_createViewModel);
  }

  SubscriptionButtonsViewModel _createViewModel(CustomerInfo customerInfo) {
    return SubscriptionButtonsViewModel(
      hasSubscription: customerInfo.activeSubscriptions.isNotEmpty,
      onUnsubscribeTap: () {
        final url = Uri.tryParse(customerInfo.managementURL!);
        if (url == null) {
          return;
        }
        launchUrl(url);
      },
    );
  }
}
