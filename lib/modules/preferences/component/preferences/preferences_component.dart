import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../preference_title.dart';
import 'preferences_bloc.dart';
import 'preferences_view_model.dart';

class PreferencesComponent extends StatelessWidget {
  const PreferencesComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<PreferencesBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<PreferencesViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _PreferencesView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _PreferencesView extends StatelessWidget {
  const _PreferencesView({required this.viewModel, Key? key}) : super(key: key);

  final PreferencesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ..._buildGeneralPreferences(context),
        ..._buildLearnPreferences(context),
        ..._buildDangerZonePreferences(context),
      ],
    );
  }

  List<Widget> _buildGeneralPreferences(BuildContext context) {
    return [
      PreferenceTitle(S.of(context).general),
      _buildThemeTile(context),
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)
        ListTileAdapter(
          child: ListTile(
            title: Text(S.of(context).reminder),
            subtitle: Text(
              S.of(context).reminderSubtitle(viewModel.activeReminderCount),
            ),
            onTap: viewModel.onReminderTap,
          ),
        ),
    ];
  }

  Widget _buildThemeTile(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        title: Text(S.of(context).theme),
        subtitle: ValueListenableBuilder<AdaptiveThemeMode>(
          valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
          builder: (_, themeMode, __) {
            late String subtitle;
            switch (themeMode) {
              case AdaptiveThemeMode.light:
                subtitle = S.of(context).lightTheme;
                break;
              case AdaptiveThemeMode.dark:
                subtitle = S.of(context).darkTheme;
                break;
              case AdaptiveThemeMode.system:
                subtitle = S.of(context).systemDependent;
                break;
            }

            return Text(subtitle);
          },
        ),
        onTap: () => viewModel.onThemeTap(context),
      ),
    );
  }

  List<Widget> _buildLearnPreferences(BuildContext context) {
    return [
      PreferenceTitle(S.of(context).learn),
      ListTileAdapter(
        child: ListTile(
          title: Text(S.of(context).cardsPerSessionLimit),
          subtitle: viewModel.isCardLimitPerSessionActive
              ? Text(S.of(context).learnCards(viewModel.cardsPerSessionLimit))
              : Text(S.of(context).learnCardsAll),
          onTap: viewModel.handleCardsPerSessionLimitTap,
        ),
      ),
    ];
  }

  List<Widget> _buildDangerZonePreferences(BuildContext context) {
    return [
      PreferenceTitle(S.of(context).dangerZone),
      ListTileAdapter(
        child: ListTile(
          title: Text(S.of(context).deleteAccount),
          onTap: viewModel.onDeleteAccountTap,
          enabled: viewModel.isLoggedIn,
        ),
      ),
    ];
  }
}
