import 'package:flutter/material.dart';

import 'component/offer/offer_component.dart';

class OfferPage extends StatelessWidget {
  const OfferPage({required this.offerId, Key? key}) : super(key: key);

  /// The name of the route to the [OfferPage] screen.
  static const String routeName = '/marketplace/offer';

  final String offerId;

  @override
  Widget build(BuildContext context) => OfferComponent(offerId: offerId);
}
