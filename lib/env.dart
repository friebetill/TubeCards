import 'package:envify/envify.dart';

part 'env.g.dart';

@Envify()
abstract class Env {
  static const revenueCatApiKey = _Env.revenueCatApiKey;
  static const azureSubscriptionKey = _Env.azureSubscriptionKey;
  static const unsplashAccessToken = _Env.unsplashAccessToken;
  static const sentryDSN = _Env.sentryDSN;
  static const amplitudeKeyProd = _Env.amplitudeKeyProd;
  static const amplitudeKeyDev = _Env.amplitudeKeyDev;
}
