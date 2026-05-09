import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/app/app.dart';
import 'package:fursafy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fursafy/features/auth/presentation/bloc/register_bloc.dart';
import 'package:fursafy/features/auth/data/repositories/auth_repository_impl.dart';

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
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // For UI preview purposes, we allow the app to continue even if Firebase isn't set up yet.
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
        // Additional BLoCs will be added as features are implemented
      ],
      child: const FursafyApp(),
    ),
  );
}
