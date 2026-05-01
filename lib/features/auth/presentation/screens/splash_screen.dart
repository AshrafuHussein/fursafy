import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/router.dart';
import '../../../../app/theme.dart';
import '../bloc/auth_bloc.dart';

/// S01 — Splash screen. Checks auth and routes accordingly.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    // Navigate after animation
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated) {
        final role = state.user.role.name;
        if (role == 'provider') {
          context.go(AppRoutes.providerDashboard);
        } else {
          context.go(AppRoutes.home);
        }
      } else {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.work_rounded,
                  size: 56,
                  color: FursafyTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Fursafy',
                style: TextStyle(
                  fontFamily: FursafyTheme.headlineFont,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fursa kwa Vijana',
                style: TextStyle(
                  fontFamily: FursafyTheme.bodyFont,
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
