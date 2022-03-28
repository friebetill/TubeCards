import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../i18n/i18n.dart';
import '../../../utils/assets.dart';
import '../../../utils/custom_navigator.dart';
import '../../../utils/spacing.dart';
import '../../../utils/tooltip_message.dart';
import '../../../widgets/component/component.dart';
import '../../../widgets/markdown.dart';
import '../../../widgets/page_callback_shortcuts.dart';
import '../../../widgets/scalable_widgets/horizontal_scalable_box.dart';
import '../../../widgets/simple_skeleton.dart';
import '../whats_new_page.dart';
import 'whats_new_bloc.dart';
import 'whats_new_view_model.dart';

class WhatsNewComponent extends StatelessWidget {
  const WhatsNewComponent({required this.args, Key? key}) : super(key: key);

  final WhatsNewPageArguments args;

  @override
  Widget build(BuildContext context) {
    return Component<WhatsNewBloc>(
      createViewModel: (bloc) => bloc.createViewModel(args: args),
      builder: (context, bloc) {
        return StreamBuilder<WhatsNewViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SimpleSkeleton(appBarTitle: S.of(context).newFunctions);
            }

            return _WhatsNewPageView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _WhatsNewPageView extends StatelessWidget {
  const _WhatsNewPageView(this.viewModel);

  final WhatsNewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: CustomNavigator.getInstance().pop,
            tooltip: closeTooltip(context),
          ),
          title: Text(S.of(context).newFunctions),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 32, 16),
                children: [
                  _buildImage(context),
                  const SizedBox(height: spacing48Pixels),
                  Align(
                    child: _buildTextContent(context),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: spacing96Pixels,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildFloatingActionButton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Padding(
      // To compensate for the 32 pixel right padding from the ListView.
      padding: const EdgeInsets.only(left: 16),
      child: HorizontalScalableBox(
        minHeight: 140,
        scaleFactor: 0.05,
        child: SvgPicture.asset(Assets.images.startup),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: MarkdownBody(
        data: viewModel.text(context),
        imageBuilder: (uri, _, __) => buildMedia(
          url: uri.toString(),
          onImageTap: () => viewModel.onImageTap(uri.toString()),
        ),
        onTapLink: viewModel.onLinkTap,
        styleSheet: buildStyleSheet(context),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return SizedBox(
      width: 700,
      child: FloatingActionButton.extended(
        onPressed: viewModel.onContinueTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        label: Text(S.of(context).continueText.toUpperCase()),
      ),
    );
  }
}
