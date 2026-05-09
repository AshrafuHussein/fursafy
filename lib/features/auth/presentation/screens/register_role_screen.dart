import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/features/auth/presentation/bloc/register_bloc.dart';

/// S04 — Registration Role Selection.
class RegisterRoleScreen extends StatelessWidget {
  const RegisterRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FursafyTheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Decor
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FursafyTheme.primary.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FursafyTheme.secondaryContainer.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: FursafyTheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.pets, color: FursafyTheme.onPrimary, size: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Fursafy',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: FursafyTheme.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        Text(
                          'Your journey\nstarts with a choice.',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: FursafyTheme.onSurface,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select the role that fits your goals today. We\'ll curate the best opportunities just for you.',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: FursafyTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 48),

                        // Youth Worker Option
                        _RoleCard(
                          title: 'Youth Worker',
                          description: 'I am looking for meaningful work, apprenticeships, or gig opportunities to grow my career.',
                          icon: Icons.person_search_rounded,
                          iconColor: FursafyTheme.primary,
                          iconBgColor: FursafyTheme.primary.withValues(alpha: 0.1),
                          cardColor: FursafyTheme.surfaceContainerLowest,
                          onTap: () {
                            context.read<RegisterBloc>().add(const RegisterRoleSelected('youth'));
                            context.push(AppRoutes.registerDetails);
                          },
                        ),
                        const SizedBox(height: 24),

                        // Job Provider Option
                        _RoleCard(
                          title: 'Job Provider',
                          description: 'I am looking to hire talented youth, post job listings, or offer skill-building projects.',
                          icon: Icons.business_center_rounded,
                          iconColor: FursafyTheme.onSecondaryContainer,
                          iconBgColor: FursafyTheme.secondaryContainer.withValues(alpha: 0.2),
                          cardColor: FursafyTheme.surfaceContainerLow,
                          onTap: () {
                            context.read<RegisterBloc>().add(const RegisterRoleSelected('provider'));
                            context.push(AppRoutes.registerDetails);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color cardColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: FursafyTheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FursafyTheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
