import 'package:flutter/material.dart' hide Card;

import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/visual_element.dart';
import 'add_card_button_bloc.dart';
import 'add_card_button_view_model.dart';

class AddCardButtonComponent extends StatelessWidget {
  const AddCardButtonComponent({required this.deckId, Key? key})
      : super(key: key);

  final String deckId;

  @override
  Widget build(BuildContext context) {
    return Component<AddCardButtonBloc>(
      createViewModel: (bloc) => bloc.createViewModel(deckId: deckId),
      builder: (context, bloc) {
        return StreamBuilder<AddCardButtonViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return FloatingActionButton(
                onPressed: () {/* NO-OP */},
                child: const Icon(Icons.add_outlined),
              );
            }

            return _AddCardButtonView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _AddCardButtonView extends StatelessWidget {
  const _AddCardButtonView(this.viewModel);

  final AddCardButtonViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return VisualElement(
      id: VEs.createCardButton,
      childBuilder: (controller) {
        return FloatingActionButton(
          onPressed: () {
            controller.logTap();
            viewModel.onPressed();
          },
          child: const Icon(Icons.add_outlined),
        );
      },
    );
  }
}
