import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../utils/custom_navigator.dart';
import '../../utils/logging/visual_element_ids.dart';
import '../../utils/tooltip_message.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/page_callback_shortcuts.dart';
import '../../widgets/visual_element.dart';
import '../login/component/build_responsive_background.dart';
import '../login/component/login_form/login_form_component.dart';
import 'component/reset_password_form/reset_password_form_component.dart';

/// The page where the user can enter their email to receive
/// instructions to reset their password.
class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  /// The name of the route to the [ResetPasswordPage] screen.
  static const String routeName = '/reset-password';

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
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
                      _buildResetPasswordTitle(context),
                      const SizedBox(height: 32),
                      _buildInfoText(context),
                      const SizedBox(height: 32),
                      const ResetPasswordFormComponent(),
                      const SizedBox(height: 32),
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

  Widget _buildResetPasswordTitle(BuildContext context) {
    return Text(
      S.of(context).resetPassword,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headline3,
    );
  }

  Widget _buildInfoText(BuildContext context) {
    return Text(
      S.of(context).resetPasswordInfoText,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyText1,
    );
  }
}
