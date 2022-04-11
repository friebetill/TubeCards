/// True when the client is running in production.
const bool isProduction = String.fromEnvironment('app.flavor') != 'dev';

/// The URL to the Space API server.
const String spaceGraphQlUrl = isProduction
    ? 'https://api.getspace.app'
    :
    // Use this to develop on the stage server.
    // 'https://stage.getspace.app/';
// Use this to develop locally for a mobile platform.
// 'http://192.168.0.1:3000/graphql';
// Use this to develop locally for a desktop platform.
    'http://localhost:3000/graphql';

/// The support email of Space.
const String supportEmail = 'space.flashcards.app@gmail.com';

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

const String privacyPolicyURL = 'https://getspace.app/privacy-policy';

/// The Microsoft store id of Space
///
/// Can be found at the end of Space Windows store url:
/// https://www.microsoft.com/en-us/p/space-spaced-repetition/9n2zrwbkjkt9
const String microsoftStoreId = '9n2zrwbkjkt9';

/// The App Store id of Space
///
/// Can be found in the iTunes store URL as the string of numbers directly
/// after id: https://apps.apple.com/us/app/space-spaced-repetition/id1546202212
const String appStoreId = '1546202212';

const String voteNextFeaturesURL = 'https://forms.gle/DsFYWYUKZVDwdc2E9';

/// ID of the PayPal donation button.
const String payPalButtonId = '4JN8FL9G57NKU';

/// API key to send events to Amplitude.
const String amplitudeKey = isProduction ? '' : '';
