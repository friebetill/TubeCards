/// Returns full URI path for the given [fileName].
///
/// The path can be used to store the associated image in the image cache
/// which needs a valid URI path including a hostname.
String buildUriPath(String fileName) => 'http://localhost/$fileName';
