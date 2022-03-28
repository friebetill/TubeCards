import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/import/analyze_file/analyze_file_component.dart';
import '../../../../widgets/import/import_state.dart';
import '../../../../widgets/import/instructions/instructions_component.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../import_overview/import_overview_component.dart';
import '../import_progress/import_progress_component.dart';
import 'import_anki_bloc.dart';
import 'import_anki_view_model.dart';

class ImportAnkiComponent extends StatelessWidget {
  const ImportAnkiComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<ImportAnkiBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<ImportAnkiViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            final isMobile = Platform.isAndroid || Platform.isIOS;

            switch (snapshot.data?.importState) {
              case ImportState.showInstructions:
                return InstructionsComponent(
                  appBarTitle: S.of(context).importFromAnki,
                  markdownBody: S.of(context).importSharedAnkiDeckText +
                      (isMobile
                          ? S.of(context).importYourAnkiDeckMobileText
                          : S.of(context).importYourAnkiDeckDesktopText),
                  onSelectFile: snapshot.data!.onSelectFile,
                );
              case ImportState.analyzeFile:
                return AnalyzeFileComponent(
                  appBarTitle: S.of(context).importFromAnki,
                  analyzeFile: snapshot.data!.analyzeFile,
                  filePath: snapshot.data!.filePath!,
                  onOpenEmailAppTap: snapshot.data!.onOpenEmailAppTap,
                );
              case ImportState.showDataOverview:
                return ImportOverviewComponent(
                  snapshot.data!.ankiPackage!,
                  snapshot.data!.importOverviewCallback,
                );
              case ImportState.showProgress:
                return ImportProgressComponent(
                  package: snapshot.data!.ankiPackage!,
                  onOpenEmailAppTap: snapshot.data!.onOpenEmailAppTap,
                );
              default:
                return SimpleSkeleton(
                  appBarTitle: S.of(context).importFromAnki,
                );
            }
          },
        );
      },
    );
  }
}
