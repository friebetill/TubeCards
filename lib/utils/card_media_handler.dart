import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' show extension;

import '../graphql/graph_ql_runner.dart';
import '../graphql/mutations/__generated__/get_presigned_s3_post_data.req.gql.dart';
import '../graphql/operation_exception.dart';
import '../services/aws_client.dart';
import 'progress.dart';

/// The class that loads the media from cards (i.e. images) into the cloud and
/// adjusts the references.
@singleton
class CardMediaHandler {
  /// Returns a CardContentHandler that handles the media of the card.
  CardMediaHandler(this._graphQLRunner, this._cacheManager);

  /// The supported image formats.
  static const supportedImageFormats = ['jpg', 'jpeg', 'png', 'svg', 'gif'];

  /// Maximum file size in bytes that is uploaded to S3
  ///
  /// Files larger than 10MB stay local.
  static const maxFileSize = 10000000;

  final GraphQLRunner _graphQLRunner;
  final BaseCacheManager _cacheManager;
  final AWSClient _awsClient = const AWSClient();

  /// Returns all image urls of [text].
  List<String?> getImagesURLs(String text) {
    final markdownImageRegExp = RegExp(r'!\[.*?\]\((.*?)\)');
    final matches = markdownImageRegExp.allMatches(text);

    return matches.map((m) => m.group(1)).toList();
  }

  /// Removes all urls from [imageURLs] linking to TubeCards S3 images.
  void removeS3URLs(Set<String> imageURLs) =>
      imageURLs.removeWhere((u) => u.contains(getS3ImageBucketUrl()));

  /// Removes all urls from [imageURLs] linking to files with unsupported
  /// extensions.
  ///
  /// The supported extensions are defined in [supportedImageFormats].
  void removeURLsToUnsupportedFiles(Set<String> imageURLs) {
    imageURLs.removeWhere((imageURL) {
      final imageExtension =
          extension(imageURL).toLowerCase().replaceAll('.', '');

      return !supportedImageFormats.contains(imageExtension);
    });
  }

  /// Removes all urls linking to files that are larger than [maxFileSize].
  ///
  /// Logs when a file is removed.
  Future<void> removeURLsToTooLargeFiles(Set<String> imageURLs) async {
    final urlsToRemove = <String>[];
    for (final imageURL in imageURLs) {
      final cachedImageInfo = await _cacheManager.getFileFromCache(imageURL);
      if (cachedImageInfo == null) {
        urlsToRemove.add(imageURL);
      } else if (cachedImageInfo.file.lengthSync() > maxFileSize) {
        urlsToRemove.add(imageURL);
      }
    }
    urlsToRemove.forEach(imageURLs.remove);
  }

  /// Uploads the file from the given URL to the TubeCards Backend.
  ///
  /// Returns the url to the uploaded file and null when the upload failed.
  ///
  /// The [onProgress] method returns the progress of the image upload.
  /// Images that have already been uploaded will not be uploaded again.
  ///
  /// Throws a [SocketException] when there is no internet connection,
  /// a [OperationException] if getting the AWS S3 presigned post data failed
  /// and a [HttpException] if the request was unsuccessful.
  Future<String> uploadImage(
    String imageURL, {
    Function(Progress)? onProgress,
  }) async {
    final image = await _cacheManager.getSingleFile(imageURL);

    final hash = md5.convert(image.readAsBytesSync());
    final uniqueFileName = '$hash${extension(imageURL)}';
    final s3URL = '${getS3ImageBucketUrl()}/$uniqueFileName';

    await _awsClient.uploadImage(
      image,
      uniqueFileName,
      await _getPreSignedS3PostData(uniqueFileName),
      onProgress: (progress) => onProgress?.call(Progress(progress.value)),
    );

    await _cacheManager.putFile(
      s3URL,
      image.readAsBytesSync(),
      eTag: hash.toString(),
    );
    await _cacheManager.removeFile(imageURL);

    return s3URL;
  }

  /// Returns the [PreSignedS3PostData] for a post to the S3 bucket with the
  /// given [fileName].
  Future<PreSignedS3PostData> _getPreSignedS3PostData(String fileName) async {
    return _graphQLRunner
        .request(GGetPreSignedS3PostDataReq((b) => b..vars.fileName = fileName))
        .map((r) {
      if (r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      return PreSignedS3PostData.fromJson(json.decode(
        r.data!.getPreSignedS3PostData,
      ) as Map<String, dynamic>);
    }).first;
  }
}
