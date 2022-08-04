import '../env.dart';

/// True when the client is running in production.
const bool isProduction = String.fromEnvironment('app.flavor') != 'dev';

/// The URL to the Space API server.
const String spaceGraphQlUrl = isProduction
    ? 'https://api.getspace.app'
    :
    // Use this to develop on the stage server.
    'https://stage.getspace.app/';
// Use this to develop locally for a mobile platform.
// 'http://192.168.0.1:3000/graphql';
// Use this to develop locally for a desktop platform.
// 'http://localhost:3000/graphql';

/// The support email of Space.
const supportEmail = 'space.flashcards.app@gmail.com';

/// Access token to send API requests to the Azure Cognitive Service.
const azureSubscriptionKey = Env.azureSubscriptionKey;

/// Base url used to access the Azure Cognitive Service API.
const azureBaseURL = 'getspace.cognitiveservices.azure.com';

/// Access token to send API requests to Unsplash.
const unplashAccessToken = Env.unsplashAccessToken;

/// API keys to manage in-app purchases with RevenueCat.
const revenueCatGoogleApiKey = Env.revenueCatGoogleApiKey;
const revenueCatAppleApiKey = Env.revenueCatAppleApiKey;

/// Data source name for Sentry.
const sentryDSN = Env.sentryDSN;

final privacyPolicyURL = Uri.https('getspace.app', '/privacy-policy');

/// The Microsoft store id of Space
///
/// Can be found at the end of Space Windows store url:
/// https://www.microsoft.com/en-us/p/space-spaced-repetition/9n2zrwbkjkt9
const microsoftStoreId = '9n2zrwbkjkt9';

/// The App Store id of Space
///
/// Can be found in the iTunes store URL as the string of numbers directly
/// after id: https://apps.apple.com/us/app/space-spaced-repetition/id1546202212
const appStoreId = '1546202212';

final voteNextFeaturesURL = Uri.https('forms.gle', '/DsFYWYUKZVDwdc2E9');

/// ID of the PayPal donation button.
const String payPalButtonId = '4JN8FL9G57NKU';

/// API key to send events to Amplitude.
const amplitudeKey = isProduction ? Env.amplitudeKeyProd : Env.amplitudeKeyDev;
