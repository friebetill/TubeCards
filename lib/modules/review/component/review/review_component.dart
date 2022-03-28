import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/models/confidence.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../controls_component.dart';
import '../app_bar/app_bar_component.dart';
import '../flashcard_component.dart';
import '../slide_in_animation_component.dart';
import '../slide_out_left_animation_component.dart';
import '../slide_out_right_animation_component.dart';
import '../swipe_feedback.dart';
import 'review_bloc.dart';
import 'review_view_model.dart';

class ReviewComponent extends StatelessWidget {
  const ReviewComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<ReviewBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<ReviewViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SimpleSkeleton();
            }

            return _ReviewView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _ReviewView extends StatelessWidget {
  const _ReviewView(this.viewModel);

  final ReviewViewModel viewModel;

  /// Distance between bottom of screen and bottom of the control button area.
  static const _controlButtonsBottomMargin = 32.0;

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.escape):
            CustomNavigator.getInstance().pop,
        LogicalKeySet(LogicalKeyboardKey.space): viewModel.onFlipTap,
        LogicalKeySet(LogicalKeyboardKey.keyA): viewModel.triggerLeftCardShift,
        LogicalKeySet(LogicalKeyboardKey.keyF): viewModel.triggerRightCardShift,
      },
      child: Scaffold(
        appBar: const AppBarComponent(),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: _buildAnimations(
                    child: SwipeFeedback(
                      onLeftPanEnd: viewModel.triggerLeftCardShift,
                      onRightPanEnd: viewModel.triggerRightCardShift,
                      onLeftDistanceCrossed: viewModel.onLeftDistanceCrossed,
                      onRightDistanceCrossed: viewModel.onRighttDistanceCrossed,
                      resetOnToggle: viewModel.slideInOnToggle,
                      child: viewModel.frontText != null
                          ? FlashcardComponent(
                              isFrontSide: viewModel.isFrontSide,
                              frontText: viewModel.frontText!,
                              backText: viewModel.backText!,
                              onCardTap: viewModel.onFlipTap,
                              resetOnToggle: viewModel.slideInOnToggle,
                              contentPadding: const EdgeInsets.all(24) +
                                  // Makes the content visible despite controls
                                  const EdgeInsets.only(bottom: 70),
                            )
                          : Container(),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: _controlButtonsBottomMargin,
                  ),
                  child: ControlsComponent(
                    isFrontSide: viewModel.isFrontSide,
                    emphasizeKnownCardLabelButton:
                        viewModel.emphasizeKnownCardLabelButton,
                    emphasizeUnknownCardLabelButton:
                        viewModel.emphasizeNotKnownCardLabelButton,
                    onFlipTap: viewModel.onFlipTap,
                    onCardKnownTap: viewModel.triggerRightCardShift,
                    onCardNotKnownTap: viewModel.triggerLeftCardShift,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimations({required Widget child}) {
    return SlideInAnimationComponent(
      animateOnToggle: viewModel.slideInOnToggle,
      child: SlideOutRightAnimationComponent(
        animateOnToggle: viewModel.slideOutRightOnToggle,
        resetOnToggle: viewModel.slideInOnToggle,
        onAnimationCompleted: () => viewModel.onCardLabeled(Confidence.known),
        child: SlideOutLeftAnimationComponent(
          animateOnToggle: viewModel.slideOutLeftOnToggle,
          resetOnToggle: viewModel.slideInOnToggle,
          onAnimationCompleted: () =>
              viewModel.onCardLabeled(Confidence.unknown),
          child: child,
        ),
      ),
    );
  }
}
