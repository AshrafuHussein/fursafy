import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/services/notification_service.dart';
import 'package:fursafy/features/auth/presentation/bloc/auth_bloc.dart';

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
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Navigate after animation — but skip if the app was launched
    // from a notification tap (the notification handler already navigated).
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (NotificationService.instance.launchedFromNotification) {
        debugPrint('[Splash] Skipping redirect — launched from notification');
        return;
      }
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
      backgroundColor: FursafyTheme.surface,
      body: Stack(
        children: [
          // Background Decorations
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: FursafyTheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                color: FursafyTheme.secondaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main Content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Icon with Gradient
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    FursafyTheme.primary,
                                    FursafyTheme.primaryContainer,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: FursafyTheme.ambientShadow,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Image.asset(
                                  'assets/icons/icon.png',
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Accent Dot
                            Positioned(
                              top: -8,
                              right: -8,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: FursafyTheme.secondaryContainer,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FursafyTheme.surface,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        const SizedBox(height: 16),
                        // Tagline
                        Text(
                          'Your opportunity,\none tap away',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: FursafyTheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Loading Bar at Bottom
          Positioned(
            bottom: 48,
            left: 48,
            right: 48,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      backgroundColor: FursafyTheme.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FursafyTheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
