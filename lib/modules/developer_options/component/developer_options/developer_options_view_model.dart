import 'package:flutter/foundation.dart';

class DeveloperOptionsViewModel {
  DeveloperOptionsViewModel({
    required this.clearDatabase,
    required this.clearCacheDirectory,
    required this.exportCacheManagerDatabase,
    required this.printAllImages,
  });

  final VoidCallback clearDatabase;

  final VoidCallback clearCacheDirectory;
  final VoidCallback exportCacheManagerDatabase;
  final VoidCallback printAllImages;
}
