import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../../utils/custom_navigator.dart';
import '../../../utils/tooltip_message.dart';
import '../../page_callback_shortcuts.dart';
import 'analyze_file_bloc.dart';
import 'analyze_file_view_model.dart';

class AnalyzeFileComponent extends StatelessWidget {
  const AnalyzeFileComponent({
    required this.appBarTitle,
    required this.filePath,
    required this.analyzeFile,
    required this.onOpenEmailAppTap,
    Key? key,
  }) : super(key: key);

  final String appBarTitle;
  final String filePath;
  final AnalyzeFileErrorCallback analyzeFile;
  final AsyncCallback onOpenEmailAppTap;

  @override
  Widget build(BuildContext context) {
    return Component<AnalyzeFileBloc>(
      createViewModel: (bloc) => bloc.createViewModel(analyzeFile),
      builder: (context, bloc) {
        return StreamBuilder<AnalyzeFileViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SimpleSkeleton(appBarTitle: appBarTitle);
            }

            return _AnalyzeFileView(
              viewModel: snapshot.data!,
              appBarTitle: appBarTitle,
            );
          },
        );
      },
    );
  }
}

@immutable
class _AnalyzeFileView extends StatelessWidget {
  const _AnalyzeFileView({
    required this.viewModel,
    required this.appBarTitle,
    Key? key,
  }) : super(key: key);

  final AnalyzeFileViewModel viewModel;
  final String appBarTitle;

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_outlined),
            onPressed: CustomNavigator.getInstance().pop,
            tooltip: closeTooltip(context),
          ),
        ),
        body: Column(
          children: [
            const Spacer(flex: 6),
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: Stack(
                  children: [
                    _buildInnerWidget(context),
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        value: viewModel.errorText == null ? null : 100,
                        color: viewModel.errorText == null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                        strokeWidth: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (viewModel.errorText == null) const Spacer(flex: 2),
            if (viewModel.errorText != null)
              Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        viewModel.errorText!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            const Spacer(flex: 3),
            // Size of extended floating action button + padding
            const SizedBox(height: 48.0 + 16),
          ],
        ),
        floatingActionButton: viewModel.errorText == null
            ? _buildAbortFAB(context)
            : viewModel.onOpenEmailAppTap != null
                ? _buildOpenEmailFAB(context)
                : _buildCloseFAB(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildAbortFAB(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text(S.of(context).abortAnalysis.toUpperCase()),
      onPressed: CustomNavigator.getInstance().pop,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  Widget _buildOpenEmailFAB(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text(S.of(context).openEmailApp.toUpperCase()),
      foregroundColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      onPressed: viewModel.onOpenEmailAppTap,
    );
  }

  Widget _buildCloseFAB(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text(S.of(context).close.toUpperCase()),
      foregroundColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Colors.white,
      onPressed: CustomNavigator.getInstance().pop,
    );
  }

  Widget _buildInnerWidget(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).analyzing,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorText == null
                  ? S.of(context).thisTakesAFewSeconds
                  : S.of(context).anErrorOccured,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      ),
    );
  }
}
