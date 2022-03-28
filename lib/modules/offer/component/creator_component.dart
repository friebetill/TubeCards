import 'package:flutter/material.dart';

import '../../../data/models/user.dart';
import '../../../i18n/i18n.dart';

class CreatorComponent extends StatelessWidget {
  const CreatorComponent({required this.creator, Key? key}) : super(key: key);

  final User creator;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCreatorAvatar(context),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${creator.firstName} ${creator.lastName}',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              Text(
                S
                    .of(context)
                    .publishedCountDecks(creator.offerConnection!.totalCount!),
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      child: Text(
        creator.firstName![0].toUpperCase(),
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
