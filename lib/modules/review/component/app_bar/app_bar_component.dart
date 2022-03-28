import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/visual_element.dart';
import 'app_bar_bloc.dart';
import 'app_bar_view_model.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  const AppBarComponent({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Component<AppBarBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<AppBarViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            return _AppBarView(viewModel: snapshot.data);
          },
        );
      },
    );
  }
}

@immutable
class _AppBarView extends StatelessWidget {
  const _AppBarView({required this.viewModel, Key? key}) : super(key: key);

  final AppBarViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    const elevation = 0.0;

    return AppBar(
      title: Text(viewModel?.title ?? ''),
      elevation: elevation,
      leading: VisualElement(
        id: VEs.backButton,
        childBuilder: (controller) {
          return BackButton(
            key: const ValueKey('back-button'),
            onPressed: viewModel?.onBackTap != null
                ? () {
                    controller.logTap();
                    viewModel!.onBackTap();
                  }
                : null,
          );
        },
      ),
      actions: _buildActions(context),
      bottom: _buildProgressBar(context),
    );
  }

  PreferredSizeWidget _buildProgressBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          maxHeight: 4,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: viewModel?.progress ?? 0,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black12
                : Colors.white12,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      if (viewModel?.onTextToSpeechToggleTap != null)
        IconButton(
          icon: Icon(viewModel != null && viewModel!.isTextToSpeechEnabled
              ? Icons.volume_up_outlined
              : Icons.volume_off_outlined),
          onPressed: viewModel?.onTextToSpeechToggleTap,
        ),
      IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: viewModel?.onEditTap,
        tooltip: S.of(context).editCard,
      ),
    ];
  }
}
