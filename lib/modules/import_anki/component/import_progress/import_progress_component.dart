import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/config.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/import/progress_state.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../data/anki_package.dart';
import 'import_progress_bloc.dart';
import 'import_progress_view_model.dart';

class ImportProgressComponent extends StatelessWidget {
  const ImportProgressComponent({
    required this.package,
    required this.onOpenEmailAppTap,
    Key? key,
  }) : super(key: key);

  final AnkiPackage package;
  final AsyncCallback onOpenEmailAppTap;

  @override
  Widget build(BuildContext context) {
    return Component<ImportProgressBloc>(
      createViewModel: (bloc) => bloc.createViewModel(
        package: package,
        onOpenEmailAppTap: onOpenEmailAppTap,
      ),
      builder: (context, bloc) {
        return StreamBuilder<ImportProgressViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SimpleSkeleton(appBarTitle: S.of(context).importFromAnki);
            }

            return _ImportProgressView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _ImportProgressView extends StatefulWidget {
  const _ImportProgressView({required this.viewModel, Key? key})
      : super(key: key);

  final ImportProgressViewModel viewModel;

  @override
  __ImportProgressViewState createState() => __ImportProgressViewState();
}

class __ImportProgressViewState extends State<_ImportProgressView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeAnimationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _fadeAnimation = _fadeAnimationController.drive(
      CurveTween(curve: Curves.easeInOutSine),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isError =
        widget.viewModel.importState == ProgressState.isGeneralError ||
            widget.viewModel.importState == ProgressState.isInternetError;

    return WillPopScope(
      onWillPop: () async {
        widget.viewModel.onCloseTap();

        // Always return false because popping is handled by onCancelTap
        return false;
      },
      child: PageCallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          LogicalKeySet(LogicalKeyboardKey.escape): widget.viewModel.onCloseTap,
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: widget.viewModel.importState == ProgressState.isImporting
                  ? const Icon(Icons.close_outlined)
                  : const BackButtonIcon(),
              onPressed: widget.viewModel.onCloseTap,
              tooltip: widget.viewModel.importState == ProgressState.isImporting
                  ? closeTooltip(context)
                  : backTooltip(context),
            ),
            title: Text(S.of(context).uploadingcards),
            elevation: 0,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Spacer(flex: 6),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: _buildProgressIndicator(context),
                ),
              ),
              const Spacer(),

              if (!isError) const Spacer(flex: 2),
              if (isError)
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        widget.viewModel.importState ==
                                ProgressState.isInternetError
                            ? S.of(context).errorNoInternetText
                            : S
                                .of(context)
                                .pleaseSendUsAnEmailAtSupport(supportEmail),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              const Spacer(flex: 3),
              // Size of extended floating action button + padding
              const SizedBox(height: 48.0 + 16),
            ],
          ),
          floatingActionButton: _buildFAB(context),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    var currentStep = 0;
    if (widget.viewModel.importProgress != null &&
        widget.viewModel.importProgress!.toPercent().isFinite) {
      // Multiply by 10 to show a progress by 0.1 percent
      currentStep =
          (widget.viewModel.importProgress!.toPercent(1) * 10).toInt();
    }

    return CircularStepProgressIndicator(
      totalSteps: 1000,
      stepSize: 1,
      currentStep: currentStep,
      selectedColor:
          widget.viewModel.importState == ProgressState.isImporting ||
                  widget.viewModel.importState == ProgressState.isDone
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
      unselectedColor: Colors.grey[200],
      padding: 0,
      width: 200,
      height: 200,
      selectedStepSize: 10,
      unselectedStepSize: 5,
      roundedCap: (_, __) => true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildInnerProgressWidget(context),
      ),
    );
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Widget _buildInnerProgressWidget(BuildContext context) {
    var subtitleText = '';
    switch (widget.viewModel.importState) {
      case ProgressState.isImporting:
        if (widget.viewModel.remainingTime == null) {
          subtitleText = S.of(context).calculatingRemainingTime;
        } else if (widget.viewModel.remainingTime!.inMinutes > 120) {
          subtitleText = S
              .of(context)
              .hoursRemaining(widget.viewModel.remainingTime!.inHours);
        } else if (widget.viewModel.remainingTime!.inSeconds > 180) {
          subtitleText = S
              .of(context)
              .minutesRemaining(widget.viewModel.remainingTime!.inMinutes);
        } else {
          subtitleText = S
              .of(context)
              .secondsRemaining(widget.viewModel.remainingTime!.inSeconds);
        }
        break;
      case ProgressState.isDone:
        subtitleText = S.of(context).importFinished;
        break;
      case ProgressState.isGeneralError:
      case ProgressState.isInternetError:
        subtitleText = S.of(context).anErrorOccured;
    }

    final isError =
        widget.viewModel.importState == ProgressState.isGeneralError ||
            widget.viewModel.importState == ProgressState.isInternetError;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: widget.viewModel.importProgress
                        ?.toPercent()
                        .toInt()
                        .toString() ??
                    '0',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 32),
              ),
              TextSpan(
                text: '%',
                style: Theme.of(context).textTheme.bodyText1!,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FadeTransition(
          opacity: widget.viewModel.remainingTime != null || isError
              ? const AlwaysStoppedAnimation(1)
              : _fadeAnimation,
          child: Text(
            subtitleText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    switch (widget.viewModel.importState) {
      case ProgressState.isImporting:
        return FloatingActionButton.extended(
          label: Text(S.of(context).abortImport.toUpperCase()),
          onPressed: widget.viewModel.onCloseTap,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      case ProgressState.isGeneralError:
        return FloatingActionButton.extended(
          label: Text(S.of(context).openEmailApp.toUpperCase()),
          onPressed: widget.viewModel.onOpenEmailAppTap,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
        );
      case ProgressState.isDone:
      case ProgressState.isInternetError:
        return FloatingActionButton.extended(
          label: Text(S.of(context).goToHomePage.toUpperCase()),
          onPressed: widget.viewModel.onCloseTap,
        );
    }
  }
}
