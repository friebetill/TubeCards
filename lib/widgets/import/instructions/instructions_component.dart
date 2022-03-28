import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../i18n/i18n.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/markdown.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../../utils/custom_navigator.dart';
import '../../../utils/tooltip_message.dart';
import '../../page_callback_shortcuts.dart';
import 'instructions_bloc.dart';
import 'instructions_view_model.dart';

class InstructionsComponent extends StatelessWidget {
  const InstructionsComponent({
    required this.appBarTitle,
    required this.markdownBody,
    required this.onSelectFile,
    Key? key,
  }) : super(key: key);

  final String appBarTitle;
  final String markdownBody;
  final VoidCallback onSelectFile;

  @override
  Widget build(BuildContext context) {
    return Component<InstructionsBloc>(
      createViewModel: (bloc) => bloc.createViewModel(
        appBarTitle: appBarTitle,
        markdownBody: markdownBody,
        handleSelectFileTap: onSelectFile,
      ),
      builder: (context, bloc) {
        return StreamBuilder<InstructionsViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SimpleSkeleton(appBarTitle: appBarTitle);
            }

            return _SelectFileView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _SelectFileView extends StatelessWidget {
  const _SelectFileView({required this.viewModel, Key? key}) : super(key: key);

  final InstructionsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          title: Text(viewModel.appBarTitle),
          elevation: 0,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: CustomNavigator.getInstance().pop,
            tooltip: backTooltip(context),
          ),
        ),
        floatingActionButton: _buildChooseFileFloatingActionButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: _buildInstructions(context),
      ),
    );
  }

  Widget _buildChooseFileFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: viewModel.onSelectFileTap,
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Text(
          S.of(context).chooseFile.toUpperCase(),
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Center(
      child: Padding(
        // Size of extended floating action button + 2 * padding
        padding: const EdgeInsets.fromLTRB(16, 16, 32, 48.0 + 16 + 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Markdown(
            padding: EdgeInsets.zero,
            data: viewModel.markdownBody,
            onTapLink: viewModel.onLinkTap,
            styleSheet: buildStyleSheet(context),
            imageBuilder: (uri, _, __) => buildMedia(url: uri.toString()),
          ),
        ),
      ),
    );
  }
}
