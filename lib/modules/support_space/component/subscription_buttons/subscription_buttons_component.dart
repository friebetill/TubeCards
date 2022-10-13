import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../widgets/component/component.dart';
import '../purchase_button/purchase_button_component.dart';
import '../support_space/support_space_component.dart';
import 'subscription_buttons_bloc.dart';
import 'subscription_buttons_view_model.dart';

/// The smallest donation subscription that costs about 1 euro + VAT
const _smallSubscriptionId = 'subscription_donation_1';

/// The mid-size donation subscription that costs about 3 euro + VAT
const _mediumSubscriptionId = 'subscription_donation_3';

/// The big donation subscription that costs about 10 euro + VAT
const _largeSubscriptionId = 'subscription_donation_10';

class SubscriptionButtonsComponent extends StatelessWidget {
  const SubscriptionButtonsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<SubscriptionButtonsBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<SubscriptionButtonsViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _SubscriptionButtonSkeleton(
                child: Icon(Icons.warning_outlined, color: Colors.white),
              );
            }

            if (!snapshot.hasData) {
              return const _SubscriptionButtonSkeleton(
                child: IconSizedLoadingIndicator(color: Colors.white),
              );
            }

            return _SubscriptionButtonsView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _SubscriptionButtonsView extends StatelessWidget {
  const _SubscriptionButtonsView({required this.viewModel, Key? key})
      : super(key: key);

  final SubscriptionButtonsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return !viewModel.hasSubscription
        ? _buildSubscriptionButtons(context)
        : _buildUnsubscripeButton(context);
  }

  Widget _buildSubscriptionButtons(BuildContext context) {
    return SizedBox(
      height: purchaseButtonSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: purchaseButtonSize.width,
            child: PurchaseButtonComponent(
              productId: _smallSubscriptionId,
              textCallback: (price) => '★\n$price',
              isSubscription: true,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: purchaseButtonSize.width,
            child: PurchaseButtonComponent(
              productId: _mediumSubscriptionId,
              textCallback: (price) => '★★\n$price',
              isSubscription: true,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: purchaseButtonSize.width,
            child: PurchaseButtonComponent(
              productId: _largeSubscriptionId,
              textCallback: (price) => '★★★\n$price',
              isSubscription: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsubscripeButton(BuildContext context) {
    return SizedBox(
      width: 192,
      height: purchaseButtonSize.height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
        onPressed: viewModel.onUnsubscribeTap,
        child: Center(
          child: Text(
            S.of(context).unsubscribe,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

@immutable
class _SubscriptionButtonSkeleton extends StatelessWidget {
  const _SubscriptionButtonSkeleton({required this.child, Key? key})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 192,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        onPressed: null,
        child: child,
      ),
    );
  }
}
