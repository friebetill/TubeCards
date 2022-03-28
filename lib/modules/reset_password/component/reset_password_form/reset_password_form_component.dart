import 'package:flutter/material.dart';

import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/visual_element.dart';
import '../email_field.dart';
import '../send_instructions_button.dart';
import 'reset_password_form_bloc.dart';
import 'reset_password_form_view_model.dart';

class ResetPasswordFormComponent extends StatelessWidget {
  const ResetPasswordFormComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<ResetPasswordFormBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<ResetPasswordFormViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // The size is measured.
              return const SizedBox(height: 120);
            }

            return _ResetPasswordFormView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _ResetPasswordFormView extends StatefulWidget {
  const _ResetPasswordFormView({required this.viewModel, Key? key})
      : super(key: key);

  final ResetPasswordFormViewModel viewModel;

  @override
  _ResetPasswordFormViewState createState() => _ResetPasswordFormViewState();
}

class _ResetPasswordFormViewState extends State<_ResetPasswordFormView> {
  final _emailFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: AutofillGroup(
        child: Column(
          children: [
            EmailField(
              widget.viewModel.onEmailChange,
              widget.viewModel.emailErrorText,
              _emailFocus,
              widget.viewModel.onSendInstructionsTap,
            ),
            const SizedBox(height: 16),
            VisualElement(
              id: VEs.sendResetPasswordInstructionsButton,
              childBuilder: (controller) {
                return SendInstructionsButton(
                  isLoading: widget.viewModel.isLoading,
                  onTap: () {
                    controller.logTap();
                    widget.viewModel.onSendInstructionsTap();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    super.dispose();
  }
}
