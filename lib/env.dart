import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'REVENUE_CAT_APPLE_API_KEY')
  static const String revenueCatAppleApiKey = _Env.revenueCatAppleApiKey;

  @EnviedField(varName: 'REVENUE_CAT_GOOGLE_API_KEY')
  static const String revenueCatGoogleApiKey = _Env.revenueCatGoogleApiKey;

  @EnviedField(varName: 'AZURE_SUBSCRIPTION_KEY')
  static const String azureSubscriptionKey = _Env.azureSubscriptionKey;

  @EnviedField(varName: 'UNSPLASH_ACCESS_TOKEN')
  static const String unsplashAccessToken = _Env.unsplashAccessToken;

  @EnviedField(varName: 'SENTRY_D_S_N')
  static const String sentryDSN = _Env.sentryDSN;

  @EnviedField(varName: 'AMPLITUDE_KEY_PROD')
  static const String amplitudeKeyProd = _Env.amplitudeKeyProd;

  @EnviedField(varName: 'AMPLITUDE_KEY_DEV')
  static const String amplitudeKeyDev = _Env.amplitudeKeyDev;
}
