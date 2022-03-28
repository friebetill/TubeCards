import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../utils/custom_navigator.dart';
import '../../utils/logging/visual_element_ids.dart';
import '../../utils/tooltip_message.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/page_callback_shortcuts.dart';
import '../../widgets/visual_element.dart';
import '../login/component/build_responsive_background.dart';
import 'component/sign_up_form/sign_up_form_component.dart';

/// The page on which the user can create an account.
class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  /// The name of the route to the [SignUpPage].
  static const String routeName = '/sign-up';

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Center(
          child: buildResponsiveBackground(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    const BrandLogo(size: BrandLogoSize.huge, showText: false),
                    const SizedBox(height: 32),
                    _buildTitle(context),
                    const SizedBox(height: 32),
                    const SignUpFormComponent(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,

      // Add enough bottom space so that the splash for the leading icon is
      // not clipped at the bottom.
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(8),
        child: Container(),
      ),
      leading: VisualElement(
        id: VEs.backButton,
        childBuilder: (controller) {
          return IconButton(
            icon: const Icon(Icons.close_outlined),
            onPressed: () {
              controller.logTap();
              CustomNavigator.getInstance().pop();
            },
            tooltip: closeTooltip(context),
          );
        },
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      S.of(context).signUp,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headline3,
    );
  }
}
