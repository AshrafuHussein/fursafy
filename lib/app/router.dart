import 'package:go_router/go_router.dart';
import '../core/services/notification_service.dart';

// Placeholder screens — will be replaced with Stitch-generated UI
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_role_screen.dart';
import '../features/auth/presentation/screens/register_details_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/skill_picker_screen.dart';
import '../features/jobs/presentation/screens/home_feed_screen.dart';
import '../features/jobs/presentation/screens/job_detail_screen.dart';
import '../features/jobs/presentation/screens/post_job_screen.dart';
import '../features/jobs/presentation/screens/edit_job_screen.dart';
import '../features/jobs/presentation/screens/search_filter_screen.dart';
import '../features/applications/presentation/screens/my_applications_screen.dart';
import '../features/applications/presentation/screens/applicants_screen.dart';
import '../features/applications/presentation/screens/application_detail_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/my_jobs_screen.dart';
import '../features/profile/presentation/screens/provider_dashboard_screen.dart';
import '../features/profile/presentation/screens/provider_profile_screen.dart';
import '../features/profile/presentation/screens/youth_public_profile_screen.dart';
import '../features/ratings/presentation/screens/rating_screen.dart';
import '../features/ratings/presentation/screens/provider_rating_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/jobs/presentation/screens/map_view_screen.dart';
import '../core/constants/app_constants.dart';

/// App route names.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String registerRole = '/register/role';
  static const String registerDetails = '/register/details';
  static const String otp = '/register/otp';
  static const String forgotPassword = '/forgot-password';
  static const String skillPicker = '/register/profile';
  static const String home = '/home';
  static const String jobDetail = '/jobs/:jobId';
  static const String postJob = '/provider/jobs/new';
  static const String editJob = '/provider/jobs/:jobId/edit';
  static const String search = '/search';
  static const String myApplications = '/applications';
  static const String applicants = '/provider/jobs/:jobId/applicants';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String providerDashboard = '/provider/home';
  static const String myJobs = '/provider/jobs';
  static const String rateJob = '/rate/:jobId';
  static const String providerRateJob = '/provider/rate/:jobId';
  static const String applicationDetail = '/applications/:applicationId';
  static const String youthPublicProfile = '/youth/:uid';
  static const String map = '/map';
  static const String admin = '/admin';
}

/// GoRouter configuration.
final GoRouter appRouter = GoRouter(
  navigatorKey: NotificationService.navigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    // ─── Auth ───
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.registerRole,
      builder: (context, state) => const RegisterRoleScreen(),
    ),
    GoRoute(
      path: AppRoutes.registerDetails,
      builder: (context, state) {
        return const RegisterDetailsScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        return const OtpScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.skillPicker,
      builder: (context, state) => const SkillPickerScreen(),
    ),

    // ─── Youth Screens ───
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeFeedScreen(),
    ),
    GoRoute(
      path: AppRoutes.jobDetail,
      builder: (context, state) {
        final jobId = state.pathParameters['jobId']!;
        return JobDetailScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchFilterScreen(),
    ),
    GoRoute(
      path: AppRoutes.myApplications,
      builder: (context, state) => const MyApplicationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.applicationDetail,
      builder: (context, state) {
        final applicationId = state.pathParameters['applicationId']!;
        return ApplicationDetailScreen(applicationId: applicationId);
      },
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthAuthenticated) {
              if (authState.user.role.name == 'provider') {
                return const ProviderProfileScreen();
              }
            }
            return const ProfileScreen();
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),

    // ─── Provider Screens ───
    GoRoute(
      path: AppRoutes.providerDashboard,
      builder: (context, state) => const ProviderDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.editJob,
      builder: (context, state) {
        final jobId = state.pathParameters['jobId']!;
        return EditJobScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: AppRoutes.postJob,
      builder: (context, state) => const PostJobScreen(),
    ),
    GoRoute(
      path: AppRoutes.myJobs,
      builder: (context, state) => const MyJobsScreen(),
    ),
    GoRoute(
      path: AppRoutes.applicants,
      builder: (context, state) {
        final jobId = state.pathParameters['jobId']!;
        return ApplicantsScreen(jobId: jobId);
      },
    ),

    // ─── Shared ───
    GoRoute(
      path: AppRoutes.rateJob,
      builder: (context, state) {
        final jobId = state.pathParameters['jobId']!;
        return RatingScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: AppRoutes.providerRateJob,
      builder: (context, state) {
        final jobId = state.pathParameters['jobId']!;
        return ProviderRatingScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: AppRoutes.youthPublicProfile,
      builder: (context, state) {
        final uid = state.pathParameters['uid']!;
        return YouthPublicProfileScreen(uid: uid);
      },
    ),
    GoRoute(
      path: AppRoutes.map,
      builder: (context, state) => const MapViewScreen(),
    ),
    GoRoute(
      path: AppRoutes.admin,
      builder: (context, state) => const AdminDashboardScreen(),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated && authState.user.role == UserRole.admin) {
          return null; // Let them through
        }
        return AppRoutes.login; // Redirect to login
      },
    ),
  ],
);
