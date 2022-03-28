import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/stadium_button.dart';
import 'account_deletion_bloc.dart';
import 'account_deletion_view_model.dart';

class AccountDeletionComponent extends StatelessWidget {
  const AccountDeletionComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<AccountDeletionBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<AccountDeletionViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            return _AccountDeletionView(viewModel: snapshot.data);
          },
        );
      },
    );
  }
}

@immutable
class _AccountDeletionView extends StatelessWidget {
  const _AccountDeletionView({required this.viewModel, Key? key})
      : super(key: key);

  final AccountDeletionViewModel? viewModel;

  static const _buttonElevation = 2.0;

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.grey.shade300;

    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 92),
              Icon(Icons.delete_outlined, color: iconColor, size: 128),
              const Spacer(),
              Text(
                S.of(context).deleteAccountText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              _buildKeepAccountButton(context),
              const SizedBox(height: 16),
              _buildDeleteAccountButton(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).deleteAccount),
      elevation: 0,
      leading: IconButton(
        icon: const BackButtonIcon(),
        onPressed: CustomNavigator.getInstance().pop,
        tooltip: backTooltip(context),
      ),
    );
  }

  Widget _buildKeepAccountButton(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: StadiumButton(
        text: S.of(context).keepAccount.toUpperCase(),
        onPressed: viewModel?.onKeepAccountTap != null
            ? viewModel!.onKeepAccountTap
            : () {/* NO-OP */},
        elevation: _buttonElevation,
        backgroundColor: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.surface,
        boldText: true,
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: StadiumButton(
        text: S.of(context).deleteAccount.toUpperCase(),
        onPressed: viewModel?.onDeleteAccountTap,
        elevation: _buttonElevation,
        backgroundColor: Theme.of(context).colorScheme.surface,
        isLoading: viewModel?.isDeleting ?? false,
        textColor: Theme.of(context).colorScheme.error,
        boldText: true,
      ),
    );
  }
}
