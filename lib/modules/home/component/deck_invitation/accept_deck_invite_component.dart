import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../utils/text_size.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/image_placeholder.dart';
import '../../../../widgets/visual_element.dart';
import 'accept_deck_invite_bloc.dart';
import 'accept_deck_invite_view_model.dart';

/// Bottom sheet to display an invitation for a deck.
class AcceptDeckInviteComponent extends StatelessWidget {
  const AcceptDeckInviteComponent(this._deckInviteId, {Key? key})
      : super(key: key);

  final String _deckInviteId;

  @override
  Widget build(BuildContext context) {
    return Component<AcceptDeckInviteBloc>(
      createViewModel: (bloc) => bloc.createViewModel(_deckInviteId),
      builder: (context, bloc) {
        return StreamBuilder<AcceptDeckInviteViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorIndicator(context, snapshot.error!);
            } else if (!snapshot.hasData) {
              return _buildLoadingIndicator();
            }

            return _AcceptDeckInviteView(snapshot.data!);
          },
        );
      },
    );
  }

  Widget _buildErrorIndicator(BuildContext context, Object error) {
    var errorText = S.of(context).errorWeWillFixText;
    if (error is OperationException) {
      if (error.isUserAlreadyMember) {
        errorText = S.of(context).alreadyMemberText;
      } else if (error.isUserInputError) {
        errorText = S.of(context).deckInvitationNotValidText;
      } else if (error.isNoInternet) {
        errorText = S.of(context).errorNoInternetText;
      }
    } else if (error is TimeoutException) {
      errorText = S.of(context).errorWeWillFixText;
    }

    return SizedBox(
      height: 160,
      child: Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorText,
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: CustomNavigator.getInstance().pop,
                  // Remove this when Flutter > 2.3.0 is released
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.standard,
                  ),
                  child: Text(S.of(context).ok.toUpperCase()),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      height: 160,
      child: Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      ),
    );
  }
}

class _AcceptDeckInviteView extends StatefulWidget {
  const _AcceptDeckInviteView(this.viewModel);

  final AcceptDeckInviteViewModel viewModel;

  @override
  _AcceptDeckInviteViewState createState() => _AcceptDeckInviteViewState();
}

class _AcceptDeckInviteViewState extends State<_AcceptDeckInviteView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildCoverImage(),
        _buildTitle(context),
        _buildSubtitle(context),
        _buildButtonRow(context),
      ],
    );
  }

  Widget _buildCoverImage() {
    return Transform.translate(
      offset: const Offset(0, -34),
      child: CircleAvatar(
        radius: 34,
        backgroundColor: Theme.of(context).cardColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: CachedNetworkImage(
            imageUrl: widget.viewModel.coverImageUrl,
            fit: BoxFit.cover,
            height: 64,
            width: 64,
            placeholder: (context, url) => const ImagePlaceholder(),
            errorWidget: (context, url, error) => Icon(
              Icons.error_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -26),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          widget.viewModel.deckName,
          overflow: TextOverflow.fade,
          maxLines: 7,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          S.of(context).createdBy(widget.viewModel.creatorFullName),
          style: TextStyle(color: Theme.of(context).hintColor),
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }

  Widget _buildButtonRow(BuildContext context) {
    final joinDeckText = S.of(context).joinDeck.toUpperCase();
    final joinDeckButtonSize =
        textSize(joinDeckText, Theme.of(context).textTheme.button);

    return SafeArea(
      top: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: widget.viewModel.onCancelTap,
            // Remove this when Flutter > 2.3.0 is released
            style: TextButton.styleFrom(visualDensity: VisualDensity.standard),
            child: Text(S.of(context).cancel.toUpperCase()),
          ),
          VisualElement(
            id: VEs.joinDeckButton,
            childBuilder: (controller) {
              return TextButton(
                onPressed: widget.viewModel.onJoinTap,
                // Remove this when Flutter > 2.3.0 is released
                style:
                    TextButton.styleFrom(visualDensity: VisualDensity.standard),
                child: !widget.viewModel.isLoading
                    ? Text(joinDeckText)
                    : SizedBox(
                        width: joinDeckButtonSize.width,
                        child: const Center(child: IconSizedLoadingIndicator()),
                      ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
