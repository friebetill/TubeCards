import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../i18n/i18n.dart';
import '../../../utils/custom_navigator.dart';
import '../../../utils/themes/custom_theme.dart';
import '../../../utils/tooltip_message.dart';
import '../../../widgets/component/component.dart';
import '../../../widgets/page_callback_shortcuts.dart';
import '../../../widgets/stadium_button.dart';
import '../component/review_statistic/review_statistic_component.dart';
import 'congratulation_bloc.dart';
import 'congratulation_view_model.dart';

class CongratulationComponent extends StatelessWidget {
  const CongratulationComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<CongratulationBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<CongratulationViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _CongratulationView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _CongratulationView extends StatefulWidget {
  const _CongratulationView(this.viewModel);

  final CongratulationViewModel viewModel;

  @override
  State<_CongratulationView> createState() => _CongratulationViewState();
}

class _CongratulationViewState extends State<_CongratulationView> {
  final _confettiController = ConfettiController();
  bool _isControllerDisposed = false;

  @override
  void initState() {
    super.initState();

    _confettiController.play();
    Future.delayed(const Duration(seconds: 5)).then((_) {
      if (!_isControllerDisposed) {
        _confettiController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sets the system status color to white
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PageCallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          LogicalKeySet(LogicalKeyboardKey.escape): () =>
              CustomNavigator.getInstance().pop(),
          LogicalKeySet(LogicalKeyboardKey.space): () =>
              CustomNavigator.getInstance().pop(),
        },
        child: Scaffold(
          body: Stack(children: <Widget>[
            _buildBackground(context),
            _buildConfetti(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Center(
                child: Column(
                  children: <Widget>[
                    const Spacer(flex: 2),
                    _buildCheckIcon(context),
                    const Spacer(),
                    const ReviewStatisticComponent(),
                    const Spacer(flex: 2),
                    _buildDoneButton(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isControllerDisposed = true;
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildBackground(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1.2),
            radius: 1.8,
            colors: Theme.of(context).brightness == Brightness.light
                ? const [Color(0xFF4FD66E), Color(0xFF00A77C)]
                : [
                    Theme.of(context).colorScheme.background,
                    Theme.of(context).colorScheme.background,
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckIcon(BuildContext context) {
    return Icon(
      Icons.check,
      size: 200,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Theme.of(context).custom.successColor,
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    final onFinishTapTooltip = buildTooltipMessage(
      message: S.of(context).done,
      windowsShortcut: S.of(context).spacebar,
      macosShortcut: S.of(context).spacebar,
      linuxShortcut: S.of(context).spacebar,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: Tooltip(
          message: onFinishTapTooltip.toString(),
          child: StadiumButton(
            text: S.of(context).done.toUpperCase(),
            onPressed: widget.viewModel.onContinueTap,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).custom.successColor,
            textColor: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    final confettiColors = Theme.of(context).brightness == Brightness.light
        ? const [Colors.white, Color(0xFF00FF6A), Color(0xFF00D4FF)]
        : const [Colors.white, Color(0xFF81AF84), Color(0xFF66AAB8)];
    final showAdditionalConfetti = MediaQuery.of(context).size.width > 600;

    return ShaderMask(
      // Fade out confetti, based on this post, https://bit.ly/3z2Fiod
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.transparent],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height * 3 / 4));
      },
      blendMode: BlendMode.dstIn,
      child: Stack(
        children: [
          _buildTopLeftConfetti(confettiColors),
          Visibility(
            visible: showAdditionalConfetti,
            child: _buildTopLeftCenterConfetti(confettiColors),
          ),
          _buildTopCenterConfetti(confettiColors),
          Visibility(
            visible: showAdditionalConfetti,
            child: _buildTopRightCenterConfetti(confettiColors),
          ),
          _buildTopRightConfetti(confettiColors),
        ],
      ),
    );
  }

  Widget _buildTopLeftConfetti(List<Color> confettiColors) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: pi / 4,
        colors: confettiColors,
      ),
    );
  }

  Widget _buildTopLeftCenterConfetti(List<Color> confettiColors) {
    return Align(
      alignment: const Alignment(-0.5, -1),
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: pi * 3 / 8,
        colors: confettiColors,
      ),
    );
  }

  Widget _buildTopCenterConfetti(List<Color> confettiColors) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: pi / 2,
        colors: confettiColors,
      ),
    );
  }

  Widget _buildTopRightCenterConfetti(List<Color> confettiColors) {
    return Align(
      alignment: const Alignment(0.5, -1),
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: pi * 5 / 8,
        colors: confettiColors,
      ),
    );
  }

  Widget _buildTopRightConfetti(List<Color> confettiColors) {
    return Align(
      alignment: Alignment.topRight,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: pi * 3 / 4,
        colors: confettiColors,
      ),
    );
  }
}
