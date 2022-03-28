import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/connection.dart';
import '../../../../data/models/flexible_size_offer_connection.dart';
import '../../../../data/models/offer.dart';
import '../../../../data/repositories/offer_repository.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../offer/offer_page.dart';
import '../../../select_deck/select_deck_page.dart';
import 'marketplace_component.dart';
import 'marketplace_viewmodel.dart';

/// BLoC for the [MarketplaceComponent].
///
/// Exposes a [MarketplaceViewModel] for that component to use.
@injectable
class MarketplaceBloc with ComponentBuildContext {
  MarketplaceBloc(this._offerRepository);

  final OfferRepository _offerRepository;

  Stream<MarketplaceViewModel>? _viewModel;
  Stream<MarketplaceViewModel>? get viewModel => _viewModel;

  Stream<MarketplaceViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest4(
      _offerRepository.getSubscribedOffers(
          fetchPolicy: FetchPolicy.CacheAndNetwork),
      _offerRepository.viewerOffers(fetchPolicy: FetchPolicy.CacheAndNetwork),
      _offerRepository.getPopular(fetchPolicy: FetchPolicy.CacheAndNetwork),
      _offerRepository.getNew(fetchPolicy: FetchPolicy.CacheAndNetwork),
      _createViewModel,
    );
  }

  MarketplaceViewModel _createViewModel(
    Connection<Offer> subscribedOffersConnection,
    Connection<Offer> viewerOfferConnection,
    Connection<Offer> recommendedOfferConnection,
    FlexibleSizeOfferConnection newOfferConnection,
  ) {
    return MarketplaceViewModel(
      subscribedOffersConnection: subscribedOffersConnection,
      viewerOfferConnection: viewerOfferConnection,
      popularOfferConnection: recommendedOfferConnection,
      newOfferConnection: newOfferConnection,
      onPublishTap: _handlePublishTap,
      onOfferTap: _handleOfferTap,
      refetch: () async {
        await Future.wait([
          subscribedOffersConnection.refetch!(),
          viewerOfferConnection.refetch!(),
          recommendedOfferConnection.refetch!(),
          newOfferConnection.refetch!(),
        ]);
      },
    );
  }

  void _handlePublishTap() {
    CustomNavigator.getInstance().pushNamed(SelectDeckPage.routeName);
  }

  void _handleOfferTap(Offer offer) {
    CustomNavigator.getInstance().pushNamed(
      OfferPage.routeName,
      args: offer.id,
    );
  }
}
