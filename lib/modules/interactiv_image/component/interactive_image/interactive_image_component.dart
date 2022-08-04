import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../widgets/component/component.dart';
import 'interactive_image_bloc.dart';
import 'interactive_image_view_model.dart';

class InteractiveImageComponent extends StatelessWidget {
  const InteractiveImageComponent(this.imageUrl, {Key? key}) : super(key: key);

  /// The url of the image.
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Component<InteractiveImageBloc>(
      createViewModel: (bloc) => bloc.createViewModel(imageUrl),
      builder: (context, bloc) {
        return StreamBuilder<InteractiveImageViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Icon(Icons.broken_image_outlined, size: 56),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return _InteractiveImageView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

class _InteractiveImageView extends StatefulWidget {
  const _InteractiveImageView({required this.viewModel, Key? key})
      : super(key: key);

  final InteractiveImageViewModel viewModel;

  @override
  _InteractiveImageViewState createState() => _InteractiveImageViewState();
}

class _InteractiveImageViewState extends State<_InteractiveImageView>
    with SingleTickerProviderStateMixin {
  /// The duration of the zoom animation
  static const _zoomAnimationDuration = Duration(milliseconds: 200);

  /// The controller to control the [InteractiveViewer]
  late TransformationController _interactiveController;

  /// The controller to control the zoom animation after a double tap.
  late AnimationController _zoomAnimationController;

  /// The animation for zooming in and out after a double tap.
  late Animation<Matrix4> _zoomAnimation;

  /// The details of a double tap.
  late TapDownDetails _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _interactiveController = TransformationController();
    _zoomAnimationController = AnimationController(
      vsync: this,
      duration: _zoomAnimationDuration,
    )..addListener(() => _interactiveController.value = _zoomAnimation.value);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildInteractivity(
        child: Hero(
          tag: widget.viewModel.heroTag,
          child: Center(
            child: Container(
              // The white background is necessary for transparent images
              color: Colors.white,
              child: widget.viewModel.isSvgImage
                  ? SvgPicture.file(
                      widget.viewModel.image,
                      width: MediaQuery.of(context).size.width,
                    )
                  : Image.file(widget.viewModel.image),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _interactiveController.dispose();
    _zoomAnimationController.dispose();
    super.dispose();
  }

  Widget _buildInteractivity({required Widget child}) {
    return GestureDetector(
      onTap: widget.viewModel.onTap,
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      // Necessary so that the entire screen is interactive, http://bit.ly/3bhSdKg
      child: ClipRect(
        child: InteractiveViewer(
          transformationController: _interactiveController,
          maxScale: 4,
          child: child,
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    final position = _doubleTapDetails.localPosition;
    final endMatrix = _interactiveController.value != Matrix4.identity()
        ? Matrix4.identity()
        :
        // 3x zoom at the position of the double-click
        //
        // Explanation by example: Imagine an image that is only 1x1 in size.
        // If you double-click in the lower right corner of the image at (1,1),
        // the image enlarges by a factor of 3 to 3x3. The position is still at
        // (1,1), but should be at (3,3). So the image is moved to the upper
        // left by two times 1x1.
        //
        // I am not sure why the matrix operation are the other way around.
        (Matrix4.identity()
          ..translate(-position.dx * 2, -position.dy * 2)
          ..scale(3.0));

    _zoomAnimation = Matrix4Tween(
      begin: _interactiveController.value,
      end: endMatrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_zoomAnimationController),
    );
    _zoomAnimationController.forward(from: 0);
  }
}
