import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../repository/support_space_repository.dart';
import 'purchase_button_view_model.dart';

@injectable
class PurchaseButtonBloc
    with ComponentBuildContext, ComponentLifecycleListener {
  PurchaseButtonBloc(this._supportUsRepository);

  final SupportSpaceRepository _supportUsRepository;

  final _logger = Logger((PurchaseButtonBloc).toString());

  Stream<PurchaseButtonViewModel>? _viewModel;
  Stream<PurchaseButtonViewModel>? get viewModel => _viewModel;

  final _isLoading = BehaviorSubject.seeded(false);

  Stream<PurchaseButtonViewModel> createViewModel(
    String productId,
    String Function(String price) textCallback, {
    bool isSubscription = false,
  }) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    final purchaseType =
        isSubscription ? PurchaseType.subs : PurchaseType.inapp;

    return _viewModel = Rx.combineLatest4(
      Stream.fromFuture(Purchases.getProducts([productId], type: purchaseType)),
      Stream.value(textCallback),
      _isLoading,
      Stream.value(purchaseType),
      _createViewModel,
    );
  }

  PurchaseButtonViewModel _createViewModel(
    List<Product> products,
    String Function(String price) textCallback,
    bool isLoading,
    PurchaseType purchaseType,
  ) {
    return PurchaseButtonViewModel(
      text: textCallback(products.first.priceString),
      onTap: () => _handlePurchase(products.first.identifier, purchaseType),
      isLoading: isLoading,
    );
  }

  @override
  void dispose() {
    _isLoading.close();
    super.dispose();
  }

  Future<void> _handlePurchase(
    String productId,
    PurchaseType purchaseType,
  ) async {
    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    _isLoading.add(true);
    try {
      final purchaserInfo =
          await Purchases.purchaseProduct(productId, type: purchaseType);

      final didUserBuy = purchaseType == PurchaseType.inapp
          ? _supportUsRepository
                  .purchaserInfo.value.nonSubscriptionTransactions.length <
              purchaserInfo.nonSubscriptionTransactions.length
          : _supportUsRepository
                  .purchaserInfo.value.activeSubscriptions.length <
              purchaserInfo.activeSubscriptions.length;
      if (didUserBuy) {
        messenger.showSuccessSnackBar(theme: theme, text: i18n.thankYouText);
      }

      _supportUsRepository.purchaserInfo.add(purchaserInfo);
    } on PlatformException catch (e, s) {
      handlePlatformException(context, e, s);
    } finally {
      _isLoading.add(false);
    }
  }

  void handlePlatformException(
    BuildContext context,
    PlatformException e,
    StackTrace s,
  ) {
    var exceptionText = S.of(context).errorWeWillFixText;

    // Explanation of all error codes http://bit.ly/3aXCujv.
    switch (PurchasesErrorHelper.getErrorCode(e)) {
      case PurchasesErrorCode.networkError:
        exceptionText = S.of(context).errorNoInternetText;
        break;
      case PurchasesErrorCode.invalidAppUserIdError:
        exceptionText = S.of(context).errorWeWillFixText;
        _logger.severe('Invalid app user id error occured', e, s);
        break;
      case PurchasesErrorCode.insufficientPermissionsError:
        final company = Platform.isAndroid ? 'Google' : 'Apple';
        exceptionText = S.of(context).makeSureSignedText(company);
        _logger.severe('Insufficient permission error occured', e, s);
        break;
      case PurchasesErrorCode.paymentPendingError:
        exceptionText = S.of(context).startedPendingPurchaseText;
        ScaffoldMessenger.of(context)
            .showSuccessSnackBar(theme: Theme.of(context), text: exceptionText);
        return;
      case PurchasesErrorCode.storeProblemError:
        // If everything was working while testing, we shouldn't have to do
        // anything to handle this error in production.
        _logger.severe('Unexpected store problem error', e, s);
        return;
      case PurchasesErrorCode.purchaseCancelledError:
        // No action required. The user decided not to proceed with their
        // in-app purchase.
        return;
      default:
        _logger.severe('Exception during purchase', e, s);
    }
    ScaffoldMessenger.of(context)
        .showErrorSnackBar(theme: Theme.of(context), text: exceptionText);
  }
}
