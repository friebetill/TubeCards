import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/assets.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/sizes.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/scalable_widgets/horizontal_scalable_box.dart';
import '../../../../widgets/scalable_widgets/vertical_scalable_box.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../../../widgets/stadium_button.dart';
import 'feedback_bloc.dart';
import 'feedback_view_model.dart';

class FeedbackComponent extends StatelessWidget {
  const FeedbackComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<FeedbackBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<FeedbackViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SimpleSkeleton(appBarTitle: S.of(context).feedback);
            }

            return _FeedbackView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _FeedbackView extends StatefulWidget {
  const _FeedbackView({required this.viewModel, Key? key}) : super(key: key);

  final FeedbackViewModel viewModel;

  @override
  _FeedbackViewState createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<_FeedbackView> {
  final _feedbackController = TextEditingController();
  final _emailTextController = TextEditingController();

  final _feedbackFocus = FocusNode();
  final _emailTextFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).feedback),
          elevation: 0,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: CustomNavigator.getInstance().pop,
            tooltip: backTooltip(context),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height -
                      appBarHeight -
                      systemBarHeight,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    HorizontalScalableBox(
                      minHeight: 140,
                      scaleFactor: 0.05,
                      child: SvgPicture.asset(Assets.images.newMessage),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).improveTheApp,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const SizedBox(height: 8),
                    _buildSubtitle(),
                    const SizedBox(height: 16),
                    VerticalScalableBox(
                      minHeight: widget.viewModel.isUserAnonymous ? 74 : 100,
                      child: _buildFeedbackField(),
                    ),
                    if (widget.viewModel.isUserAnonymous)
                      const SizedBox(height: 16),
                    if (widget.viewModel.isUserAnonymous)
                      VerticalScalableBox(
                        minHeight: 50,
                        child: _buildEmailField(),
                      ),
                    const Spacer(flex: 2),
                    _buildSendButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _feedbackFocus.dispose();
    _emailTextFocus.dispose();
    super.dispose();
  }

  Widget _buildSubtitle() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Text(
        S.of(context).feedbackSubtitle,
        style: Theme.of(context).textTheme.bodyText2,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFeedbackField() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: TextFormField(
        controller: _feedbackController,
        focusNode: _feedbackFocus,
        keyboardType: TextInputType.multiline,
        onChanged: widget.viewModel.onFeedbackTextChange,
        maxLines: 10,
        decoration: InputDecoration(
          errorText: widget.viewModel.feedbackErrorText,
          labelText: S.of(context).describeTheProblemOrYourIdea,
          labelStyle: TextStyle(
            color: widget.viewModel.feedbackErrorText != null
                ? Theme.of(context).colorScheme.error
                : _feedbackFocus.hasFocus
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).hintColor,
          ),
          alignLabelWithHint: true,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: TextFormField(
        controller: _emailTextController,
        focusNode: _emailTextFocus,
        keyboardType: TextInputType.emailAddress,
        onChanged: widget.viewModel.onEmailTextChange,
        decoration: InputDecoration(
          labelText: S.of(context).emailOptional,
          errorText: widget.viewModel.emailErrorText,
          labelStyle: TextStyle(
            color: widget.viewModel.emailErrorText != null
                ? Theme.of(context).colorScheme.error
                : _emailTextFocus.hasFocus
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).hintColor,
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        textInputAction: TextInputAction.done,
      ),
    );
  }

  Widget _buildSendButton() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: StadiumButton(
          text: S.of(context).sendFeedback.toUpperCase(),
          onPressed: widget.viewModel.onSendEmailTap,
          backgroundColor: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.onPrimary,
          isLoading: widget.viewModel.isSending,
        ),
      ),
    );
  }
}
