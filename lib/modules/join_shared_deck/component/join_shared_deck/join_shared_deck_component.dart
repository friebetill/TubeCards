import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/assets.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/sizes.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/scalable_widgets/horizontal_scalable_box.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../../../widgets/stadium_button.dart';
import 'join_shared_deck_bloc.dart';
import 'join_shared_deck_view_model.dart';

class JoinSharedDeckComponent extends StatelessWidget {
  const JoinSharedDeckComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<JoinSharedDeckBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<JoinSharedDeckViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SimpleSkeleton(appBarTitle: S.of(context).sharedDeck);
            }

            return _JoinSharedDeckView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _JoinSharedDeckView extends StatefulWidget {
  const _JoinSharedDeckView({required this.viewModel, Key? key})
      : super(key: key);

  final JoinSharedDeckViewModel viewModel;

  @override
  _JoinSharedDeckViewState createState() => _JoinSharedDeckViewState();
}

class _JoinSharedDeckViewState extends State<_JoinSharedDeckView> {
  final _emailTextFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).sharedDeck),
          elevation: 0,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: CustomNavigator.getInstance().pop,
            tooltip: backTooltip(context),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height -
                      appBarHeight -
                      systemBarHeight,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    HorizontalScalableBox(
                      scaleFactor: 0.05,
                      child: SvgPicture.asset(Assets.images.teamWork),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      S.of(context).enterDeckInviteText,
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    _buildInviteLinkRow(),
                    const Spacer(flex: 2),
                    _buildJoinButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailTextFocus.dispose();
    super.dispose();
  }

  Widget _buildInviteLinkRow() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.viewModel.linkTextController,
              focusNode: _emailTextFocus,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: S.of(context).deckLink,
                errorText: widget.viewModel.linkErrorText,
                labelStyle: TextStyle(
                  color: widget.viewModel.linkErrorText != null
                      ? Theme.of(context).colorScheme.error
                      : _emailTextFocus.hasFocus
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).hintColor,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              textInputAction: TextInputAction.done,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.primary,
              visualDensity: VisualDensity.comfortable,
            ),
            onPressed: widget.viewModel.onPasteLinkTap,
            child: const SizedBox(
              height: 44,
              child: Icon(Icons.paste_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: StadiumButton(
          text: S.of(context).getDeckInviteInformation.toUpperCase(),
          onPressed: widget.viewModel.onJoinTap,
          backgroundColor: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.onPrimary,
          isLoading: widget.viewModel.isLoading,
        ),
      ),
    );
  }
}
