import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../utils/responsiveness/breakpoints.dart';
import '../../../../widgets/component/component.dart';
import 'rate_offer_bloc.dart';
import 'rate_offer_view_model.dart';

class RateOfferComponent extends StatelessWidget {
  const RateOfferComponent({required this.offerId, Key? key}) : super(key: key);

  final String offerId;

  @override
  Widget build(BuildContext context) {
    return Component<RateOfferBloc>(
      createViewModel: (bloc) => bloc.createViewModel(offerId),
      builder: (context, bloc) {
        return StreamBuilder<RateOfferViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // Prevents a jumping widget.
              return const SizedBox(height: 200);
            }

            return _RateOfferView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _RateOfferView extends StatefulWidget {
  const _RateOfferView(this.viewModel);

  final RateOfferViewModel viewModel;

  @override
  State<_RateOfferView> createState() => _RateOfferViewState();
}

class _RateOfferViewState extends State<_RateOfferView> {
  final _descriptionController = TextEditingController();

  @override
  void didUpdateWidget(covariant _RateOfferView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewModel.offerReview.description != null &&
        widget.viewModel.offerReview.description !=
            _descriptionController.text) {
      _descriptionController.text = widget.viewModel.offerReview.description!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context),
        const SizedBox(height: 32),
        if (!widget.viewModel.viewer.isAnonymous!) ...[
          _buildRating(),
        ] else
          _buildAnonymousState(),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        S.of(context).rateThisDeck,
        style: Theme.of(context)
            .textTheme
            .headline5!
            .copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRating() {
    return SizedBox(
      width: Breakpoint.mobileToLarge,
      child: Column(
        children: [
          _buildViewerAvatar(context),
          const SizedBox(height: 16),
          _buildRatingBar(context),
          if (!widget.viewModel.showTextFields)
            _buildWriteReviewButton(context)
          else
            _buildReviewTextFields(context)
        ],
      ),
    );
  }

  Widget _buildViewerAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      child: Text(
        widget.viewModel.viewer.firstName![0].toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .headline5!
            .copyWith(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context) {
    return RatingBar(
      onRatingUpdate: (r) => widget.viewModel.onRatingChanged(r.toInt()),
      ratingWidget: RatingWidget(
        full: const Icon(Icons.star, color: Colors.amber),
        half: const Icon(Icons.star, color: Colors.amber),
        empty: const Icon(
          Icons.star_outline_outlined,
          color: Color(0xFFCCCCCC),
        ),
      ),
      itemSize: 28,
      minRating: 1,
      initialRating: widget.viewModel.offerReview.rating?.toDouble() ?? 0,
    );
  }

  Widget _buildWriteReviewButton(BuildContext context) {
    return TextButton(
      onPressed: widget.viewModel.onShowTextFieldTap,
      child: Text(
        widget.viewModel.offerReview.rating == null
            ? S.of(context).writeReview
            : S.of(context).updateReview,
      ),
    );
  }

  Widget _buildReviewTextFields(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          onChanged: widget.viewModel.onDescriptionChanged,
          maxLength: 250,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText:
                '${S.of(context).description} (${S.of(context).optional})',
            filled: true,
            fillColor: _getBackgroundColor(context),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.viewModel.onDeleteReviewTap != null)
              TextButton(
                onPressed: widget.viewModel.onDeleteReviewTap,
                child: !widget.viewModel.isDeleteReviewLoading
                    ? Text(
                        S.of(context).delete,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText1!.color),
                      )
                    : IconSizedLoadingIndicator(
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
              ),
            const SizedBox(width: 24),
            TextButton(
              onPressed: widget.viewModel.onSubmit,
              child: !widget.viewModel.isSubmitLoading
                  ? Text(S.of(context).submit)
                  : const IconSizedLoadingIndicator(),
            ),
          ],
        ),
      ],
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFF4F4F4)
        : Color.alphaBlend(
            ElevationOverlay.overlayColor(context, 4),
            Theme.of(context).colorScheme.surface,
          );
  }

  Widget _buildAnonymousState() {
    return SizedBox(
      // This value is measured and equal to the height of the avatar, rating
      // bar and the button.
      height: 140,
      width: Breakpoint.mobileToLarge,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context).noPermission,
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 12),
              Text(
                S.of(context).anonymousUserAddRatingSubtitleText,
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: widget.viewModel.onCreateAccountTap,
                child: Text(S.of(context).createAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
