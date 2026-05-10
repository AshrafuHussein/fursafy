import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

/// S08 — Job Detail screen (Youth view).
/// Shows full job info, provider card, and Apply CTA.
class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  JobEntity? _job;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchJob();
  }

  Future<void> _fetchJob() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs)
          .doc(widget.jobId)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _job = JobEntity.fromMap(doc.id, doc.data()!);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _showApplySheet() {
    final coverController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: FursafyTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: FursafyTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Apply for this job',
              style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: FursafyTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell the provider why you\'re a great fit.',
              style: FursafyTheme.bodyStyle.copyWith(
                color: FursafyTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: coverController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write a short cover message...',
                  hintStyle: FursafyTheme.bodyStyle.copyWith(
                    color: FursafyTheme.outline,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showSuccessDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FursafyTheme.primary,
                  foregroundColor: FursafyTheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Submit Application',
                  style: FursafyTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: FursafyTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [FursafyTheme.primary, FursafyTheme.primaryContainer],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Application Sent!',
                style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: FursafyTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The provider will review your application and get back to you.',
                textAlign: TextAlign.center,
                style: FursafyTheme.bodyStyle.copyWith(
                  color: FursafyTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Got it',
                    style: FursafyTheme.bodyStyle.copyWith(
                      color: FursafyTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: FursafyTheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: FursafyTheme.primary),
        ),
      );
    }

    if (_job == null) {
      return Scaffold(
        backgroundColor: FursafyTheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: FursafyTheme.onSurface),
        ),
        body: Center(
          child: Text(
            'Job not found',
            style: FursafyTheme.headlineStyle.copyWith(
              color: FursafyTheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final job = _job!;

    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: FursafyTheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [FursafyTheme.primary, FursafyTheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            job.category,
                            style: FursafyTheme.labelStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.title,
                          style: FursafyTheme.headlineStyle.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Info Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoItem(Icons.payments_outlined,
                            '${job.payAmount.toStringAsFixed(0)} TZS', 'Pay'),
                        Container(
                          width: 1,
                          height: 32,
                          color: FursafyTheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                        _infoItem(
                            Icons.location_on_outlined,
                            job.locationName ?? 'TBD',
                            'Location'),
                        Container(
                          width: 1,
                          height: 32,
                          color: FursafyTheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                        _infoItem(Icons.access_time_outlined,
                            timeago.format(job.createdAt), 'Posted'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Description
                  Text(
                    'About this job',
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: FursafyTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    job.description,
                    style: FursafyTheme.bodyStyle.copyWith(
                      fontSize: 15,
                      color: FursafyTheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Skills Required
                  Text(
                    'Skills Required',
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: FursafyTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.skillsRequired.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: FursafyTheme.primaryFixed,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          skill,
                          style: FursafyTheme.labelStyle.copyWith(
                            color: FursafyTheme.onPrimaryFixed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Provider Card
                  Text(
                    'Posted by',
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: FursafyTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: FursafyTheme.ambientShadow,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: FursafyTheme.surfaceContainerHighest,
                          backgroundImage: job.providerAvatarUrl != null
                              ? NetworkImage(job.providerAvatarUrl!)
                              : null,
                          child: job.providerAvatarUrl == null
                              ? const Icon(Icons.business,
                                  color: FursafyTheme.onSurfaceVariant)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.providerName,
                                style: FursafyTheme.bodyStyle.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: FursafyTheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 14,
                                      color: FursafyTheme.secondaryContainer),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${job.providerRating.toStringAsFixed(1)} · ${job.providerJobsDone} jobs',
                                    style: FursafyTheme.labelStyle.copyWith(
                                      color: FursafyTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: FursafyTheme.outlineVariant),
                      ],
                    ),
                  ),

                  // Spacer for bottom button
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Apply CTA
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: FursafyTheme.surface,
          boxShadow: [
            BoxShadow(
              color: FursafyTheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _showApplySheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: FursafyTheme.primary,
              foregroundColor: FursafyTheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Apply Now',
                  style: FursafyTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: FursafyTheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: FursafyTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: FursafyTheme.onSurface,
          ),
        ),
        Text(
          label,
          style: FursafyTheme.labelStyle.copyWith(
            fontSize: 11,
            color: FursafyTheme.outline,
          ),
        ),
      ],
    );
  }
}
