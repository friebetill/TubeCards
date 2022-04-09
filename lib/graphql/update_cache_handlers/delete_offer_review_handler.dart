import 'package:ferry/typed_links.dart';

import '../fragments/__generated__/offer_fragment.data.gql.dart';
import '../fragments/__generated__/offer_fragment.req.gql.dart';
import '../mutations/__generated__/delete_offer_review.data.gql.dart';
import '../mutations/__generated__/delete_offer_review.var.gql.dart';

const String deleteOfferReviewHandlerKey = 'deleteOfferReviewHandler';

void deleteOfferReviewHandler(
  CacheProxy proxy,
  OperationResponse<GDeleteOfferReviewData, GDeleteOfferReviewVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  const updateMethods = [_updateOfferFragment];

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, response.data!.deleteOfferReview.offer);
  }
}

void _updateOfferFragment(
  CacheProxy proxy,
  GDeleteOfferReviewData_deleteOfferReview_offer offer,
) {
  final request = GOfferFragmentReq((u) => u.idFields = {'id': offer.id});
  final response = GOfferFragmentData.fromJson(offer.toJson());

  proxy.writeFragment(request, response);
}
