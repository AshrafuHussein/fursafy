import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// S12b — Provider Profile screen — Cover + logo editorial design.
class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  Map<String, dynamic>? _userData;
  List<JobEntity> _activeJobs = [];
  bool _loading = true;
  int _totalJobsPosted = 0;
  int _jobsFilled = 0;
  Map<String, int> _applicantCounts = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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
      debugPrint('ProviderProfileScreen._loadProfile user doc error: $e');
    }

    // 2. Fetch jobs and counts
    try {
      final allJobsSnap = await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs)
          .where('providerId', isEqualTo: uid)
          .get();

      final activeJobSnap = await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs)
          .where('providerId', isEqualTo: uid)
          .where('status', isEqualTo: 'open')
          .limit(5)
          .get();

      final closedCount = allJobsSnap.docs
          .where((d) => d.data()['status'] == 'closed')
          .length;

      final jobs = activeJobSnap.docs
          .map((d) => JobEntity.fromMap(d.id, d.data()))
          .toList();

      final Map<String, int> applicantCounts = {};
      for (final job in jobs) {
        final countSnap = await FirebaseFirestore.instance
            .collection(FirestorePaths.applications)
            .where('jobId', isEqualTo: job.id)
            .where('providerId', isEqualTo: uid)
            .count()
            .get();
        applicantCounts[job.id] = countSnap.count ?? 0;
      }

      setState(() {
        _totalJobsPosted = allJobsSnap.docs.length;
        _jobsFilled = closedCount;
        _activeJobs = jobs;
        _applicantCounts = applicantCounts;
      });
    } catch (e) {
      debugPrint('ProviderProfileScreen._loadProfile jobs query error: $e');
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _userData?['avatarUrl'] as String?;
    debugPrint('ProviderProfileScreen: build - avatarUrl = $avatarUrl');

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
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          color: FursafyTheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : const Icon(
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
          IconButton(
            icon: const Icon(Icons.notifications, color: FursafyTheme.primary),
            onPressed: () => context.go(AppRoutes.notifications),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FursafyTheme.primary),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover + Logo Hero
                  _buildCoverHero(context),

                  // Stats Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: _buildStatsGrid(),
                  ),

                  // About Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildAboutSection(),
                  ),
                  const SizedBox(height: 32),

                  // Active Postings
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildActivePostings(context),
                  ),
                  const SizedBox(height: 32),

                  // Sign Out
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSignOutButton(context),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
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
              _buildNavItem(
                Icons.mail_outline,
                'INBOX',
                false,
                onTap: () => context.go(AppRoutes.notifications),
              ),
              _buildNavItem(Icons.person, 'PROFILE', true),
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

  Widget _buildCoverHero(BuildContext context) {
    final name = _userData?['displayName'] ?? 'Company Name';
    final avatarUrl = _userData?['avatarUrl'] as String?;
    final industry =
        _userData?['industry'] as String? ?? 'Opportunity Provider';
    final location = _userData?['locationName'] ?? 'Dar es Salaam, Tanzania';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover Image
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 192,
              width: double.infinity,
              color: FursafyTheme.primaryContainer,
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? Opacity(
                      opacity: 0.8,
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: FursafyTheme.primaryContainer,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: FursafyTheme.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: FursafyTheme.primaryContainer,
                        ),
                      ),
                    )
                  : null,
            ),
            // Profile Logo — overlapping the cover
            Positioned(
              left: 24,
              bottom: -48,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FursafyTheme.surfaceContainerLowest,
                  border: Border.all(color: FursafyTheme.surface, width: 4),
                  boxShadow: FursafyTheme.floatingShadow,
                ),
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: avatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: FursafyTheme.primary,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.business,
                            size: 40,
                            color: FursafyTheme.primary,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.business,
                        size: 40,
                        color: FursafyTheme.primary,
                      ),
              ),
            ),
            // Edit Profile Button — top right over cover
            Positioned(
              right: 24,
              bottom: -24,
              child: GestureDetector(
                onTap: () async {
                  final result = await context.push<bool>(AppRoutes.editProfile);
                  if (result == true) {
                    _loadProfile();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: FursafyTheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: FursafyTheme.ambientShadow,
                  ),
                  child: Text(
                    'Edit Profile',
                    style: FursafyTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: FursafyTheme.onSecondaryContainer,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 56),
        // Company Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: FursafyTheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.verified,
                    color: FursafyTheme.primary,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                industry,
                style: FursafyTheme.bodyStyle.copyWith(
                  fontSize: 14,
                  color: FursafyTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: FursafyTheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location.toUpperCase(),
                    style: FursafyTheme.labelStyle.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: FursafyTheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard(
          '$_totalJobsPosted',
          'Total Jobs\nPosted',
          FursafyTheme.surfaceContainerLow,
          FursafyTheme.primary,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          '$_jobsFilled',
          'Jobs\nFilled',
          FursafyTheme.surfaceContainerLow,
          FursafyTheme.primary,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          '${_activeJobs.length}',
          'Active\nJobs',
          FursafyTheme.secondaryFixed,
          const Color(0xFF653E00),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: FursafyTheme.labelStyle.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: textColor.withValues(alpha: 0.8),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    final bio =
        _userData?['bio'] ??
        'A leading opportunity provider committed to empowering youth through meaningful short-term opportunities and professional apprenticeships.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About ${_userData?['displayName'] ?? 'Company'}',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: FursafyTheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: FursafyTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: FursafyTheme.onSurface.withValues(alpha: 0.02),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: FursafyTheme.surfaceContainer),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bio,
                style: FursafyTheme.bodyStyle.copyWith(
                  fontSize: 14,
                  color: FursafyTheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: FursafyTheme.surfaceContainerHigh.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Stacked avatars
                    SizedBox(
                      width: 64,
                      height: 32,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: FursafyTheme.primaryFixedDim,
                                border: Border.all(
                                  color: FursafyTheme.surfaceContainerLowest,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: FursafyTheme.secondaryFixedDim,
                                border: Border.all(
                                  color: FursafyTheme.surfaceContainerLowest,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 32,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: FursafyTheme.tertiaryFixedDim,
                                border: Border.all(
                                  color: FursafyTheme.surfaceContainerLowest,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Trusted by 2k+ Youth',
                      style: FursafyTheme.labelStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: FursafyTheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivePostings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Postings',
              style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: FursafyTheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap: () => context.push(AppRoutes.myJobs),
              child: Text(
                'View All',
                style: FursafyTheme.bodyStyle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: FursafyTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_activeJobs.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: FursafyTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No active listings. Post your first job!',
                style: FursafyTheme.bodyStyle.copyWith(
                  color: FursafyTheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...List.generate(_activeJobs.length, (index) {
            return _buildJobCard(_activeJobs[index], context);
          }),
      ],
    );
  }

  Widget _buildJobCard(JobEntity job, BuildContext context) {
    final payStr = '${(job.payAmount / 1000).toStringAsFixed(0)}k TZS';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: FursafyTheme.onSurface.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circle
          Positioned(
            top: -32,
            right: -32,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FursafyTheme.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: FursafyTheme.headlineStyle.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: FursafyTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: FursafyTheme.primaryFixed,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                job.category.toUpperCase(),
                                style: FursafyTheme.labelStyle.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF00513A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              job.locationName ?? '',
                              style: FursafyTheme.labelStyle.copyWith(
                                fontSize: 12,
                                color: FursafyTheme.outline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.more_vert,
                      color: FursafyTheme.outline,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY RATE',
                        style: FursafyTheme.labelStyle.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: FursafyTheme.outlineVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: payStr,
                              style: FursafyTheme.headlineStyle.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: FursafyTheme.primary,
                              ),
                            ),
                            TextSpan(
                              text: '/day',
                              style: FursafyTheme.bodyStyle.copyWith(
                                fontSize: 12,
                                color: FursafyTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () =>
                        context.push('/provider/jobs/${job.id}/applicants'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: FursafyTheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.groups,
                            size: 16,
                            color: FursafyTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_applicantCounts[job.id] ?? 0} Applicants',
                            style: FursafyTheme.bodyStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: FursafyTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.push(AppRoutes.postJob),
            style: ElevatedButton.styleFrom(
              backgroundColor: FursafyTheme.primary,
              foregroundColor: FursafyTheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
            ),
            child: Text(
              'Post a Job',
              style: FursafyTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: const BoxDecoration(
            color: FursafyTheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 22),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              context.go(AppRoutes.login);
            },
          ),
        ),
      ],
    );
  }
}
