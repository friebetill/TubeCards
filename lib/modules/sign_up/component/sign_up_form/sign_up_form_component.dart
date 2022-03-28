import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/stadium_button.dart';
import '../../../../widgets/visual_element.dart';
import '../../../login/component/email_field.dart';
import '../../../login/component/login_form/login_form_component.dart';
import '../../../login/component/password_field.dart';
import '../../../login/login_page.dart';
import 'first_name_field.dart';
import 'last_name_field.dart';
import 'sign_up_form_bloc.dart';
import 'sign_up_form_view_model.dart';

const insetMargin = 32.0;

class SignUpFormComponent extends StatelessWidget {
  const SignUpFormComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<SignUpFormBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<SignUpFormViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // The size is measured.
              const signUpViewSize = Size(384, 284);

              return SizedBox(
                width: signUpViewSize.width,
                height: signUpViewSize.height,
              );
            }

            return _SignUpView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _SignUpView extends StatefulWidget {
  const _SignUpView({required this.viewModel, Key? key}) : super(key: key);

  final SignUpFormViewModel viewModel;

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  /// Controller used to manage form data.
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();

  /// [FocusNode]s used to control whether an [TextField] is focused.
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return SizedBox(
      width: maxWidgetWidth,
      child: Form(
        child: AutofillGroup(
          child: Column(
            children: [
              Row(
                children: [
                  FirstNameField(
                    viewModel.onFirstNameChanged,
                    viewModel.firstNameErrorText,
                    _firstNameFocus,
                    _lastNameFocus,
                  ),
                  const SizedBox(width: 16),
                  LastNameField(
                    viewModel.onLastNameChanged,
                    viewModel.lastNameErrorText,
                    _lastNameFocus,
                    _emailFocus,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              EmailField(
                viewModel.onEmailChanged,
                viewModel.emailErrorText,
                _emailFocus,
                _passwordFocus,
              ),
              const SizedBox(height: 16),
              PasswordField(
                viewModel.onPasswordChanged,
                viewModel.passwordErrorText,
                _passwordFocus,
                viewModel.onSignUpTap,
                viewModel.onObscureTap,
                obscurePassword: viewModel.obscurePassword,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: _buildAlreadyRegisteredButton(),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: widgetHeight,
                width: double.infinity,
                child: _buildSignUpButton(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildAlreadyRegisteredButton() {
    return VisualElement(
      id: VEs.alreadyRegisteredButton,
      childBuilder: (controller) {
        return StadiumButton(
          text: S.of(context).alreadyRegistered.toUpperCase(),
          textColor: Theme.of(context).hintColor,
          onPressed: () {
            controller.logTap();
            CustomNavigator.getInstance()
                .pushReplacementNamed(LoginPage.routeName);
          },
          elevation: 0,
        );
      },
    );
  }

  Widget _buildSignUpButton() {
    return VisualElement(
      id: VEs.signUpButton,
      childBuilder: (controller) {
        return StadiumButton(
          text: S.of(context).signUp.toUpperCase(),
          onPressed: () {
            controller.logTap();
            widget.viewModel.onSignUpTap();
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.onPrimary,
          boldText: true,
          isLoading: widget.viewModel.isLoading,
        );
      },
    );
  }
}
