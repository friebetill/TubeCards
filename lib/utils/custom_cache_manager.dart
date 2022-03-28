import 'dart:typed_data';

import 'package:file/file.dart' hide FileSystem;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// The IOFileSystem is currently not public, http://bit.ly/3s2S43a
// ignore: implementation_imports
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// The cache manager where the files are stored.
///
/// The files are stored in a folder that is only cleared when the app is
/// deleted.
///
/// If the images are not used for [_staleDuration], they will be deleted.
class CustomCacheManager extends CacheManager {
  /// Returns an singleton instance of [CacheManager].
  factory CustomCacheManager() => _instance ??= CustomCacheManager._();

  CustomCacheManager._() : super(_config);

  static CustomCacheManager? _instance;

  static final _config = Config(
    key,
    stalePeriod: _staleDuration,
    // Necessary so that the images are not stored in the temporary folder but
    // in the application folder.
    fileSystem: _IOFileSystem(key),
  );

  /// The duration after which a file is stale and then automatically deleted.
  static const _staleDuration = Duration(days: 30);

  /// The name of the sqlite database without the fileextension '.db'.
  static const key = 'libCachedImageData';

  /// The duration until the stored files expire in the CacheManager.
  static const storageExpirationDuration = Duration(days: 365000);

  /// Puts a file without expiration in the cache.
  ///
  /// The [fileExtension] should be without a dot, for example "jpg".
  ///
  /// [maxAge] is always overwritten by [storageExpirationDuration].
  @override
  Future<File> putFile(
    String url,
    Uint8List fileBytes, {
    String? key,
    String? eTag,
    Duration maxAge = const Duration(days: 30),
    String fileExtension = 'file',
  }) {
    return super.putFile(
      url,
      fileBytes,
      key: key,
      eTag: eTag,
      fileExtension: fileExtension,
      maxAge: storageExpirationDuration,
    );
  }
}

/// The file system to store files.
///
/// The difference to the default file system is that the files are stored in
/// the application directory instead of the temporary directory.
class _IOFileSystem implements FileSystem {
  _IOFileSystem(String key) : _fileDir = createDirectory(key);

  final Future<Directory> _fileDir;

  static Future<Directory> createDirectory(String key) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final path = join(baseDir.path, key);

    const fileSystem = LocalFileSystem();
    final directory = fileSystem.directory(path);
    await directory.create(recursive: true);

    return directory;
  }

  @override
  Future<File> createFile(String name) async {
    return (await _fileDir).childFile(name);
  }
}
