/// Fursafy — Environment Configuration
///
/// All API keys and sensitive configuration values are read from
/// compile-time environment variables using `String.fromEnvironment()`.
///
/// **Usage (local development):**
/// ```bash
/// flutter run \
///   --dart-define=FIREBASE_API_KEY=your_key \
///   --dart-define=FIREBASE_PROJECT_ID=your_project_id \
///   --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
///   --dart-define=FIREBASE_APP_ID=your_app_id \
///   --dart-define=FIREBASE_STORAGE_BUCKET=your_storage_bucket \
///   --dart-define=GOOGLE_MAPS_API_KEY=your_maps_key \
///   --dart-define=AFRICAS_TALKING_API_KEY=your_at_key
/// ```
///
/// **Usage (CI/CD — GitHub Actions):**
/// Keys are passed from GitHub Secrets via `--dart-define` in the workflow.
///
/// See `.env.example` for the full list of required variables.
class EnvConfig {
  EnvConfig._();

  // ======================== FIREBASE ========================

  /// Firebase Web API key for authentication and service access.
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
  );

  /// Firebase project identifier (e.g., "fursafy-12345").
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );

  /// Firebase Cloud Messaging sender ID for push notifications.
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );

  /// Firebase application ID for this specific app registration.
  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
  );

  /// Firebase Storage bucket URL (e.g., "fursafy.firebasestorage.app").
  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );

  // ======================== GOOGLE MAPS ========================

  /// Google Maps Platform API key for map rendering and geocoding.
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );

  // ======================== AFRICA'S TALKING ========================

  /// Africa's Talking API key for SMS/OTP verification services.
  static const String africasTalkingApiKey = String.fromEnvironment(
    'AFRICAS_TALKING_API_KEY',
  );

  // ======================== VALIDATION ========================

  /// Returns `true` if all required environment variables are set.
  static bool get isConfigured =>
      firebaseApiKey.isNotEmpty &&
      firebaseProjectId.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseStorageBucket.isNotEmpty &&
      googleMapsApiKey.isNotEmpty;

  /// Returns a list of environment variable names that are missing.
  static List<String> get missingVariables {
    final missing = <String>[];
    if (firebaseApiKey.isEmpty) missing.add('FIREBASE_API_KEY');
    if (firebaseProjectId.isEmpty) missing.add('FIREBASE_PROJECT_ID');
    if (firebaseMessagingSenderId.isEmpty) {
      missing.add('FIREBASE_MESSAGING_SENDER_ID');
    }
    if (firebaseAppId.isEmpty) missing.add('FIREBASE_APP_ID');
    if (firebaseStorageBucket.isEmpty) missing.add('FIREBASE_STORAGE_BUCKET');
    if (googleMapsApiKey.isEmpty) missing.add('GOOGLE_MAPS_API_KEY');
    // Africa's Talking is optional for local development
    return missing;
  }

  /// Throws an [AssertionError] if any required variable is missing.
  /// Call this early in `main()` during development.
  static void validate() {
    final missing = missingVariables;
    assert(
      missing.isEmpty,
      'Missing environment variables: ${missing.join(', ')}.\n'
      'Pass them with --dart-define or check .env.example for the full list.',
    );
  }
}
