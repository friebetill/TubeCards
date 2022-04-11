import 'package:envify/envify.dart';

part 'env.g.dart';

@Envify()
abstract class Env {
  static const String revenueCatAppleApiKey = _Env.revenueCatAppleApiKey;
  static const String revenueCatGoogleApiKey = _Env.revenueCatGoogleApiKey;
  static const String azureSubscriptionKey = _Env.azureSubscriptionKey;
  static const String unsplashAccessToken = _Env.unsplashAccessToken;
  static const String sentryDSN = _Env.sentryDSN;
  static const String amplitudeKeyProd = _Env.amplitudeKeyProd;
  static const String amplitudeKeyDev = _Env.amplitudeKeyDev;
}
