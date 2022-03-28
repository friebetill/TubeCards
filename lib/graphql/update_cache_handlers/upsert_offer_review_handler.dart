import 'package:ferry/typed_links.dart';

import '../fragments/offer_fragment.data.gql.dart';
import '../fragments/offer_fragment.req.gql.dart';
import '../mutations/upsert_offer_review.data.gql.dart';
import '../mutations/upsert_offer_review.var.gql.dart';

const String upsertOfferReviewHandlerKey = 'upsertOfferReviewHandler';

void upsertOfferReviewHandler(
  CacheProxy proxy,
  OperationResponse<GUpsertOfferReviewData, GUpsertOfferReviewVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  const updateMethods = [_updateOfferFragment];

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, response.data!.upsertOfferReview.offer);
  }
}

void _updateOfferFragment(
  CacheProxy proxy,
  GUpsertOfferReviewData_upsertOfferReview_offer offer,
) {
  final request = GOfferFragmentReq((u) => u.idFields = {'id': offer.id});
  final response = GOfferFragmentData.fromJson(offer.toJson());

  proxy.writeFragment(request, response);
}
