import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/assets.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../utils/themes/dark_theme.dart';
import '../../../../widgets/brand_logo.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/stadium_button.dart';
import '../../../../widgets/visual_element.dart';
import '../../../login/component/login_form/login_form_component.dart';
import 'landing_bloc.dart';
import 'landing_view_model.dart';

class LandingComponent extends StatelessWidget {
  const LandingComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: darkTheme,
      child: Component<LandingBloc>(
        createViewModel: (bloc) => bloc.createViewModel(),
        builder: (context, bloc) {
          return StreamBuilder<LandingViewModel>(
            stream: bloc.viewModel,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold();
              }

              return _LandingView(viewModel: snapshot.data!);
            },
          );
        },
      ),
    );
  }
}

@immutable
class _LandingView extends StatefulWidget {
  const _LandingView({required this.viewModel, Key? key}) : super(key: key);

  final LandingViewModel viewModel;

  @override
  _LandingViewState createState() => _LandingViewState();
}

class _LandingViewState extends State<_LandingView>
    with TickerProviderStateMixin {
  VideoPlayerController? _playerController;

  @override
  void initState() {
    super.initState();

    // Activate video for desktop when https://bit.ly/3wCBwjV is resolved
    final canDisplayVideos = Platform.isAndroid || Platform.isIOS;
    if (canDisplayVideos) {
      _playerController = VideoPlayerController.asset(Assets.videos.nightSky)
        ..setLooping(true)
        ..initialize()
        ..play();
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.initDeepLinkSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // This hidden [Scaffold] is needed for the status bar icons to show
        // the correct color. The reason is that uses code of the [AppBar]
        // to determine the color of the status bar. If no [AppBar] is
        // present, the color is not adjusted.
        Scaffold(appBar: AppBar(elevation: 0)),
        _buildVideoBackground(),
        // This second Scaffold is needed so that SnackBar messages will be
        // visible and not be buried below the video.
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            // The top padding is the sum of the height of the status
            // bar (24), app bar(56) and extra bottom spacing from the
            // log in and sign up screens (8).
            padding: const EdgeInsets.only(
              left: 48,
              right: 48,
              top: 88,
              bottom: 48,
            ),
            child: Center(
              child: SizedBox(
                width: maxWidgetWidth,
                child: Column(
                  children: <Widget>[
                    const BrandLogo(
                      size: BrandLogoSize.large,
                      showLogo: false,
                    ),
                    const Spacer(),
                    _buildGetStartedButton(),
                    const SizedBox(height: 16),
                    _buildSignUpButton(),
                    const SizedBox(height: 8),
                    Center(child: _buildAlreadyRegisteredButton()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _playerController?.dispose();
    super.dispose();
  }

  Widget _buildVideoBackground() {
    return Center(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(),
        child: AspectRatio(
          aspectRatio: 360 / 640,
          child: _playerController != null &&
                  _playerController!.value.isInitialized
              ? VideoPlayer(_playerController!)
              : Image.asset(
                  Assets.images.nightSkyPlaceholder,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return VisualElement(
      id: VEs.getStartedButton,
      childBuilder: (controller) {
        return SizedBox(
          height: 56,
          width: double.infinity,
          child: StadiumButton(
            text: S.of(context).getStarted.toUpperCase(),
            onPressed: () {
              controller.logTap();
              widget.viewModel.onGetStartedTap();
            },
            elevation: 0,
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
    return VisualElement(
      id: VEs.signUpButton,
      childBuilder: (controller) {
        return SizedBox(
          height: 56,
          width: double.infinity,
          child: StadiumButton(
            text: S.of(context).signUp.toUpperCase(),
            onPressed: () {
              controller.logTap();
              widget.viewModel.onSignUpTap();
            },
            elevation: 0,
            borderColor: Colors.white,
            textColor: Colors.white,
            boldText: true,
          ),
        );
      },
    );
  }

  Widget _buildAlreadyRegisteredButton() {
    return VisualElement(
      id: VEs.alreadyRegisteredButton,
      childBuilder: (controller) {
        return StadiumButton(
          text: S.of(context).alreadyRegistered.toUpperCase(),
          textColor: Colors.white,
          fontSize: 12,
          elevation: 0,
          onPressed: () {
            controller.logTap();
            widget.viewModel.onAlreadyRegisteredTap();
          },
        );
      },
    );
  }
}
