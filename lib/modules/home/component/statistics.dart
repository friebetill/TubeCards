import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../i18n/i18n.dart';

class Statistics extends StatelessWidget {
  const Statistics({
    required this.totalDueCardsCount,
    required this.totalCardsCount,
    Key? key,
  }) : super(key: key);

  final int totalDueCardsCount;
  final int totalCardsCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCardsCount(context),
        const Divider(),
        _buildDueCardsCount(context),
      ],
    );
  }

  Widget _buildDueCardsCount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.whatshot_outlined, size: 16),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 90),
          child: Text(
            S.of(context).dueCards,
            overflow: TextOverflow.fade,
            maxLines: 1,
            softWrap: false,
          ),
        ),
        const Spacer(),
        Text(
          NumberFormat.compact().format(totalDueCardsCount),
          style: _emphasizedNumberStyle(context),
        ),
      ],
    );
  }

  Widget _buildCardsCount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(children: const [
          // To align the icon to the text
          SizedBox(height: 1),
          Icon(Icons.crop_portrait_outlined, size: 16),
        ]),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 90),
          child: Text(
            S.of(context).cards(totalCardsCount),
            overflow: TextOverflow.fade,
            maxLines: 1,
            softWrap: false,
          ),
        ),
        const Spacer(),
        Text(
          NumberFormat.compact().format(totalCardsCount),
          style: _emphasizedNumberStyle(context),
        ),
      ],
    );
  }

  TextStyle _emphasizedNumberStyle(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .bodyText1!
        .copyWith(color: Theme.of(context).colorScheme.primary);
  }
}
