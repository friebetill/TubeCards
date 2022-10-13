import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/custom_navigator.dart';
import '../../../widgets/stadium_button.dart';
import '../../login/login_page.dart';
import '../../sign_up/sign_up_page.dart';

/// Tile that urgs the current user to either create an account or log in.
class AccountNag extends StatelessWidget {
  const AccountNag({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SizedBox(
          width: 360 - 16 - 16,
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(1, 2),
                  radius: 2,
                  colors: Theme.of(context).brightness == Brightness.light
                      ? const [Color(0xFF30CFD0), Color(0xFF326A9A)]
                      : const [Color(0xFF82B1FF), Color(0xFF326A9A)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTitle(context),
                  const SizedBox(height: 12),
                  _buildBody(context),
                  const SizedBox(height: 16),
                  _buildSignUpButton(context),
                  const SizedBox(height: 4),
                  Align(child: _buildLoginButton(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      S.of(context).createAccount,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Text(
      S.of(context).accountAdvantagesText,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 256,
        height: 48,
        child: StadiumButton(
          text: S.of(context).signUp.toUpperCase(),
          onPressed: () =>
              CustomNavigator.getInstance().pushNamed(SignUpPage.routeName),
          textColor: Colors.black,
          backgroundColor: Colors.white,
          boldText: true,
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 12),
        // Leads to 8 pixel padding
        minimumSize: const Size(64, 38),
      ),
      onPressed: () =>
          CustomNavigator.getInstance().pushNamed(LoginPage.routeName),
      child: Text(S.of(context).alreadyRegistered.toUpperCase()),
    );
  }
}
