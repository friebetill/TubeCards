import 'package:flutter/material.dart' hide Card;
import 'package:flutter/widgets.dart';

import '../../../../widgets/component/component.dart';
import '../../../../widgets/cover_image.dart';
import 'deck_cover_image_bloc.dart';
import 'deck_cover_image_view_model.dart';

class DeckCoverImageComponent extends StatelessWidget {
  const DeckCoverImageComponent({required this.deckId, Key? key})
      : super(key: key);

  final String deckId;

  @override
  Widget build(BuildContext context) {
    return Component<DeckCoverImageBloc>(
      createViewModel: (bloc) => bloc.createViewModel(deckId: deckId),
      builder: (context, bloc) {
        return StreamBuilder<DeckCoverImageViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            return _DeckCoverImageView(snapshot.data);
          },
        );
      },
    );
  }
}

class _DeckCoverImageView extends StatelessWidget {
  const _DeckCoverImageView(this.viewModel);

  final DeckCoverImageViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    return CoverImage(
      imageUrl: viewModel?.coverImageUrl,
      tag: viewModel?.deckId,
    );
  }
}
