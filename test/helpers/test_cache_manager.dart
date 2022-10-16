import 'dart:async';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager/src/cache_store.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart'
    as fs;
import 'package:tubecards/data/models/unsplash_image.dart';
import 'package:tubecards/utils/assets.dart';

// A dummy test file system to access test fixture files.
class _TestFileSystem extends fs.FileSystem {
  final directoryFuture =
      MemoryFileSystem().systemTempDirectory.createTemp('test-file-system');

  @override
  Future<File> createFile(String name) async {
    final dir = await directoryFuture;
    await dir.create(recursive: true);

    return dir.childFile(name);
  }
}

// Designed to be a drop in for getIt<BaseCacheManager>() calls.
//
// In non-test code, the CustomCacheManager is used but for tests we need to
// have a mocked instance so that CachedNetworkImages are working as expected.
class TestCacheManager extends CacheManager implements BaseCacheManager {
  TestCacheManager()
      : super.custom(
          _testConfig,
          cacheStore: CacheStore(_testConfig),
        );

  static final Config _testConfig = Config(
    'test-cache',
    repo: NonStoringObjectProvider(),
    fileSystem: _TestFileSystem(),
  );

  // Override the method so that the regular default cover image can be accessed
  // in tests.
  @override
  Future<FileInfo?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  }) async {
    if (key == defaultCoverImage.regularUrl) {
      return Future.value(FileInfo(
        const LocalFileSystem().file(Assets.images.defaultCoverImage),
        FileSource.Cache,
        DateTime(2050),
        key,
      ));
    }

    return Future.value();
  }
}
