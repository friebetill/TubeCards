import '../../../graphql/operation_exception.dart';
import '../../../i18n/i18n.dart';

/// Returns the most fitting error text for the given [exception].
///
/// In case no good message can be found, a generic error message is returned.
String getErrorText(S i18n, Exception exception) {
  if (exception is OperationException) {
    if (exception.isNoInternet) {
      return i18n.errorNoInternetText;
    } else if (exception.isServerOffline) {
      return i18n.errorWeWillFixText;
    }
  }

  return i18n.errorUnknownText;
}
