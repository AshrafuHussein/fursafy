import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';

/// S12b — Provider Profile screen (Stitch Generated).
class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  Map<String, dynamic>? _userData;
  List<JobEntity> _activeJobs = [];
  bool _loading = true;

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
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();
      
      final jobSnap = await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs)
          .where('providerId', isEqualTo: uid)
          .where('status', isEqualTo: 'open')
          .limit(3)
          .get();

      setState(() {
        _userData = userDoc.data();
        _activeJobs = jobSnap.docs
            .map((d) => JobEntity.fromMap(d.id, d.data()))
            .toList();
        _loading = false;
      });
    } catch (e) {
      print('ProviderProfileScreen._loadProfile error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FursafyTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, color: FursafyTheme.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: FursafyTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Editorial Header
                  Text(
                    'DIGITAL CURATOR',
                    style: FursafyTheme.labelStyle.copyWith(
                      color: FursafyTheme.secondary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: FursafyTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.business_rounded, size: 40, color: FursafyTheme.primary),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userData?['displayName'] ?? 'Global Logistics',
                              style: FursafyTheme.headlineStyle.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Verified Opportunity Provider',
                              style: FursafyTheme.bodyStyle.copyWith(
                                color: FursafyTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // About Section
                  _buildSectionHeader('About Company', FursafyTheme.primary),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _userData?['bio'] ?? 'Leading the way in efficient logistics and supply chain management across East Africa. We are committed to empowering local youth through sustainable employment.',
                      style: FursafyTheme.bodyStyle.copyWith(
                        height: 1.6,
                        color: FursafyTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stats Section
                  Row(
                    children: [
                      _buildStatBox('12', 'ACTIVE JOBS'),
                      const SizedBox(width: 12),
                      _buildStatBox('150+', 'HIRED'),
                      const SizedBox(width: 12),
                      _buildStatBox('4.9', 'RATING'),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Top Skills Section
                  _buildSectionHeader('Top Skills We Hire', FursafyTheme.secondary),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Driving', 'Warehouse Management', 'Customer Service', 'Data Entry']
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: FursafyTheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.1)),
                              ),
                              child: Text(
                                s,
                                style: FursafyTheme.labelStyle.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // Open Opportunities Section
                  _buildSectionHeader('Open Opportunities', FursafyTheme.tertiary),
                  const SizedBox(height: 16),
                  if (_activeJobs.isEmpty)
                    Text('No active listings.', style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant))
                  else
                    ..._activeJobs.map((job) => _buildMiniJobCard(job)),
                  
                  const SizedBox(height: 48),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.push(AppRoutes.postJob),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FursafyTheme.primary,
                            foregroundColor: FursafyTheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            elevation: 0,
                          ),
                          child: Text('Post a Job', style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: FursafyTheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                            icon: const Icon(Icons.logout, color: Colors.redAccent),
                            onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                if (!context.mounted) return;
                                context.go(AppRoutes.login);
                            },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: FursafyTheme.labelStyle.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1.5,
            color: FursafyTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FursafyTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: FursafyTheme.headlineStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: FursafyTheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: FursafyTheme.labelStyle.copyWith(fontSize: 8, fontWeight: FontWeight.w900, color: FursafyTheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniJobCard(JobEntity job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.work_outline, color: FursafyTheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              job.title,
              style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: FursafyTheme.outline),
        ],
      ),
    );
  }
}
