import 'package:flutter/foundation.dart';

import '../../../../data/models/offer_review.dart';
import '../../../../data/models/user.dart';

class RateOfferViewModel {
  const RateOfferViewModel({
    required this.viewer,
    required this.offerReview,
    required this.showTextFields,
    required this.isSubmitLoading,
    required this.isDeleteReviewLoading,
    required this.onSubmit,
    required this.onRatingChanged,
    required this.onDescriptionChanged,
    required this.onDeleteReviewTap,
    required this.onShowTextFieldTap,
    required this.onCreateAccountTap,
  });

  final User viewer;
  final OfferReview offerReview;
  final bool showTextFields;
  final bool isSubmitLoading;
  final bool isDeleteReviewLoading;
  final VoidCallback onSubmit;
  final ValueSetter<int> onRatingChanged;
  final ValueSetter<String> onDescriptionChanged;
  final VoidCallback? onDeleteReviewTap;
  final VoidCallback onShowTextFieldTap;
  final VoidCallback onCreateAccountTap;
}
