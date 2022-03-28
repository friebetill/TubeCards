import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/custom_navigator.dart';

class ThemeDialog extends StatelessWidget {
  const ThemeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adaptiveTheme = AdaptiveTheme.of(context);

    return AlertDialog(
      title: Text(S.of(context).theme),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSystemOption(context, adaptiveTheme),
          _buildLightOption(context, adaptiveTheme),
          _buildDarkOption(context, adaptiveTheme),
        ],
      ),
    );
  }

  Widget _buildLightOption(
    BuildContext context,
    AdaptiveThemeManager adaptiveTheme,
  ) {
    return RadioListTile<AdaptiveThemeMode>(
      title: Text(
        S.of(context).lightTheme,
        style: const TextStyle(fontSize: 16),
      ),
      dense: true,
      selected: adaptiveTheme.mode == AdaptiveThemeMode.light,
      value: AdaptiveThemeMode.light,
      groupValue: adaptiveTheme.mode,
      onChanged: (value) {
        adaptiveTheme.setThemeMode(value!);
        CustomNavigator.getInstance().pop();
      },
    );
  }

  Widget _buildDarkOption(
    BuildContext context,
    AdaptiveThemeManager adaptiveTheme,
  ) {
    return RadioListTile<AdaptiveThemeMode>(
      title: Text(
        S.of(context).darkTheme,
        style: const TextStyle(fontSize: 16),
      ),
      dense: true,
      selected: adaptiveTheme.mode == AdaptiveThemeMode.dark,
      value: AdaptiveThemeMode.dark,
      groupValue: adaptiveTheme.mode,
      onChanged: (value) {
        adaptiveTheme.setThemeMode(value!);
        CustomNavigator.getInstance().pop();
      },
    );
  }

  Widget _buildSystemOption(
    BuildContext context,
    AdaptiveThemeManager adaptiveTheme,
  ) {
    return RadioListTile<AdaptiveThemeMode>(
      title: Text(
        S.of(context).systemDependent,
        style: const TextStyle(fontSize: 16),
      ),
      dense: true,
      selected: adaptiveTheme.mode == AdaptiveThemeMode.system,
      value: AdaptiveThemeMode.system,
      groupValue: adaptiveTheme.mode,
      onChanged: (value) {
        adaptiveTheme.setThemeMode(value!);
        CustomNavigator.getInstance().pop();
      },
    );
  }
}
