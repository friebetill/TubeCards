import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/stadium_button.dart';
import '../../../../widgets/visual_element.dart';
import '../email_field.dart';
import '../password_field.dart';
import 'login_form_bloc.dart';
import 'login_form_view_model.dart';

const double edgeInset = 8;
const double maxWidgetWidth = 384;
const double widgetHeight = 56;
const double insetMargin = 32;

class LoginFormComponent extends StatelessWidget {
  const LoginFormComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<LoginFormBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<LoginFormViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // The size is measured.
              const signUpViewSize = Size(384, 248);

              return SizedBox(
                width: signUpViewSize.width,
                height: signUpViewSize.height,
              );
            }

            return _LoginFormView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _LoginFormView extends StatefulWidget {
  const _LoginFormView({required this.viewModel, Key? key}) : super(key: key);

  final LoginFormViewModel viewModel;

  @override
  _LoginFormViewState createState() => _LoginFormViewState();
}

class _LoginFormViewState extends State<_LoginFormView> {
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidgetWidth,
      child: Form(
        child: AutofillGroup(
          child: Column(
            children: [
              EmailField(
                widget.viewModel.onEmailChange,
                widget.viewModel.emailErrorText,
                _emailFocus,
                _passwordFocus,
              ),
              const SizedBox(height: 16),
              PasswordField(
                widget.viewModel.onPasswordChange,
                widget.viewModel.passwordErrorText,
                _passwordFocus,
                widget.viewModel.onLogInTap,
                widget.viewModel.onToggleObscurePassword,
                obscurePassword: widget.viewModel.obscurePassword,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: _buildResetPasswordButton(),
              ),
              const SizedBox(height: 8),
              _buildLoginButton(),
              const SizedBox(height: 8),
              Center(child: _buildSignUpButton()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Widget _buildResetPasswordButton() {
    return VisualElement(
      id: VEs.resetPasswordButton,
      childBuilder: (controller) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 36),
          padding: const EdgeInsets.only(right: edgeInset),
          child: TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).hintColor),
            onPressed: () {
              controller.logTap();
              widget.viewModel.onResetPassword();
            },
            child: Text(S.of(context).resetPassword.toUpperCase()),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return VisualElement(
      id: VEs.loginButton,
      childBuilder: (controller) {
        return SizedBox(
          height: widgetHeight,
          width: double.infinity,
          child: StadiumButton(
            text: S.of(context).login.toUpperCase(),
            onPressed: () {
              controller.logTap();
              widget.viewModel.onLogInTap();
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Theme.of(context).colorScheme.onPrimary,
            boldText: true,
            isLoading: widget.viewModel.isLoading,
          ),
        );
      },
    );
  }

  Widget _buildSignUpButton() {
    final hintStyle = Theme.of(context)
        .textTheme
        .bodyText1!
        .copyWith(color: Theme.of(context).hintColor);

    return VisualElement(
      id: VEs.signUpButton,
      childBuilder: (controller) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 36),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context).dontHaveAnAccount, style: hintStyle),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () {
                  controller.logTap();
                  widget.viewModel.onSignUpTap();
                },
                style: TextButton.styleFrom(textStyle: hintStyle),
                child: Text(S.of(context).signUp.toUpperCase()),
              ),
            ],
          ),
        );
      },
    );
  }
}
