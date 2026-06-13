/// Firestore collection and document path constants.
class FirestorePaths {
  FirestorePaths._();

  // Collections
  static const String users = 'users';
  static const String youthProfiles = 'youth_profiles';
  static const String jobs = 'jobs';
  static const String applications = 'applications';
  static const String ratings = 'ratings';

  // Sub-collections
  static String notifications(String uid) => 'notifications/$uid';

  // Documents
  static String user(String uid) => '$users/$uid';
  static String youthProfile(String uid) => '$youthProfiles/$uid';
  static String job(String jobId) => '$jobs/$jobId';
  static String application(String appId) => '$applications/$appId';
  static String rating(String ratingId) => '$ratings/$ratingId';
}

/// App-wide constants.
class AppConstants {
  AppConstants._();

  // Pagination
  static const int jobsPerPage = 15;
  static const int notificationsPerPage = 50;

  // Matching
  static const double defaultMatchRadiusKm = 10.0;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxSkills = 10;
  static const int maxCoverMessageLength = 500;
  static const int maxBioLength = 300;

  // Remote Config keys
  static const String matchRadiusKey = 'match_radius_km';

  // FCM
  static const String fcmChannelId = 'fursafy_jobs';
  static const String fcmChannelName = 'Fursafy Jobs';
  static const String fcmChannelDescription =
      'Notifications for job matches and application updates';

  // Job categories
  static const List<String> jobCategories = [
    'Tech',
    'Cleaning',
    'Construction',
    'Tutoring',
    'Delivery',
    'Cooking',
    'Repair',
    'Other',
  ];

  // Predefined skills
  static const List<String> predefinedSkills = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Cooking',
    'Driving',
    'Tutoring',
    'Web Development',
    'Mobile Development',
    'Graphic Design',
    'Photography',
    'Videography',
    'Writing',
    'Translation',
    'Data Entry',
    'Customer Service',
    'Sales',
    'Marketing',
    'Accounting',
    'Masonry',
    'Welding',
    'Tailoring',
    'Hairdressing',
    'Gardening',
    'Security',
    'Childcare',
    'Elderly Care',
  ];
}

/// User roles.
enum UserRole {
  youth,
  provider,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.youth:
        return 'Youth';
      case UserRole.provider:
        return 'Provider';
      case UserRole.admin:
        return 'Admin';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.youth,
    );
  }
}

/// Application status.
enum ApplicationStatus {
  pending,
  accepted,
  rejected,
  withdrawn;

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ApplicationStatus.pending,
    );
  }
}

/// Job status.
enum JobStatus {
  open,
  filled,
  closed;

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => JobStatus.open,
    );
  }
}

/// Pay type.
enum PayType {
  fixed,
  hourly,
  negotiable;

  static PayType fromString(String value) {
    return PayType.values.firstWhere(
      (s) => s.name == value,
      orElse: () => PayType.fixed,
    );
  }
}

/// Notification type.
enum NotificationType {
  jobMatch,
  applicationReceived,
  applicationAccepted,
  applicationRejected,
  ratingReceived;

  String get firestoreValue {
    switch (this) {
      case NotificationType.jobMatch:
        return 'job_match';
      case NotificationType.applicationReceived:
        return 'application_received';
      case NotificationType.applicationAccepted:
        return 'application_accepted';
      case NotificationType.applicationRejected:
        return 'application_rejected';
      case NotificationType.ratingReceived:
        return 'rating_received';
    }
  }

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (t) => t.firestoreValue == value,
      orElse: () => NotificationType.jobMatch,
    );
  }
}

/// Account status.
enum AccountStatus {
  active,
  suspended;

  static AccountStatus fromString(String value) {
    return AccountStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => AccountStatus.active,
    );
  }
}
