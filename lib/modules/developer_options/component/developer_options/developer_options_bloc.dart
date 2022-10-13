// ignore_for_file: avoid_print
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../graphql/graph_ql_runner.dart';
import '../../../../utils/card_media_handler.dart';
import '../../../../utils/custom_cache_manager.dart';
import 'developer_options_component.dart';
import 'developer_options_view_model.dart';

/// BLoC for the [DeveloperOptionsComponent].
///
/// Exposes a [DeveloperOptionsViewModel] for that component to use.
@injectable
class DeveloperOptionsBloc {
  DeveloperOptionsBloc(this._graphQLRunner);

  final GraphQLRunner _graphQLRunner;

  Stream<DeveloperOptionsViewModel>? _viewModel;
  Stream<DeveloperOptionsViewModel>? get viewModel => _viewModel;

  Stream<DeveloperOptionsViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Stream.value(DeveloperOptionsViewModel(
      clearDatabase: () async => _graphQLRunner.clear(),
      clearCacheDirectory: _clearCacheDirectory,
      exportCacheManagerDatabase: _exportCacheManagerDatabase,
      printAllImages: _printAllImages,
    ));
  }

  /// Exports the cache manager SQL database.
  Future<void> _exportCacheManagerDatabase() async {
    final appDir = await getApplicationSupportDirectory();
    await Share.shareXFiles(
      [XFile(join(appDir.path, '${CustomCacheManager.key}.db'))],
      subject: 'CacheManager database',
      text: '${CustomCacheManager.key}.db',
    );
  }

  /// Deletes all files in the cache directory.
  void _clearCacheDirectory() {
    const cacheDirectory = '/data/user/0/com.space.space.dev/cache/';
    for (final file in Directory(cacheDirectory).listSync()) {
      if (file is File) {
        file.deleteSync();
      }
    }
  }

  /// Prints all images of the app.
  Future<void> _printAllImages() async {
    _printAllImagesIn(await getTemporaryDirectory());
    _printAllImagesIn(await getApplicationDocumentsDirectory());
  }

  /// Prints all image paths in the given [directory].
  ///
  /// Recurses into subdirectories and prints images in there as well.
  void _printAllImagesIn(Directory directory) {
    for (final fileSystemEntity in directory.listSync()) {
      if (fileSystemEntity is Directory) {
        _printAllImagesIn(fileSystemEntity);
      } else if (fileSystemEntity is File) {
        final fileExtension = extension(fileSystemEntity.path);
        // Cached images are saved with the extension .file
        if (CardMediaHandler.supportedImageFormats.contains(fileExtension) ||
            fileExtension == '.file') {
          print('File: ${fileSystemEntity.path}');
        }
      } else {
        print('Not known: ${fileSystemEntity.path}');
      }
    }
  }
}
