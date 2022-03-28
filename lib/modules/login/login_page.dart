import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../utils/custom_navigator.dart';
import '../../utils/logging/visual_element_ids.dart';
import '../../utils/tooltip_message.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/page_callback_shortcuts.dart';
import '../../widgets/visual_element.dart';
import 'component/build_responsive_background.dart';
import 'component/login_form/login_form_component.dart';

/// The screen on which the user can log in with his existing account.
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  /// The name of the route to the [LoginPage] screen.
  static const String routeName = '/log-in';

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: _buildBackButton(context),
        ),
        body: Center(
          child: buildResponsiveBackground(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: maxWidgetWidth,
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      const BrandLogo(
                        size: BrandLogoSize.huge,
                        showText: false,
                      ),
                      const SizedBox(height: 32),
                      _buildLoginTitle(context),
                      const SizedBox(height: 32),
                      const LoginFormComponent(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return VisualElement(
      id: VEs.backButton,
      childBuilder: (controller) {
        return IconButton(
          icon: const BackButtonIcon(),
          tooltip: backTooltip(context),
          onPressed: () {
            controller.logTap();
            CustomNavigator.getInstance().pop();
          },
        );
      },
    );
  }

  Widget _buildLoginTitle(BuildContext context) {
    return Text(
      S.of(context).login,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headline3,
    );
  }
}
