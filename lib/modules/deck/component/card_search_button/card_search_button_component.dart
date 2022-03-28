import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/visual_element.dart';
import 'card_search_button_bloc.dart';
import 'card_search_button_view_model.dart';

class CardSearchButtonComponent extends StatelessWidget {
  const CardSearchButtonComponent({required this.deckId, Key? key})
      : super(key: key);

  final String deckId;

  @override
  Widget build(BuildContext context) {
    return Component<CardSearchButtonBloc>(
      createViewModel: (bloc) => bloc.createViewModel(deckId),
      builder: (context, bloc) {
        return StreamBuilder<CardSearchButtonViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            return _CardSearchButtonView(snapshot.data);
          },
        );
      },
    );
  }
}

class _CardSearchButtonView extends StatelessWidget {
  const _CardSearchButtonView(this.viewModel);

  final CardSearchButtonViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    return VisualElement(
      id: VEs.searchCardsButton,
      childBuilder: (controller) {
        return IconButton(
          onPressed: viewModel?.onTap != null
              ? () {
                  controller.logTap();
                  viewModel!.onTap();
                }
              : null,
          tooltip: S.of(context).search,
          icon: const Icon(Icons.search),
        );
      },
    );
  }
}
