import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/app/app.dart';
import 'package:fursafy/core/utils/db_seeder.dart';
import 'package:fursafy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fursafy/features/auth/presentation/bloc/register_bloc.dart';
import 'package:fursafy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fursafy/features/jobs/data/repositories/job_repository_impl.dart';
import 'package:fursafy/features/jobs/presentation/bloc/job_feed_bloc.dart';
import 'package:fursafy/features/jobs/presentation/bloc/job_feed_event.dart';
import 'package:fursafy/features/applications/data/repositories/application_repository_impl.dart';
import 'package:fursafy/features/applications/presentation/bloc/application_bloc.dart';
import 'package:fursafy/features/ratings/data/repositories/rating_repository_impl.dart';
import 'package:fursafy/features/ratings/presentation/bloc/rating_bloc.dart';
import 'package:fursafy/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:fursafy/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fursafy/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:fursafy/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:fursafy/core/services/notification_service.dart';
import 'package:fursafy/core/location/location_bloc.dart';
import 'package:fursafy/core/location/location_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFAF9F4),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase — google-services.json + Gradle plugin handle native config.
  try {
    await Firebase.initializeApp();
    await DatabaseSeeder.seedJobsIfNeeded();
  } catch (e) {
    // Already initialized by native plugin — safe to continue.
    debugPrint('Firebase init: $e');
  }

  // Initialize FCM push notifications
  await NotificationService.instance.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: AuthRepositoryImpl(),
          )..add(AuthCheckRequested()),
        ),
        BlocProvider<RegisterBloc>(
          create: (context) => RegisterBloc(
            authRepository: AuthRepositoryImpl(),
          ),
        ),
        BlocProvider<JobFeedBloc>(
          create: (context) => JobFeedBloc(
            jobRepository: JobRepositoryImpl(),
          )..add(const JobFeedLoadRequested()),
        ),
        BlocProvider<ApplicationBloc>(
          create: (context) => ApplicationBloc(
            applicationRepository: ApplicationRepositoryImpl(),
          ),
        ),
        BlocProvider<RatingBloc>(
          create: (context) => RatingBloc(
            ratingRepository: RatingRepositoryImpl(),
          ),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(
            profileRepository: ProfileRepositoryImpl(),
          ),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            repository: NotificationRepositoryImpl(),
          )..add(const UnreadCountSubscriptionRequested()),
        ),
        BlocProvider<LocationBloc>(
          create: (context) => LocationBloc()
            ..add(const LocationRequested())
            ..add(const LocationBackgroundStarted()),
        ),
      ],
      child: const FursafyApp(),
    ),
  );
}
