import 'package:flutter/material.dart';

import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/visual_element.dart';
import 'card_sort_button_bloc.dart';
import 'card_sort_button_view_model.dart';

class CardSortButtonComponent extends StatelessWidget {
  const CardSortButtonComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<CardSortButtonBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<CardSortButtonViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _LearnDueButtonSkeleton();
            }

            return _LearnDueButtonView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _LearnDueButtonView extends StatelessWidget {
  const _LearnDueButtonView(this.viewModel);

  final CardSortButtonViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return VisualElement(
      id: VEs.cardSortButton,
      childBuilder: (controller) {
        return IconButton(
          icon: const Icon(Icons.sort_outlined),
          onPressed: () {
            controller.logTap();
            viewModel.onTap();
          },
        );
      },
    );
  }
}

class _LearnDueButtonSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const IconButton(
      icon: Icon(Icons.sort_outlined),
      onPressed: null,
    );
  }
}
