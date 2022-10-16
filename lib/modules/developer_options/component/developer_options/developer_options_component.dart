import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../../main.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import 'developer_options_bloc.dart';
import 'developer_options_view_model.dart';

class DeveloperOptionsComponent extends StatelessWidget {
  const DeveloperOptionsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<DeveloperOptionsBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<DeveloperOptionsViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _DeveloperOptionsView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _DeveloperOptionsView extends StatelessWidget {
  const _DeveloperOptionsView({required this.viewModel, Key? key})
      : super(key: key);

  final DeveloperOptionsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Options'),
        elevation: 0,
        leading: const BackButton(key: ValueKey('back-button')),
      ),
      body: ListView(
        children: [
          ..._buildDatabaseOptions(context),
          ..._buildCacheOptions(context),
        ],
      ),
    );
  }

  List<Widget> _buildDatabaseOptions(BuildContext context) {
    return [
      Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Text(
          'Database',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ListTileAdapter(
        child: ListTile(
          title: const Text('Clear TubeCards database'),
          onTap: viewModel.clearDatabase,
        ),
      ),
    ];
  }

  List<Widget> _buildCacheOptions(BuildContext context) {
    return [
      Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Text(
          'Cache',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ListTileAdapter(
        child: ListTile(
          title: const Text('Export CacheManager database'),
          onTap: viewModel.exportCacheManagerDatabase,
        ),
      ),
      ListTileAdapter(
        child: ListTile(
          title: const Text('Empty image cache'),
          subtitle: const Text('Removes all images from the CacheManager.'),
          onTap: () => getIt<BaseCacheManager>().emptyCache(),
        ),
      ),
      ListTileAdapter(
        child: ListTile(
          title: const Text('Empty image cache'),
          subtitle: const Text('Removes all images from the cache folder.'),
          onTap: viewModel.clearCacheDirectory,
        ),
      ),
      ListTileAdapter(
        child: ListTile(
          title: const Text('List all images this app currently saves'),
          subtitle: const Text('The images are printed in the console.'),
          onTap: viewModel.printAllImages,
        ),
      ),
    ];
  }
}
