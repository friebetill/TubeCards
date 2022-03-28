import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/visual_element.dart';
import '../../../shared/horizontal_list_shelf_component.dart';
import '../offer_item_component.dart';
import '../viewer_offers_shelf.dart';
import 'marketplace_bloc.dart';
import 'marketplace_viewmodel.dart';

class MarketplaceComponent extends StatelessWidget {
  const MarketplaceComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<MarketplaceBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<MarketplaceViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _MarketplaceView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _MarketplaceView extends StatelessWidget {
  const _MarketplaceView(this.viewModel);

  final MarketplaceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: viewModel.refetch,
      child: ListView(
        children: [
          const SizedBox(height: 16),
          ViewerOffersShelf(
            onPublishTap: viewModel.onPublishTap,
            onOfferTap: viewModel.onOfferTap,
            viewerOfferConnection: viewModel.viewerOfferConnection,
          ),
          if (viewModel.subscribedOffersConnection.totalCount! > 0) ...[
            const SizedBox(height: 8),
            _buildSubscribedOffers(context),
          ],
          if (viewModel.popularOfferConnection.totalCount! > 0) ...[
            const SizedBox(height: 8),
            _buildPopularOffers(context),
          ],
          const SizedBox(height: 8),
          _buildNewOffers(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSubscribedOffers(BuildContext context) {
    return HorizontalListShelfComponent(
      title: S.of(context).downloadedDecks,
      children: viewModel.subscribedOffersConnection.nodes!
          .map((o) => VisualElement(
              id: VEs.offerItem,
              childBuilder: (controller) {
                return OfferItemComponent(
                  offer: o,
                  onTap: () {
                    controller.logTap();
                    viewModel.onOfferTap(o);
                  },
                );
              }))
          .toList(),
    );
  }

  Widget _buildPopularOffers(BuildContext context) {
    return HorizontalListShelfComponent(
      title: S.of(context).popular,
      children: viewModel.popularOfferConnection.nodes!
          .map((o) => VisualElement(
              id: VEs.offerItem,
              childBuilder: (controller) {
                return OfferItemComponent(
                  offer: o,
                  onTap: () {
                    controller.logTap();
                    viewModel.onOfferTap(o);
                  },
                );
              }))
          .toList(),
    );
  }

  Widget _buildNewOffers(BuildContext context) {
    return HorizontalListShelfComponent(
      title: S.of(context).newText,
      children: viewModel.newOfferConnection.nodes!
          .map((o) => VisualElement(
              id: VEs.offerItem,
              childBuilder: (controller) {
                return OfferItemComponent(
                  offer: o,
                  onTap: () {
                    controller.logTap();
                    viewModel.onOfferTap(o);
                  },
                );
              }))
          .toList(),
    );
  }
}
