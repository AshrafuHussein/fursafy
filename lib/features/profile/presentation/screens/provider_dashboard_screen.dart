import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// S14 — Provider Home Dashboard (Stitch Exact Match).
class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  List<JobEntity> _recentJobs = [];
  bool _loading = true;
  int _activeJobCount = 0;
  int _totalApplications = 0;
  final int _jobsFilledCount = 48; // Mocked for design parity
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    // 1. Fetch user doc independently
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data();
        });
      }
    } catch (e) {
      debugPrint('ProviderDashboardScreen._loadDashboard user doc error: $e');
    }

    // 2. Fetch jobs and counts
    try {
      final jobSnap = await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs)
          .where('providerId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      final jobs = jobSnap.docs
          .map((d) => JobEntity.fromMap(d.id, d.data()))
          .toList();
      final active = jobs.where((j) => j.status == JobStatus.open).length;

      // Count total applications
      int appCount = 0;
      for (final job in jobs) {
        final appSnap = await FirebaseFirestore.instance
            .collection(FirestorePaths.applications)
            .where('jobId', isEqualTo: job.id)
            .get();
        appCount += appSnap.docs.length;
      }

      setState(() {
        _recentJobs = jobs;
        _activeJobCount = active;
        _totalApplications = appCount;
      });
    } catch (e) {
      debugPrint('ProviderDashboardScreen._loadDashboard jobs error: $e');
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = _userData?['displayName'] ??
        FirebaseAuth.instance.currentUser?.displayName ?? 'Provider';
    final avatarUrl = _userData?['avatarUrl'] as String?;

    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: FursafyTheme.surfaceContainerLow.withValues(
          alpha: 0.8,
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: FursafyTheme.primaryContainer,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(avatarUrl)
                : null,
            child: avatarUrl == null || avatarUrl.isEmpty
                ? const Icon(Icons.person, color: FursafyTheme.onPrimary, size: 20)
                : null,
          ),
        ),
        title: Text(
          'Fursafy',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: FursafyTheme.primary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.notifications),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: FursafyTheme.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FursafyTheme.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              color: FursafyTheme.primary,
              child: CustomScrollView(
                slivers: [
                  // Welcome Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Karibu, $userName',
                            style: FursafyTheme.headlineStyle.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: FursafyTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Manage your hiring pipeline and find Tanzania's best talent.",
                            style: FursafyTheme.bodyStyle.copyWith(
                              color: FursafyTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bento Grid Stats
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _buildBentoStat(
                                icon: Icons.analytics_outlined,
                                label: 'ACTIVE JOBS',
                                value: _activeJobCount.toString(),
                                bgColor: FursafyTheme.primary,
                                textColor: FursafyTheme.onPrimary,
                                labelColor: FursafyTheme.primaryFixed,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: _buildBentoStat(
                                      icon: Icons.group_outlined,
                                      label: 'APPLICANTS',
                                      value: _totalApplications.toString(),
                                      bgColor:
                                          FursafyTheme.surfaceContainerLowest,
                                      textColor: FursafyTheme.onSurface,
                                      labelColor: FursafyTheme.onSurfaceVariant,
                                      isSmall: true,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: _buildBentoStat(
                                      icon: Icons.check_circle_outline,
                                      label: 'JOBS FILLED',
                                      value: _jobsFilledCount.toString(),
                                      bgColor: FursafyTheme.surfaceContainer,
                                      textColor: FursafyTheme.onSurface,
                                      labelColor: FursafyTheme.onSurfaceVariant,
                                      isSmall: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Hiring Health Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: FursafyTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Hiring Health',
                                  style: FursafyTheme.headlineStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Target: 60 Filled',
                                  style: FursafyTheme.bodyStyle.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: FursafyTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: const LinearProgressIndicator(
                                value: 0.8,
                                minHeight: 12,
                                backgroundColor:
                                    FursafyTheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FursafyTheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your profile is 80% towards your quarterly goal. Keep it up!',
                              style: FursafyTheme.bodyStyle.copyWith(
                                fontSize: 13,
                                color: FursafyTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Recent Jobs Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Recent Jobs',
                            style: FursafyTheme.headlineStyle.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.myJobs),
                            child: Row(
                              children: [
                                Text(
                                  'View All',
                                  style: FursafyTheme.bodyStyle.copyWith(
                                    color: FursafyTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 14,
                                  color: FursafyTheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recent Jobs List
                  if (_recentJobs.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No jobs posted yet.',
                            style: FursafyTheme.bodyStyle.copyWith(
                              color: FursafyTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _buildEditorialJobCard(_recentJobs[index]);
                        }, childCount: _recentJobs.length),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.postJob),
        backgroundColor: FursafyTheme.secondaryContainer,
        foregroundColor: FursafyTheme.onSecondaryContainer,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, size: 32),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBentoStat({
    required IconData icon,
    required String label,
    required String value,
    required Color bgColor,
    required Color textColor,
    required Color labelColor,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: bgColor == FursafyTheme.surfaceContainerLowest
            ? Border.all(
                color: FursafyTheme.outlineVariant.withValues(alpha: 0.1),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: textColor.withValues(
              alpha: bgColor == FursafyTheme.primary ? 1.0 : 0.8,
            ),
            size: isSmall ? 28 : 40,
          ),
          if (!isSmall) const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FursafyTheme.labelStyle.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: FursafyTheme.headlineStyle.copyWith(
                  color: textColor,
                  fontSize: isSmall ? 28 : 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditorialJobCard(JobEntity job) {
    return GestureDetector(
      onTap: () => context.push('/provider/jobs/${job.id}/applicants'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FursafyTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Job Image Placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=200&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: FursafyTheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.locationName ?? 'Tanzania',
                        style: FursafyTheme.labelStyle.copyWith(
                          color: FursafyTheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (job.payAmount > 100000)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FursafyTheme.secondary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bolt,
                                size: 12,
                                color: FursafyTheme.secondary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'URGENT',
                                style: FursafyTheme.labelStyle.copyWith(
                                  color: FursafyTheme.secondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '12', // Mocked count
                  style: FursafyTheme.headlineStyle.copyWith(
                    color: FursafyTheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'APPLICANTS',
                  style: FursafyTheme.labelStyle.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: FursafyTheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
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
              _buildNavItem(Icons.home_max, 'HOME', true),
              _buildNavItem(
                Icons.work_outline,
                'WORK',
                false,
                onTap: () => context.push(AppRoutes.myJobs),
              ),
              _buildNavItem(
                Icons.add_circle_outline,
                'ADD',
                false,
                onTap: () => context.push(AppRoutes.postJob),
              ),
              _buildNavItem(
                Icons.mail_outline,
                'INBOX',
                false,
                onTap: () => context.push(AppRoutes.notifications),
              ),
              _buildNavItem(
                Icons.person_outline,
                'PROFILE',
                false,
                onTap: () => context.push(AppRoutes.profile),
              ),
            ],
          ),
        ),
      ),
    );
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
}
