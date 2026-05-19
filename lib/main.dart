import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/app/app.dart';
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
import 'firebase_options.dart';
import 'package:fursafy/core/config/env_config.dart';

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

  // Validate environment configuration before initializing Firebase
  final missing = EnvConfig.missingVariables;
  if (missing.isNotEmpty) {
    debugPrint('Missing env variables: ${missing.join(', ')}');
    debugPrint('Pass them with --dart-define or use --dart-define-from-file');
  }

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

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
      ],
      child: const FursafyApp(),
    ),
  );
}
