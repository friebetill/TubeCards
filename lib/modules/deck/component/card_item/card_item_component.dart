import 'dart:math';

import 'package:flutter/material.dart' hide Card;
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/card.dart';
import '../../../../utils/custom_markdown_body.dart';
import '../../../../utils/durations.dart';
import '../../../../utils/formatted_duration.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../../../../widgets/visual_element.dart';
import '../../../home/component/strength_indicator.dart';
import 'card_item_bloc.dart';
import 'card_item_view_model.dart';

class CardItemComponent extends StatefulWidget {
  const CardItemComponent({required this.card, Key? key}) : super(key: key);

  // Use the card instead of the card ID to reduce the number of database
  // queries and thus speed up the UI.
  final Card card;

  @override
  CardItemComponentState createState() => CardItemComponentState();
}

class CardItemComponentState extends State<CardItemComponent> {
  // Needed to ensure CardItemComponent is rebuilt when the given Card changes
  late final _card = BehaviorSubject<Card>.seeded(widget.card);

  @override
  Widget build(BuildContext context) {
    return Component<CardItemBloc>(
      createViewModel: (bloc) => bloc.createViewModel(_card),
      builder: (context, bloc) {
        return StreamBuilder<CardItemViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 56);
            }

            return _CardItemView(snapshot.data!);
          },
        );
      },
    );
  }

  @override
  void didUpdateWidget(CardItemComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.card != oldWidget.card) {
      _card.add(widget.card);
    }
  }

  @override
  void dispose() {
    _card.close();
    super.dispose();
  }
}

class _CardItemView extends StatelessWidget {
  const _CardItemView(this.viewModel);

  final CardItemViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return VisualElement(
      id: VEs.cardItemTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          backgroundColor: viewModel.isSelected
              ? Theme.of(context).selectedRowColor
              : Colors.transparent,
          child: ListTile(
            leading: _buildAnimatedCircleAvatar(context),
            key: Key('card-item-tile-${viewModel.card.id}'),
            onTap: () {
              controller.logTap();
              viewModel.onTap();
            },
            onLongPress: () {
              controller.logLongPress();
              viewModel.onLongPress();
            },
            visualDensity: VisualDensity.standard,
            // Use MarkdownBody widget if it supports maxLines and overflow, https://bit.ly/2VoP854
            title: CustomMarkdownBody(
              // The text fades out to the bottom if there is a linebreak
              // before the end of line is reached. To prevent this we remove
              // the linebreak.
              data: viewModel.previewText.split('\n').first,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            subtitle: _buildDetails(context),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCircleAvatar(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.black87;

    return VisualElement(
      id: VEs.cardItemTileAvatar,
      childBuilder: (controller) {
        return GestureDetector(
          // To make the whole rectangle clickable.
          behavior: HitTestBehavior.opaque,
          onTap: () {
            controller.logTap();
            viewModel.onAvatarTap();
          },
          child: TweenAnimationBuilder<double>(
            duration: Durations.milliseconds100,
            tween: Tween<double>(begin: 0, end: viewModel.isSelected ? pi : 0),
            builder: (context, value, child) {
              return Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.rotationY(value),
                child: value > pi / 2
                    ? Transform(
                        alignment: FractionalOffset.center,
                        transform: Matrix4.rotationY(-pi),
                        child: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Icon(Icons.check_outlined, color: textColor),
                        ),
                      )
                    : SizedBox(
                        width: 40,
                        height: 40,
                        child: StrengthIndicator(
                          strength:
                              viewModel.card.latestLearningState.strength!,
                          showSubtitle: false,
                          numberStyle: Theme.of(context).textTheme.bodyText1!,
                          unitStyle: Theme.of(context).textTheme.caption!,
                        ),
                      ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const WidgetSpan(child: Icon(Icons.edit_outlined, size: 12)),
          const TextSpan(text: ' '),
          TextSpan(
            text: DateTime.now()
                .difference(viewModel.card.updatedAt!)
                .countWithUnitAndAgo(context),
          ),
        ],
      ),
      style: Theme.of(context).textTheme.caption,
    );
  }
}
