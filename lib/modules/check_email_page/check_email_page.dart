import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../utils/custom_navigator.dart';
import '../../utils/logging/visual_element_ids.dart';
import '../../utils/tooltip_message.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/page_callback_shortcuts.dart';
import '../../widgets/stadium_button.dart';
import '../../widgets/visual_element.dart';
import '../login/component/build_responsive_background.dart';
import '../login/component/login_form/login_form_component.dart';
import '../reset_password/component/no_email_received_text.dart';
import '../reset_password/component/open_email_button.dart';

/// The page that encourages the user to check their email.
class CheckEmailPage extends StatelessWidget {
  const CheckEmailPage({required this.email, Key? key}) : super(key: key);

  final String email;

  /// The name of the route to the [CheckEmailPage] screen.
  static const String routeName = '/check-email';

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: _buildBackButton(context),
        ),
        body: Center(
          child: Column(
            children: [
              const Spacer(),
              buildResponsiveBackground(
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
                        _buildTitle(context),
                        const SizedBox(height: 32),
                        _buildInfoText(context),
                        const SizedBox(height: 32),
                        OpenEmailButton(),
                        const SizedBox(height: 16),
                        _buildCheckLaterButton(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: maxWidgetWidth,
                child: NoEmailReceivedText(email: email),
              ),
              const SizedBox(height: 32),
            ],
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
          onPressed: () {
            controller.logTap();
            CustomNavigator.getInstance().pop();
          },
          tooltip: backTooltip(context),
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      S.of(context).checkYourEmail,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headline3,
    );
  }

  Widget _buildInfoText(BuildContext context) {
    return Text(
      S.of(context).sentRecoverInstructionsText,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyText1,
    );
  }

  Widget _buildCheckLaterButton(BuildContext context) {
    return VisualElement(
      id: VEs.checkLaterButton,
      childBuilder: (controller) {
        return StadiumButton(
          textColor: Theme.of(context).colorScheme.onBackground,
          fontSize: 12,
          elevation: 0,
          onPressed: () {
            controller.logTap();
            CustomNavigator.getInstance().pop();
          },
          text: S.of(context).checkLater.toUpperCase(),
        );
      },
    );
  }
}
