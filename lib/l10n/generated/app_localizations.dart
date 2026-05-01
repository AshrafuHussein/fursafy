import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Fursafy'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Fursa kwa Vijana — Opportunities for Youth'**
  String get appTagline;

  /// No description provided for @welcomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}!'**
  String welcomeGreeting(String name);

  /// No description provided for @discoverOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Discover Opportunities Near You'**
  String get discoverOpportunities;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Your Role'**
  String get selectRole;

  /// No description provided for @iAmYouth.
  ///
  /// In en, this message translates to:
  /// **'I\'m looking for work'**
  String get iAmYouth;

  /// No description provided for @iAmProvider.
  ///
  /// In en, this message translates to:
  /// **'I\'m hiring workers'**
  String get iAmProvider;

  /// No description provided for @youthRole.
  ///
  /// In en, this message translates to:
  /// **'Youth / Worker'**
  String get youthRole;

  /// No description provided for @providerRole.
  ///
  /// In en, this message translates to:
  /// **'Job Provider'**
  String get providerRole;

  /// No description provided for @enterDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Details'**
  String get enterDetails;

  /// No description provided for @verifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Phone'**
  String get verifyPhone;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to your phone'**
  String get enterOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @selectSkills.
  ///
  /// In en, this message translates to:
  /// **'Select Your Skills'**
  String get selectSkills;

  /// No description provided for @setLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Your Location'**
  String get setLocation;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @searchJobs.
  ///
  /// In en, this message translates to:
  /// **'Search jobs...'**
  String get searchJobs;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @techCategory.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get techCategory;

  /// No description provided for @cleaningCategory.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get cleaningCategory;

  /// No description provided for @constructionCategory.
  ///
  /// In en, this message translates to:
  /// **'Construction'**
  String get constructionCategory;

  /// No description provided for @tutoringCategory.
  ///
  /// In en, this message translates to:
  /// **'Tutoring'**
  String get tutoringCategory;

  /// No description provided for @otherCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherCategory;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @applyForJob.
  ///
  /// In en, this message translates to:
  /// **'Apply for This Job'**
  String get applyForJob;

  /// No description provided for @saveForLater.
  ///
  /// In en, this message translates to:
  /// **'Save for Later'**
  String get saveForLater;

  /// No description provided for @alreadyApplied.
  ///
  /// In en, this message translates to:
  /// **'Already Applied'**
  String get alreadyApplied;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @coverMessage.
  ///
  /// In en, this message translates to:
  /// **'Cover Message (optional)'**
  String get coverMessage;

  /// No description provided for @coverMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Tell the provider why you\'re a great fit...'**
  String get coverMessageHint;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submitApplication;

  /// No description provided for @applicationSent.
  ///
  /// In en, this message translates to:
  /// **'Application Sent!'**
  String get applicationSent;

  /// No description provided for @applicationSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Your application has been submitted successfully.'**
  String get applicationSentMessage;

  /// No description provided for @myApplications.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get myApplications;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @withdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get withdrawn;

  /// No description provided for @noApplications.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get noApplications;

  /// No description provided for @noApplicationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Start applying for jobs to see your applications here.'**
  String get noApplicationsMessage;

  /// No description provided for @postJob.
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get postJob;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get jobDescription;

  /// No description provided for @skillsRequired.
  ///
  /// In en, this message translates to:
  /// **'Skills Required'**
  String get skillsRequired;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @payAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay Amount'**
  String get payAmount;

  /// No description provided for @payType.
  ///
  /// In en, this message translates to:
  /// **'Pay Type'**
  String get payType;

  /// No description provided for @fixedPay.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixedPay;

  /// No description provided for @hourlyPay.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourlyPay;

  /// No description provided for @negotiable.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get negotiable;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @publishJob.
  ///
  /// In en, this message translates to:
  /// **'Publish Job'**
  String get publishJob;

  /// No description provided for @jobPosted.
  ///
  /// In en, this message translates to:
  /// **'Job Posted!'**
  String get jobPosted;

  /// No description provided for @jobPostedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your job has been published successfully.'**
  String get jobPostedMessage;

  /// No description provided for @editJob.
  ///
  /// In en, this message translates to:
  /// **'Edit Job'**
  String get editJob;

  /// No description provided for @closeJob.
  ///
  /// In en, this message translates to:
  /// **'Close Job'**
  String get closeJob;

  /// No description provided for @deleteJob.
  ///
  /// In en, this message translates to:
  /// **'Delete Job'**
  String get deleteJob;

  /// No description provided for @myJobs.
  ///
  /// In en, this message translates to:
  /// **'My Jobs'**
  String get myJobs;

  /// No description provided for @activeJobs.
  ///
  /// In en, this message translates to:
  /// **'Active Jobs'**
  String get activeJobs;

  /// No description provided for @closedJobs.
  ///
  /// In en, this message translates to:
  /// **'Closed Jobs'**
  String get closedJobs;

  /// No description provided for @applicants.
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get applicants;

  /// No description provided for @viewApplicants.
  ///
  /// In en, this message translates to:
  /// **'View Applicants'**
  String get viewApplicants;

  /// No description provided for @acceptApplicant.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptApplicant;

  /// No description provided for @rejectApplicant.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectApplicant;

  /// No description provided for @acceptConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept Applicant?'**
  String get acceptConfirmTitle;

  /// No description provided for @acceptConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to accept this applicant?'**
  String get acceptConfirmMessage;

  /// No description provided for @rejectConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Applicant?'**
  String get rejectConfirmTitle;

  /// No description provided for @rejectConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this applicant?'**
  String get rejectConfirmMessage;

  /// No description provided for @rateWorker.
  ///
  /// In en, this message translates to:
  /// **'Rate Worker'**
  String get rateWorker;

  /// No description provided for @rateProvider.
  ///
  /// In en, this message translates to:
  /// **'Rate Provider'**
  String get rateProvider;

  /// No description provided for @ratingTitle.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get ratingTitle;

  /// No description provided for @ratingComment.
  ///
  /// In en, this message translates to:
  /// **'Leave a comment (optional)'**
  String get ratingComment;

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submitRating;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @jobsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Jobs Completed'**
  String get jobsCompleted;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviews;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @noJobsFound.
  ///
  /// In en, this message translates to:
  /// **'No jobs near you yet'**
  String get noJobsFound;

  /// No description provided for @noJobsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Check back soon!'**
  String get noJobsFoundMessage;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get noNotificationsMessage;

  /// No description provided for @newJobMatch.
  ///
  /// In en, this message translates to:
  /// **'New Job Match!'**
  String get newJobMatch;

  /// No description provided for @applicationReceived.
  ///
  /// In en, this message translates to:
  /// **'New Application'**
  String get applicationReceived;

  /// No description provided for @applicationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Application Accepted'**
  String get applicationAccepted;

  /// No description provided for @applicationRejected.
  ///
  /// In en, this message translates to:
  /// **'Application Rejected'**
  String get applicationRejected;

  /// No description provided for @ratingReceived.
  ///
  /// In en, this message translates to:
  /// **'New Rating'**
  String get ratingReceived;

  /// No description provided for @providerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get providerDashboard;

  /// No description provided for @totalApplicants.
  ///
  /// In en, this message translates to:
  /// **'Total Applicants'**
  String get totalApplicants;

  /// No description provided for @openJobs.
  ///
  /// In en, this message translates to:
  /// **'Open Jobs'**
  String get openJobs;

  /// No description provided for @filterJobs.
  ///
  /// In en, this message translates to:
  /// **'Filter Jobs'**
  String get filterJobs;

  /// No description provided for @maxDistance.
  ///
  /// In en, this message translates to:
  /// **'Max Distance'**
  String get maxDistance;

  /// No description provided for @payRange.
  ///
  /// In en, this message translates to:
  /// **'Pay Range'**
  String get payRange;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @tsh.
  ///
  /// In en, this message translates to:
  /// **'TSh'**
  String get tsh;

  /// No description provided for @postedAgo.
  ///
  /// In en, this message translates to:
  /// **'Posted {time}'**
  String postedAgo(String time);

  /// No description provided for @nApplicants.
  ///
  /// In en, this message translates to:
  /// **'{count} applicants'**
  String nApplicants(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
