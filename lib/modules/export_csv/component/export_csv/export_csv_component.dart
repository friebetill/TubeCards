import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/markdown.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../../../widgets/stadium_text_field.dart';
import '../../../../widgets/visual_element.dart';
import 'export_csv_bloc.dart';
import 'export_csv_view_model.dart';

class ExportCSVComponent extends StatelessWidget {
  const ExportCSVComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<ExportCSVBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<ExportCSVViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return SimpleSkeleton(appBarTitle: S.of(context).exportToCSV);
            }

            return _ExportCSVComponent(snapshot.data!);
          },
        );
      },
    );
  }
}

class _ExportCSVComponent extends StatefulWidget {
  const _ExportCSVComponent(this.viewModel);

  final ExportCSVViewModel viewModel;

  @override
  State<_ExportCSVComponent> createState() => _ExportCSVComponentState();
}

class _ExportCSVComponentState extends State<_ExportCSVComponent> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(elevation: 0, title: Text(S.of(context).exportToCSV)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 32, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView(
                children: [
                  MarkdownBody(
                    data: S.of(context).exportCSVText,
                    imageBuilder: (uri, _, __) => buildMedia(
                      url: uri.toString(),
                      onImageTap: () {
                        widget.viewModel.onImageTap(uri.toString());
                      },
                    ),
                    onTapLink: widget.viewModel.onLinkTap,
                    styleSheet: buildStyleSheet(context),
                  ),
                  if (widget.viewModel.showEmailField) ..._buildEmailField(),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _buildExportButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  List<Widget> _buildEmailField() {
    return [
      const SizedBox(height: 32),
      Text(S.of(context).exportDeckEmailText),
      const SizedBox(height: 24),
      StadiumTextField(
        autofillHints: const [AutofillHints.email],
        controller: _textEditingController,
        placeholder: S.of(context).email,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => widget.viewModel.onExportTap(),
        errorText: widget.viewModel.emailErrorText,
        onChanged: widget.viewModel.onEmailChanged,
      ),
    ];
  }

  Widget _buildExportButton() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: VisualElement(
        id: VEs.exportButton,
        childBuilder: (controller) {
          return FloatingActionButton.extended(
            onPressed: () {
              controller.logTap();
              widget.viewModel.onExportTap();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            label: !widget.viewModel.isLoading
                ? Text(S.of(context).export.toUpperCase())
                : IconSizedLoadingIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
          );
        },
      ),
    );
  }
}
