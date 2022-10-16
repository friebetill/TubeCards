import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../utils/config.dart';
import '../utils/progress.dart';

/// The domain of the data center of Amazon where TubeCards S3 buckets are
/// located.
const s3EuWestDomain = 's3-eu-west-1.amazonaws.com';

/// The name of the TubeCards production image bucket.
const s3ImageBucketName = 'image.getspace.app';

/// The name of the TubeCards stage image bucket.
const s3StageImageBucketName = 'stage.image.getspace.app';

/// Returns the URL of the image bucket.
String getS3ImageBucketUrl() {
  return isProduction
      ? 'https://$s3EuWestDomain/$s3ImageBucketName'
      : 'https://$s3EuWestDomain/$s3StageImageBucketName';
}

/// Client to use Amazon Web Services.
class AWSClient {
  const AWSClient();

  /// Uploads the given [file] with the given [fileName] in the S3 bucket.
  ///
  /// The given pre-signed post data must be specially generated for the file
  /// name by the TubeCards API. Normally not used directly but via a
  /// repository.
  ///
  /// Throws a [SocketException] when there is no internet connection and a
  /// [HttpException] if the request was unsuccessful.
  Future<void> uploadImage(
    File file,
    String fileName,
    PreSignedS3PostData preSignedS3PostData, {
    Function(Progress)? onProgress,
  }) async {
    /// Helper method to propagate the progress from the image upload to the
    /// caller.
    void handleSendProgress(int received, int total) {
      if (total == -1) {
        onProgress?.call(const Progress(0));
      }
      onProgress?.call(Progress(received / total));
    }

    final data = FormData.fromMap({
      'key': fileName,
      'acl': 'public-read',
      'bucket': preSignedS3PostData.bucket,
      'x-amz-credential': preSignedS3PostData.xAmzCredential,
      'policy': preSignedS3PostData.policy,
      'x-amz-signature': preSignedS3PostData.xAmzSignature,
      'x-amz-algorithm': preSignedS3PostData.xAmzAlgorithm,
      'x-amz-date': preSignedS3PostData.xAmzDate,
      'file': MultipartFile.fromFileSync(file.path, filename: fileName),
    });

    try {
      final response = await Dio().post(
        preSignedS3PostData.url,
        options: Options(method: 'POST'),
        data: data,
        onSendProgress: handleSendProgress,
      );

      // Expecting response 204 (NO_CONTENT) in case of success.
      if (response.statusCode != HttpStatus.noContent) {
        throw HttpException('Response has unexpected status code: $response');
      }
    } on DioError catch (e) {
      throw HttpException('Image was not uploaded: ${e.message}');
    }
  }
}

/// The class that stores all information to send an authenticated post to the
/// TubeCards S3 bucket.
class PreSignedS3PostData {
  /// Returns from the given [json] string a [PreSignedS3PostData].
  PreSignedS3PostData.fromJson(Map<String, dynamic> json)
      : url = json['url'].toString(),
        bucket = json['fields']['bucket'].toString(),
        xAmzAlgorithm = json['fields']['X-Amz-Algorithm'].toString(),
        xAmzCredential = json['fields']['X-Amz-Credential'].toString(),
        xAmzDate = json['fields']['X-Amz-Date'].toString(),
        policy = json['fields']['Policy'].toString(),
        xAmzSignature = json['fields']['X-Amz-Signature'].toString();

  /// The URL to the S3 server at which the post can be sent.
  final String url;

  /// The bucket in which the image can be uploaded.
  final String bucket;

  /// Base64-encoded version of the POST policy.
  final String policy;

  /// The signing algorithm that must be used during signature calculation.
  final String xAmzAlgorithm;

  /// The credentials that is used to calculate the signature.
  final String xAmzCredential;

  /// The date used in creating the signing key for signature calculation.
  final String xAmzDate;

  /// The signature used to verify that the correct key was used.
  final String xAmzSignature;
}
