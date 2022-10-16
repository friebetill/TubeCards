import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/config.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../../../../widgets/visual_element.dart';
import '../profile/profile_component.dart';
import 'account_bloc.dart';
import 'account_view_model.dart';

class AccountComponent extends StatelessWidget {
  const AccountComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<AccountBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<AccountViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _AccountView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _AccountView extends StatelessWidget {
  const _AccountView({required this.viewModel, Key? key}) : super(key: key);

  final AccountViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        const ProfileComponent(),
        _buildPreferencesTile(context),
        _buildImportExportTile(context),
        _buildOtherPlatforms(context),
        if (!isProduction) _buildDeveloperTile(context),
        const Divider(),
        _buildSupportUsTile(context),
        _buildNextFeaturesTile(context),
        _buildFeedbackTile(context),
        _buildSourceCodeTile(context),
        if (Platform.isAndroid ||
            Platform.isIOS ||
            Platform.isMacOS ||
            Platform.isWindows)
          _buildRateUsTile(context),
        _buildPrivacyPolicyTile(context),
        _buildAboutTile(context),
        const Divider(),
        _buildLogoutTile(context),
      ],
    );
  }

  Widget _buildPreferencesTile(BuildContext context) {
    return VisualElement(
      id: VEs.preferencesTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: ListTile(
            leading: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(S.of(context).preferences),
            onTap: () {
              controller.logTap();
              viewModel.onPreferenceTap();
            },
          ),
        );
      },
    );
  }

  Widget _buildImportExportTile(BuildContext context) {
    return VisualElement(
      id: VEs.importExportTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: ListTile(
            leading: Icon(
              Icons.import_export_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(S.of(context).importAndExport),
            onTap: () {
              controller.logTap();
              viewModel.onImportExportTap();
            },
          ),
        );
      },
    );
  }

  Widget _buildOtherPlatforms(BuildContext context) {
    return VisualElement(
      id: VEs.otherPlatformsTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: ListTile(
            leading: Icon(
              Icons.devices_other_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(S.of(context).otherPlatforms),
            onTap: () {
              controller.logTap();
              viewModel.onOtherPlatformsTap();
            },
          ),
        );
      },
    );
  }

  Widget _buildDeveloperTile(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        leading: Icon(
          Icons.developer_mode_outlined,
          color: Theme.of(context).iconTheme.color,
        ),
        title: const Text('Developer options'),
        onTap: viewModel.onDeveloperTap,
      ),
    );
  }

  Widget _buildFeedbackTile(BuildContext context) {
    return VisualElement(
      id: VEs.feedbackTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: ListTile(
            leading: Icon(
              Icons.feedback_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(S.of(context).feedback),
            onTap: () {
              controller.logTap();
              viewModel.onFeedbackTap();
            },
          ),
        );
      },
    );
  }

  Widget _buildSourceCodeTile(BuildContext context) {
    return VisualElement(
      id: VEs.sourceCodeTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: ListTile(
            leading: Icon(
              Icons.code_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(S.of(context).sourceCode),
            onTap: () {
              controller.logTap();
              viewModel.onSourceCodeTap();
            },
          ),
        );
      },
    );
  }

  Widget _buildNextFeaturesTile(BuildContext context) {
    return VisualElement(
      id: VEs.nextFeaturesTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: ListTile(
            leading: Icon(
              Icons.checklist_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(S.of(context).voteForTheNextFeature),
            onTap: () {
              controller.logTap();
              viewModel.onVoteNextFeaturesTap();
            },
          ),
        );
      },
    );
  }

  Widget _buildSupportUsTile(BuildContext context) {
    return VisualElement(
      id: VEs.supportUsTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: ListTile(
            leading: Icon(
              Icons.favorite_border_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(S.of(context).supportSpace),
            onTap: () {
              controller.logTap();
              viewModel.onSupportUsTap();
            },
          ),
        );
      },
    );
  }

  Widget _buildRateUsTile(BuildContext context) {
    return VisualElement(
      id: VEs.rateUsTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: ListTile(
            leading: Icon(
              Icons.star_border_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(S.of(context).rateUs),
            onTap: () {
              controller.logTap();
              viewModel.onRateUsTap();
            },
          ),
        );
      },
    );
  }

  Widget _buildPrivacyPolicyTile(BuildContext context) {
    return VisualElement(
      id: VEs.privacyPolicyTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: ListTile(
            leading: Icon(
              Icons.assignment_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(S.of(context).privacyPolicy),
            onTap: () {
              controller.logTap();
              viewModel.onPrivacyPolicyTap();
            },
          ),
        );
      },
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return VisualElement(
      id: VEs.aboutTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(S.of(context).aboutSpace),
            onTap: () {
              controller.logTap();
              viewModel.onAboutTap();
            },
          ),
        );
      },
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return VisualElement(
      id: VEs.logoutTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: ListTile(
            leading: Icon(
              Icons.exit_to_app_outlined,
              color: viewModel.isLoggedIn
                  ? Theme.of(context).iconTheme.color
                  : Theme.of(context).disabledColor,
            ),
            title: Text(S.of(context).logout),
            onTap: () {
              controller.logTap();
              viewModel.onLogOutTap();
            },
            enabled: viewModel.isLoggedIn,
          ),
        );
      },
    );
  }
}
