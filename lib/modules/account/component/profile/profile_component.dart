import 'package:flutter/material.dart';

import '../../../../widgets/component/component.dart';
import '../account_nag.dart';
import 'profile_bloc.dart';
import 'profile_view_model.dart';

class ProfileComponent extends StatelessWidget {
  const ProfileComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<ProfileBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<ProfileViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // Add a placeholder so that the screen does not jump around.
              // There is still a small jump for the anonymous user.
              return const SizedBox(height: _ProfileView.height);
            }

            return _ProfileView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.viewModel, Key? key}) : super(key: key);

  final ProfileViewModel viewModel;

  static const double height = 96;

  @override
  Widget build(BuildContext context) {
    if (viewModel.user.isAnonymous!) {
      return const AccountNag();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildUserIcon(context),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${viewModel.user.firstName} ${viewModel.user.lastName}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .textTheme
                      .headline6!
                      .color!
                      .withOpacity(0.8),
                ),
              ),
              Text(
                viewModel.user.email!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Hero(
        tag: 'account-avatar',
        child: CircleAvatar(
          radius: 32,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: Text(
            viewModel.user.firstName![0].toUpperCase(),
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}
