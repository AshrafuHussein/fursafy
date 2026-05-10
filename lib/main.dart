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
import 'firebase_options.dart';

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

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        // Additional BLoCs will be added as features are implemented
      ],
      child: const FursafyApp(),
    ),
  );
}
