import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/assets.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../../../preferences/component/preference_title.dart';
import 'import_bloc.dart';
import 'import_view_model.dart';

class ImportExportComponent extends StatelessWidget {
  const ImportExportComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<ImportExportBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<ImportExportViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _ImportExportView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _ImportExportView extends StatelessWidget {
  const _ImportExportView({
    required this.viewModel,
    Key? key,
  }) : super(key: key);

  final ImportExportViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        PreferenceTitle(S.of(context).import),
        _buildImportCSVTile(context),
        _buildImportExcelTile(context),
        _buildImportGoogleSheetsTile(context),
        _buildImportAnkiTile(context),
        PreferenceTitle(S.of(context).export),
        _buildExportCSVTile(context),
      ],
    );
  }

  Widget _buildImportCSVTile(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        leading: SizedBox(
          height: 32,
          width: 32,
          child: SvgPicture.asset(Assets.images.csvLogo),
        ),
        title: const Text('CSV'),
        onTap: viewModel.onImportCSVTap,
      ),
    );
  }

  Widget _buildImportGoogleSheetsTile(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        leading: SizedBox(
          height: 32,
          width: 32,
          child: SvgPicture.asset(Assets.images.googleSheetsLogo),
        ),
        title: const Text('Google Sheets'),
        onTap: viewModel.onImportGoogleSheetsTap,
      ),
    );
  }

  Widget _buildImportExcelTile(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        leading: SizedBox(
          height: 32,
          width: 32,
          child: SvgPicture.asset(Assets.images.microsoftExcelLogo),
        ),
        title: const Text('Excel'),
        onTap: viewModel.onImportExcelTap,
      ),
    );
  }

  Widget _buildImportAnkiTile(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        leading: SizedBox(
          height: 32,
          width: 32,
          child: SvgPicture.asset(Assets.images.ankiLogo),
        ),
        title: const Text('Anki'),
        onTap: viewModel.onImportAnkiTap,
      ),
    );
  }

  Widget _buildExportCSVTile(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        leading: SizedBox(
          height: 32,
          width: 32,
          child: SvgPicture.asset(Assets.images.csvLogo),
        ),
        title: const Text('CSV'),
        onTap: viewModel.onExportCSVTap,
      ),
    );
  }
}
