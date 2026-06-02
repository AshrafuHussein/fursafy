import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fursafy/app/theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fursafy/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:fursafy/features/notifications/domain/entities/notification_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/core/constants/app_constants.dart';

/// S11 — Notifications screen — Editorial "Daily Curation" design.
/// Powered by NotificationBloc for reactive state management.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications via BLoC
    context.read<NotificationBloc>().add(const NotificationLoadRequested());
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'application_accepted':
        return Icons.verified;
      case 'application_rejected':
        return Icons.cancel_outlined;
      case 'new_application':
      case 'application_received':
        return Icons.person_add;
      case 'job_match':
        return Icons.work;
      case 'rating_received':
        return Icons.rate_review;
      default:
        return Icons.update;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'application_accepted':
        return FursafyTheme.secondary;
      case 'application_rejected':
        return FursafyTheme.error;
      case 'new_application':
      case 'application_received':
        return FursafyTheme.secondary;
      case 'job_match':
        return FursafyTheme.primary;
      case 'rating_received':
        return const Color(0xFF6B4200); // on-secondary-container
      default:
        return FursafyTheme.onSurfaceVariant;
    }
  }

  String _labelForType(String? type) {
    switch (type) {
      case 'application_accepted':
        return 'MILESTONE';
      case 'application_rejected':
        return 'UPDATE';
      case 'job_match':
        return 'CAREER ENGINE';
      case 'new_application':
      case 'application_received':
        return 'APPLICATION';
      case 'rating_received':
        return 'FEEDBACK';
      default:
        return 'SYSTEM UPDATE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isProvider =
        authState is AuthAuthenticated &&
        authState.user.role.name == 'provider';

    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: FursafyTheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: FursafyTheme.surfaceContainerHighest,
              ),
              child: const Icon(
                Icons.person,
                color: FursafyTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'FURSAFY',
              style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: FursafyTheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          // Mark all as read button
          BlocBuilder<NotificationBloc, NotificationState>(
            buildWhen: (prev, curr) => prev.unreadCount != curr.unreadCount,
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.done_all, color: FursafyTheme.primary),
                tooltip: 'Mark all as read',
                onPressed: () {
                  context
                      .read<NotificationBloc>()
                      .add(const NotificationMarkAllAsRead());
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: FursafyTheme.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading &&
              state.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: FursafyTheme.primary),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<NotificationBloc>()
                  .add(const NotificationLoadRequested());
              // Wait briefly for the bloc to process
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: FursafyTheme.primary,
            child: CustomScrollView(
              slivers: [
                // Status bar padding
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Editorial Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          isProvider ? 'Inbox' : 'Daily Curation',
                          style: FursafyTheme.headlineStyle.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: FursafyTheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isProvider
                              ? 'Manage communications and hiring activities.'
                              : 'Your personalized updates and career milestones.',
                          style: FursafyTheme.bodyStyle.copyWith(
                            color: FursafyTheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Notifications List
                state.notifications.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            if (index < state.notifications.length) {
                              return _buildNotificationCard(
                                state.notifications[index],
                              );
                            }
                            return null;
                          }, childCount: state.notifications.length),
                        ),
                      ),

                // Stay Ahead CTA Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                    child: _buildStayAheadCard(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context, isProvider),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isProvider) {
    if (isProvider) {
      return Container(
        decoration: BoxDecoration(
          color: FursafyTheme.surface.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.home_max,
                  'HOME',
                  false,
                  onTap: () => context.go(AppRoutes.providerDashboard),
                ),
                _buildNavItem(
                  Icons.work_outline,
                  'WORK',
                  false,
                  onTap: () => context.go(AppRoutes.myJobs),
                ),
                _buildNavItem(
                  Icons.add_circle_outline,
                  'ADD',
                  false,
                  onTap: () => context.push(AppRoutes.postJob),
                ),
                _buildNavItem(Icons.mail, 'INBOX', true),
                _buildNavItem(
                  Icons.person_outline,
                  'PROFILE',
                  false,
                  onTap: () => context.go(AppRoutes.profile),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: FursafyTheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  context,
                  Icons.home_max_rounded,
                  'HOME',
                  false,
                  onTap: () => context.go(AppRoutes.home),
                ),
                _navItem(
                  context,
                  Icons.search_rounded,
                  'SEARCH',
                  false,
                  onTap: () => context.push(AppRoutes.search),
                ),
                _navItem(
                  context,
                  Icons.description_outlined,
                  'APPLIED',
                  false,
                  onTap: () => context.go(AppRoutes.myApplications),
                ),
                _navItem(context, Icons.notifications_active, 'ALERTS', true),
                _navItem(
                  context,
                  Icons.person_outline_rounded,
                  'PROFILE',
                  false,
                  onTap: () => context.go(AppRoutes.profile),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? FursafyTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? FursafyTheme.primary : FursafyTheme.outline,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: FursafyTheme.labelStyle.copyWith(
                color: isActive ? FursafyTheme.primary : FursafyTheme.outline,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? FursafyTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? FursafyTheme.primary : FursafyTheme.outline,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: FursafyTheme.labelStyle.copyWith(
                color: isActive ? FursafyTheme.primary : FursafyTheme.outline,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(
            Icons.notifications_off_outlined,
            size: 56,
            color: FursafyTheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: FursafyTheme.headlineStyle.copyWith(
              fontSize: 18,
              color: FursafyTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your personalized updates will appear here.',
            style: FursafyTheme.bodyStyle.copyWith(
              color: FursafyTheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationEntity notification) {
    final type = notification.type.firestoreValue;
    final isRead = notification.isRead;
    final createdAt = notification.createdAt;
    final message = notification.message;
    final color = _colorForType(type);
    final icon = _iconForType(type);
    final label = _labelForType(type);

    final jobId = notification.jobId;

    // Determine if it's a "featured" notification (job_match)
    final isFeatured = type == 'job_match';

    return GestureDetector(
      onTap: () async {
        // Mark as read via BLoC
        context
            .read<NotificationBloc>()
            .add(NotificationMarkAsRead(notification.id));

        if (!mounted) return;

        final uid = FirebaseAuth.instance.currentUser?.uid;

        if (type == 'application_accepted' || type == 'application_rejected') {
          if (jobId != null && jobId.isNotEmpty) {
            try {
              final snap = await FirebaseFirestore.instance
                  .collection(FirestorePaths.applications)
                  .where('jobId', isEqualTo: jobId)
                  .where('youthId', isEqualTo: uid)
                  .limit(1)
                  .get();
              if (snap.docs.isNotEmpty && mounted) {
                context.push('/applications/${snap.docs.first.id}');
              }
            } catch (_) {}
          }
        } else if (type == 'job_match' && jobId != null && jobId.isNotEmpty) {
          context.push('/jobs/$jobId');
        } else if ((type == 'application_received' ||
                type == 'new_application') &&
            jobId != null &&
            jobId.isNotEmpty) {
          context.push('/provider/jobs/$jobId/applicants');
        } else if (type == 'rating_received') {
          context.go(AppRoutes.profile);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isFeatured
              ? FursafyTheme.surfaceContainerLowest
              : isRead
              ? FursafyTheme.surfaceContainerLow
              : FursafyTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: isFeatured
              ? null
              : Border(
                  left: type == 'rating_received'
                      ? const BorderSide(
                          color: FursafyTheme.secondaryContainer,
                          width: 4,
                        )
                      : BorderSide.none,
                ),
          boxShadow: isFeatured
              ? [
                  BoxShadow(
                    color: FursafyTheme.onSurface.withValues(alpha: 0.04),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label + Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: FursafyTheme.labelStyle.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: color,
                        ),
                      ),
                      Text(
                        timeago.format(createdAt, locale: 'en_short'),
                        style: FursafyTheme.labelStyle.copyWith(
                          fontSize: 11,
                          color: FursafyTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Message
                  Text(
                    message,
                    style: FursafyTheme.bodyStyle.copyWith(
                      fontSize: 13,
                      color: FursafyTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  // Action button for featured
                  if (isFeatured) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: FursafyTheme.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'View Opportunity',
                        style: FursafyTheme.labelStyle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: FursafyTheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The green CTA card at the bottom: "Stay Ahead"
  Widget _buildStayAheadCard() {
    final authState = context.read<AuthBloc>().state;
    final isProvider =
        authState is AuthAuthenticated &&
        authState.user.role.name == 'provider';

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: FursafyTheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Decorative background circle
          Positioned(
            right: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FursafyTheme.primaryContainer.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Decorative icon
          Positioned(
            right: 0,
            top: -8,
            child: Icon(
              Icons.auto_awesome,
              size: 80,
              color: FursafyTheme.onPrimary.withValues(alpha: 0.1),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isProvider ? 'Stay Connected' : 'Stay Ahead',
                style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: FursafyTheme.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 200,
                child: Text(
                  isProvider
                      ? 'Keep your profile updated to build trust and attract high-quality applicants.'
                      : 'Complete your profile to unlock more curated opportunities.',
                  style: FursafyTheme.bodyStyle.copyWith(
                    fontSize: 13,
                    color: FursafyTheme.primaryFixed.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
