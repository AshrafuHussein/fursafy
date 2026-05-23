import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/applications/domain/entities/application_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

/// S10 — My Applications screen (Youth) — Editorial design.
class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  List<ApplicationEntity> _applications = [];
  bool _loading = true;
  int _selectedTab = 0; // 0=Pending, 1=Accepted, 2=Rejected

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection(FirestorePaths.applications)
          .where('youthId', isEqualTo: uid)
          .orderBy('appliedAt', descending: true)
          .get();

      setState(() {
        _applications = snap.docs
            .map((d) => ApplicationEntity.fromMap(d.id, d.data()))
            .toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<ApplicationEntity> _filtered() {
    switch (_selectedTab) {
      case 0:
        return _applications
            .where((a) => a.status == ApplicationStatus.pending)
            .toList();
      case 1:
        return _applications
            .where((a) => a.status == ApplicationStatus.accepted)
            .toList();
      case 2:
        return _applications
            .where((a) => a.status == ApplicationStatus.rejected)
            .toList();
      default:
        return _applications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FursafyTheme.primary))
          : CustomScrollView(
              slivers: [
                // Invisible status bar padding
                SliverToBoxAdapter(
                  child: SizedBox(
                      height: MediaQuery.of(context).padding.top + 16),
                ),

                // Editorial Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TRACK YOUR GROWTH',
                          style: FursafyTheme.labelStyle.copyWith(
                            color: FursafyTheme.secondary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3.0,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'My Applications',
                          style: FursafyTheme.headlineStyle.copyWith(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: FursafyTheme.onSurface,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Pill-shaped Tab Selector
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabDelegate(
                    child: Container(
                      color: FursafyTheme.surface.withValues(alpha: 0.9),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: FursafyTheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            _buildTabPill('Pending', 0),
                            _buildTabPill('Accepted', 1),
                            _buildTabPill('Rejected', 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Applications List
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  sliver: _buildApplicationsList(),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
              _navItem(context, Icons.home_max_rounded, 'HOME', false,
                  onTap: () => context.go(AppRoutes.home)),
              _navItem(context, Icons.search_rounded, 'SEARCH', false,
                  onTap: () => context.push(AppRoutes.search)),
              _navItem(context, Icons.description_outlined, 'APPLIED', true),
              _navItem(context, Icons.notifications_none_rounded, 'ALERTS', false,
                  onTap: () => context.go(AppRoutes.notifications)),
              _navItem(context, Icons.person_outline_rounded, 'PROFILE', false,
                  onTap: () => context.go(AppRoutes.profile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool isActive,
      {VoidCallback? onTap}) {
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

  Widget _buildTabPill(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? FursafyTheme.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            boxShadow: isSelected ? FursafyTheme.ambientShadow : null,
          ),
          child: Center(
            child: Text(
              label,
              style: FursafyTheme.labelStyle.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? FursafyTheme.primary
                    : FursafyTheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationsList() {
    final apps = _filtered();

    if (apps.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Motivational empty state (dashed card)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: FursafyTheme.outlineVariant.withValues(alpha: 0.3),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.history_edu,
                    size: 40,
                    color: FursafyTheme.outlineVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Keep applying to increase your chances!\nNew opportunities added daily.',
                    textAlign: TextAlign.center,
                    style: FursafyTheme.bodyStyle.copyWith(
                      color: FursafyTheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < apps.length) {
            return _buildApplicationCard(apps[index], index);
          }
          // Footer motivational card
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: FursafyTheme.outlineVariant.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.history_edu,
                      size: 40, color: FursafyTheme.outlineVariant),
                  const SizedBox(height: 12),
                  Text(
                    'Keep applying to increase your chances!\nNew opportunities added daily.',
                    textAlign: TextAlign.center,
                    style: FursafyTheme.bodyStyle.copyWith(
                      color: FursafyTheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: apps.length + 1,
      ),
    );
  }

  Widget _buildApplicationCard(ApplicationEntity app, int index) {
    // Status badge
    Color badgeColor;
    Color badgeTextColor;
    String badgeLabel;
    switch (app.status) {
      case ApplicationStatus.accepted:
        badgeColor = FursafyTheme.primaryFixed;
        badgeTextColor = const Color(0xFF00513A);
        badgeLabel = 'ACCEPTED';
        break;
      case ApplicationStatus.rejected:
        badgeColor = FursafyTheme.tertiaryFixed;
        badgeTextColor = const Color(0xFF7E2A27);
        badgeLabel = 'REJECTED';
        break;
      case ApplicationStatus.withdrawn:
        badgeColor = FursafyTheme.surfaceContainerHigh;
        badgeTextColor = FursafyTheme.onSurfaceVariant;
        badgeLabel = 'WITHDRAWN';
        break;
      default:
        badgeColor = FursafyTheme.secondaryFixed;
        badgeTextColor = const Color(0xFF2A1700);
        badgeLabel = 'PENDING';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: FursafyTheme.ambientShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon/image + content + status badge
          Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job icon placeholder
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.work_outline,
                      color: FursafyTheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.jobTitle,
                            style: FursafyTheme.headlineStyle.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: FursafyTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Location + Date row
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14,
                                  color: FursafyTheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                'Applied ${timeago.format(app.appliedAt)}',
                                style: FursafyTheme.labelStyle.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: FursafyTheme.onSurfaceVariant,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Status Badge — top right
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    badgeLabel,
                    style: FursafyTheme.labelStyle.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: FursafyTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () => context.push('/jobs/${app.jobId}'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: FursafyTheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'VIEW JOB',
                      style: FursafyTheme.labelStyle.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: FursafyTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              if (app.status == ApplicationStatus.pending || app.status == ApplicationStatus.accepted) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: FursafyTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () {
                        if (app.status == ApplicationStatus.accepted) {
                          context.push('/applications/${app.id}');
                        } else {
                          // Withdraw action
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: FursafyTheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        app.status == ApplicationStatus.accepted ? 'NEXT STEPS' : 'WITHDRAW',
                        style: FursafyTheme.labelStyle.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: FursafyTheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Sticky header delegate for the tab bar
class _StickyTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTabDelegate({required this.child});

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyTabDelegate oldDelegate) => true;
}
