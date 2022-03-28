import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/offer_review.dart';
import '../../../../data/models/user.dart';
import '../../../../data/repositories/offer_repository.dart';
import '../../../../data/repositories/offer_review_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../sign_up/sign_up_page.dart';
import 'rate_offer_component.dart';
import 'rate_offer_view_model.dart';

/// BLoC for the [RateOfferComponent].
///
/// Exposes a [RateOfferViewModel] for that component to use.
@injectable
class RateOfferBloc with ComponentBuildContext, ComponentLifecycleListener {
  RateOfferBloc(
    this._offerRepository,
    this._offerReviewRepository,
    this._userRepository,
  );

  final _logger = Logger((RateOfferBloc).toString());

  final OfferRepository _offerRepository;
  final OfferReviewRepository _offerReviewRepository;
  final UserRepository _userRepository;

  Stream<RateOfferViewModel>? _viewModel;
  Stream<RateOfferViewModel>? get viewModel => _viewModel;

  OfferReview? _existingOfferReview;

  final _offerReview = BehaviorSubject<OfferReview>();
  final _showTextFields = BehaviorSubject.seeded(false);
  final _isUpsertReviewLoading = BehaviorSubject.seeded(false);
  final _isDeleteReviewLoading = BehaviorSubject.seeded(false);

  Stream<RateOfferViewModel> createViewModel(String offerId) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    _offerReview.addStream(_offerRepository.get(offerId).take(1).map((offer) {
      if (offer.viewerReview != null) {
        _existingOfferReview = offer.viewerReview;
      }

      return offer.viewerReview ?? const OfferReview(description: '');
    }));

    return _viewModel = Rx.combineLatest6(
      Stream.value(offerId),
      _offerReview,
      _userRepository.viewer(),
      _showTextFields,
      _isUpsertReviewLoading,
      _isDeleteReviewLoading,
      _createViewModel,
    );
  }

  RateOfferViewModel _createViewModel(
    String offerId,
    OfferReview offerReview,
    User? viewer,
    bool showTextFields,
    bool isUpsertReviewLoading,
    bool isDeleteReviewLoading,
  ) {
    return RateOfferViewModel(
      viewer: viewer!,
      offerReview: offerReview,
      showTextFields: showTextFields,
      isDeleteReviewLoading: isDeleteReviewLoading,
      isSubmitLoading: isUpsertReviewLoading,
      onShowTextFieldTap: () => _showTextFields.add(true),
      onRatingChanged: _handleRatingChanged,
      onDescriptionChanged: _handleDescriptionChanged,
      onSubmit: () => _handleSubmitReviewTap(offerId),
      onDeleteReviewTap: _existingOfferReview != null
          ? () => _handleDeleteReviewTap(offerId)
          : null,
      onCreateAccountTap: () {
        CustomNavigator.getInstance().pushNamed(SignUpPage.routeName);
      },
    );
  }

  @override
  void dispose() {
    _offerReview.close();
    _showTextFields.close();
    _isUpsertReviewLoading.close();
    _isDeleteReviewLoading.close();
    super.dispose();
  }

  Future<void> _handleSubmitReviewTap(String offerId) async {
    if (_isUpsertReviewLoading.value && _isDeleteReviewLoading.value) {
      return;
    }

    final isOfferReviewUnchanged = _existingOfferReview != null &&
        _offerReview.value.rating == _existingOfferReview!.rating &&
        _offerReview.value.description == _existingOfferReview!.description;
    if (isOfferReviewUnchanged) {
      _showTextFields.add(false);
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final isValidRating = _offerReview.value.rating != null &&
        (_offerReview.value.rating! >= 1 || _offerReview.value.rating! <= 5);
    if (!isValidRating) {
      return messenger.showErrorSnackBar(
        text: i18n.enterRatingText,
        theme: theme,
      );
    }

    _isUpsertReviewLoading.add(true);
    try {
      await _offerReviewRepository.upsertReview(
        offerId: offerId,
        rating: _offerReview.value.rating!,
        description: _offerReview.value.description,
      );
      messenger.showSuccessSnackBar(
        text: i18n.thankYouForYourReview,
        theme: theme,
      );
      _existingOfferReview = _offerReview.value;
      _showTextFields.add(false);
    } on OperationException catch (e, s) {
      _handleOperationException(i18n, messenger, theme, e, s);
    } on TimeoutException {
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during submitting rating', e, s);
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } finally {
      _isUpsertReviewLoading.add(false);
    }
  }

  Future<void> _handleDeleteReviewTap(String offerID) async {
    if (_isUpsertReviewLoading.value && _isDeleteReviewLoading.value) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    _isDeleteReviewLoading.add(true);
    try {
      await _offerReviewRepository.delete(offerId: offerID);
      _showTextFields.add(false);
      _offerReview.add(const OfferReview(description: ''));
      _existingOfferReview = null;
    } on OperationException catch (e, s) {
      _handleOperationException(i18n, messenger, theme, e, s);
    } on TimeoutException {
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during offer deletion', e, s);
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } finally {
      _isDeleteReviewLoading.add(false);
    }
  }

  void _handleRatingChanged(int rating) {
    _offerReview.add(_offerReview.value.copyWith(rating: rating));
    _showTextFields.add(true);
  }

  void _handleDescriptionChanged(String description) {
    _offerReview.add(_offerReview.value.copyWith(description: description));
  }

  void _handleOperationException(
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
    OperationException e,
    StackTrace s,
  ) {
    var exceptionText = i18n.errorUnknownText;
    if (e.isNoInternet) {
      exceptionText = i18n.errorNoInternetText;
    } else if (e.isServerOffline) {
      exceptionText = i18n.errorWeWillFixText;
    } else {
      _logger.severe('Exception during upsert/delete offer review', e, s);
    }

    messenger.showErrorSnackBar(theme: theme, text: exceptionText);
  }
}
