import 'package:flutter/material.dart';

import '../../../../widgets/component/component.dart';
import 'app_bar_overlay_bloc.dart';
import 'app_bar_overlay_view_model.dart';

class AppBarOverlayComponent extends StatelessWidget {
  const AppBarOverlayComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<AppBarOverlayBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<AppBarOverlayViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _AppBarOverlayView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

class _AppBarOverlayView extends StatelessWidget {
  const _AppBarOverlayView({required this.viewModel, Key? key})
      : super(key: key);

  final AppBarOverlayViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Use AnimatedSwitcher instead of AnimatedOpacity to remove the clickable
    // area if the widget is not visible
    return AnimatedSwitcher(
      // We choose a short duration since there is some inherent delay before
      // the screen is re-rendered and thus we need to minimize total duration.
      duration: const Duration(milliseconds: 100),
      child: viewModel.isVisible ? _buildAppBar() : const SizedBox.shrink(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 76,
      color: const Color.fromRGBO(0, 0, 0, 0.25),
      child: Padding(
        // Ensures that the leading icon is at the correct position.
        padding: const EdgeInsets.only(top: 25),
        child: Row(
          children: const <Widget>[
            SizedBox(
              height: 76,
              width: 56,
              child: BackButton(
                key: ValueKey('back-button'),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
