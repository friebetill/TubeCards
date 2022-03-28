/// True when the client is running in production.
const bool isProduction = String.fromEnvironment('app.flavor') != 'dev';

/// The URL to the Space API server.
const String spaceGraphQlUrl = isProduction
    ? ''
    :
    // Use this to develop on the stage server.
    '';
// Use this to develop locally for a mobile platform.
// 'http://192.168.0.1:3000/graphql';
// Use this to develop locally for a desktop platform.
// 'http://localhost:3000/graphql';

/// The support email of Space.
const String supportEmail = '';

/// Username of Amazon Simple Email Service.
const String sesUsername = '';

/// Password of Amazon Simple Email Service.
const String sesPassword = '';

/// Access token to send API requests to the Azure Cognitive Service.
const String azureSubscriptionKey = '';

/// Base url used to access the Azure Cognitive Service API.
const String azureBaseURL = '';

/// Access token to send API requests to Unsplash.
const String unplashAccessToken = '';

/// API key to manage in-app purchases with RevenueCat.
const String revenueCatApiKey = '';

/// Data source name for Sentry.
const String sentryDSN = '';

const String privacyPolicyURL = '';

/// The Microsoft store id of Space
///
/// Can be found at the end of Space Windows store url:
/// https://www.microsoft.com/en-us/p/space-spaced-repetition/9n2zrwbkjkt9
const String microsoftStoreId = '';

/// The App Store id of Space
///
/// Can be found in the iTunes store URL as the string of numbers directly
/// after id: https://apps.apple.com/us/app/space-spaced-repetition/id1546202212
const String appStoreId = '';

const String voteNextFeaturesURL = '';

/// ID of the PayPal donation button.
const String payPalButtonId = '';

/// API key to send events to Amplitude.
const String amplitudeKey = isProduction ? '' : '';
