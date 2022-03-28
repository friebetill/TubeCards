import 'package:flutter/material.dart';

import 'component/offer_preview/offer_preview_component.dart';

class OfferPreviewPage extends StatelessWidget {
  const OfferPreviewPage({required this.deckId, Key? key}) : super(key: key);

  /// The name of the route to the [OfferPreviewPage] screen.
  static const String routeName = '/marketplace/offer-preview';

  final String deckId;

  @override
  Widget build(BuildContext context) => OfferPreviewComponent(deckId: deckId);
}
