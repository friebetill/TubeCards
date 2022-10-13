import 'package:flutter/material.dart';

import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../widgets/component/component.dart';
import 'purchase_button_bloc.dart';
import 'purchase_button_view_model.dart';

class PurchaseButtonComponent extends StatelessWidget {
  const PurchaseButtonComponent({
    required this.productId,
    required this.textCallback,
    this.isSubscription = false,
    Key? key,
  }) : super(key: key);

  final String productId;
  final String Function(String price) textCallback;
  final bool isSubscription;

  @override
  Widget build(BuildContext context) {
    return Component<PurchaseButtonBloc>(
      createViewModel: (bloc) => bloc.createViewModel(
        productId,
        textCallback,
        isSubscription: isSubscription,
      ),
      builder: (context, bloc) {
        return StreamBuilder<PurchaseButtonViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _ErrorButton();
            }

            if (!snapshot.hasData) {
              return _DonationButtonView(
                PurchaseButtonViewModel(
                  text: '',
                  onTap: () {/* NO-OP */},
                  isLoading: true,
                ),
              );
            }

            return _DonationButtonView(snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _DonationButtonView extends StatelessWidget {
  const _DonationButtonView(this.viewModel, {Key? key}) : super(key: key);

  final PurchaseButtonViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: viewModel.onTap,
      child: Center(
        child: viewModel.isLoading
            ? const IconSizedLoadingIndicator(color: Colors.white)
            : Text(
                viewModel.text,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}

@immutable
class _ErrorButton extends StatelessWidget {
  const _ErrorButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: null,
      child: const Center(
        child: Icon(Icons.warning_outlined, color: Colors.white),
      ),
    );
  }
}
