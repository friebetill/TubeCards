import 'package:flutter/material.dart';

import '../../../data/models/connection.dart';
import '../../../data/models/offer.dart';
import '../../../i18n/i18n.dart';
import '../../../utils/logging/visual_element_ids.dart';
import '../../../widgets/visual_element.dart';
import '../../shared/horizontal_list_shelf_component.dart';
import 'offer_item_component.dart';

class ViewerOffersShelf extends StatelessWidget {
  const ViewerOffersShelf({
    required this.viewerOfferConnection,
    required this.onOfferTap,
    required this.onPublishTap,
    Key? key,
  }) : super(key: key);

  final Connection<Offer> viewerOfferConnection;
  final ValueSetter<Offer> onOfferTap;
  final VoidCallback onPublishTap;

  @override
  Widget build(BuildContext context) {
    return HorizontalListShelfComponent(
      title: S.of(context).publishedDecks,
      button: VisualElement(
        id: VEs.publishOfferButton,
        childBuilder: (controller) {
          return TextButton(
            onPressed: () {
              controller.logTap();
              onPublishTap();
            },
            child: Text(S.of(context).publish.toUpperCase()),
          );
        },
      ),
      children: [
        if (viewerOfferConnection.totalCount == 0)
          _buildEmptyState(context)
        else
          ...viewerOfferConnection.nodes!
              .map((o) => VisualElement(
                    id: VEs.offerItem,
                    childBuilder: (controller) {
                      return OfferItemComponent(
                        offer: o,
                        onTap: () {
                          controller.logTap();
                          onOfferTap(o);
                        },
                      );
                    },
                  ))
              .toList(),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 32,
      height: OfferItemComponent.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).noDecksYet,
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).publishDecksCaptionText,
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
