import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

/// S18 — My Jobs Screen (Provider) — Stitch editorial design.
class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  List<JobEntity> _jobs = [];
  bool _loading = true;
  int _activeTab = 0; // 0=Active, 1=Filled, 2=Closed
  final _tabs = ['Active', 'Filled', 'Closed'];
  // Applicant counts per job
  final Map<String, int> _applicantCounts = {};

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }
    try {
      final snap = await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs)
          .where('providerId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();
      final jobs = snap.docs.map((d) => JobEntity.fromMap(d.id, d.data())).toList();

      // Fetch applicant counts
      for (final job in jobs) {
        final countSnap = await FirebaseFirestore.instance
            .collection(FirestorePaths.applications)
            .where('jobId', isEqualTo: job.id)
            .count()
            .get();
        _applicantCounts[job.id] = countSnap.count ?? 0;
      }

      setState(() { _jobs = jobs; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  List<JobEntity> get _filtered {
    final statusStr = _activeTab == 0 ? 'open' : _activeTab == 1 ? 'closed' : 'closed';
    return _jobs.where((j) => j.status.name == statusStr).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: FursafyTheme.primary))
            : CustomScrollView(
                slivers: [
                  // Editorial Header
                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Jobs', style: FursafyTheme.headlineStyle.copyWith(
                          fontSize: 36, fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                        const SizedBox(height: 8),
                        Text(
                          'Managing your active opportunities and growing the future of Tanzania.',
                          style: FursafyTheme.bodyStyle.copyWith(
                            color: FursafyTheme.onSurfaceVariant, height: 1.5),
                        ),
                      ],
                    ),
                  )),

                  // Tabs
                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Row(children: List.generate(_tabs.length, (i) {
                      final active = i == _activeTab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                           onTap: () => setState(() => _activeTab = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: active ? FursafyTheme.primary : FursafyTheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: active ? [BoxShadow(
                                color: FursafyTheme.primary.withValues(alpha: 0.2),
                                blurRadius: 12, offset: const Offset(0, 4),
                              )] : null,
                            ),
                            child: Text(_tabs[i], style: FursafyTheme.bodyStyle.copyWith(
                              color: active ? FursafyTheme.onPrimary : FursafyTheme.onSurfaceVariant,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 14,
                            )),
                          ),
                        ),
                      );
                    })),
                  )),

                  // Job Cards
                  if (_filtered.isEmpty)
                    SliverFillRemaining(child: Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.work_off_outlined, size: 56,
                            color: FursafyTheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text('No ${_tabs[_activeTab].toLowerCase()} jobs',
                            style: FursafyTheme.headlineStyle.copyWith(
                              fontSize: 18, color: FursafyTheme.onSurfaceVariant)),
                      ],
                    )))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 200,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _jobCard(_filtered[i]),
                          childCount: _filtered.length,
                        ),
                      ),
                    ),

                  // Post New Job Card
                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: _postNewCard(),
                  )),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
              _buildNavItem(Icons.home_max, 'HOME', false, onTap: () => context.go(AppRoutes.providerDashboard)),
              _buildNavItem(Icons.work, 'WORK', true),
              _buildNavItem(Icons.add_circle_outline, 'ADD', false, onTap: () => context.push(AppRoutes.postJob)),
              _buildNavItem(Icons.mail_outline, 'INBOX', false, onTap: () => context.go(AppRoutes.notifications)),
              _buildNavItem(Icons.person_outline, 'PROFILE', false, onTap: () => context.go(AppRoutes.profile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? FursafyTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
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

  Widget _jobCard(JobEntity job) {
    final count = _applicantCounts[job.id] ?? 0;
    final isClosed = job.status == JobStatus.closed;

    return GestureDetector(
      onTap: () => context.push('/provider/jobs/${job.id}/applicants'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isClosed
              ? FursafyTheme.surfaceContainerLow.withValues(alpha: 0.5)
              : FursafyTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isClosed ? null : FursafyTheme.ambientShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: badge + applicant avatars
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isClosed
                        ? FursafyTheme.surfaceContainerHighest
                        : FursafyTheme.primaryFixed,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    isClosed ? 'CLOSED' : 'ACTIVE',
                    style: FursafyTheme.labelStyle.copyWith(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: isClosed ? FursafyTheme.onSurfaceVariant : FursafyTheme.onPrimaryFixed,
                    ),
                  ),
                ),
                if (count > 0) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: FursafyTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('+$count',
                      style: FursafyTheme.labelStyle.copyWith(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: FursafyTheme.onPrimaryContainer)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(job.title, style: FursafyTheme.headlineStyle.copyWith(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: isClosed
                  ? FursafyTheme.onSurface.withValues(alpha: 0.6)
                  : FursafyTheme.onSurface,
            )),
            const SizedBox(height: 8),

            // Meta row
            Row(children: [
              Icon(Icons.location_on_outlined, size: 16,
                  color: FursafyTheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(job.locationName ?? 'Remote',
                  style: FursafyTheme.labelStyle.copyWith(
                    fontSize: 13, color: FursafyTheme.onSurfaceVariant)),
              const SizedBox(width: 16),
              Icon(Icons.group_outlined, size: 16,
                  color: FursafyTheme.primary),
              const SizedBox(width: 4),
              Text('$count Applicants',
                  style: FursafyTheme.labelStyle.copyWith(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: FursafyTheme.primary)),
            ]),
            const Spacer(),

            // Progress bar
            if (!isClosed) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: count > 0 ? (count / 40).clamp(0.0, 1.0) : 0.05,
                  minHeight: 6,
                  backgroundColor: FursafyTheme.surfaceContainer,
                  color: FursafyTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Posted ${timeago.format(job.createdAt)}',
                      style: FursafyTheme.labelStyle.copyWith(
                        fontSize: 10, color: FursafyTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500, letterSpacing: -0.2)),
                  Text('${((count / 40) * 100).clamp(0, 100).toInt()}% Reach',
                      style: FursafyTheme.labelStyle.copyWith(
                        fontSize: 10, color: FursafyTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500, letterSpacing: -0.2)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _postNewCard() {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.postJob),
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: FursafyTheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: FursafyTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20, offset: const Offset(0, 8),
          )],
        ),
        child: Stack(
          children: [
            // Decorative bg icon
            Positioned(top: -16, right: -16,
              child: Icon(Icons.add_circle, size: 140,
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(Icons.add, color: FursafyTheme.onPrimary),
                ),
                const SizedBox(height: 16),
                Text('Post a new\nOpportunity',
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 24, fontWeight: FontWeight.w900,
                      color: FursafyTheme.onPrimary, height: 1.2)),
                const SizedBox(height: 8),
                Text('CONNECT WITH LOCAL TALENT',
                    style: FursafyTheme.labelStyle.copyWith(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: FursafyTheme.primaryFixed,
                      letterSpacing: 2.0)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
