import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

/// S08 — Job Detail screen (Youth view) — Stitch editorial design.
/// Flat appbar, trending badge, bento stats, provider card with verified badge,
/// location map preview, and sticky Apply + Bookmark bottom bar.
class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  JobEntity? _job;
  bool _loading = true;
  bool _bookmarked = false;

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

  // ─── Apply Bottom Sheet (Stitch design) ───
  void _showApplySheet() {
    final coverController = TextEditingController();
    final job = _job!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: FursafyTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(
            color: Color(0x1A000000), blurRadius: 40, offset: Offset(0, -10))],
        ),
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(child: Container(width: 48, height: 6,
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(100)))),
            const SizedBox(height: 24),

            // Title + subtitle
            Text('Apply for this role',
              style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 24, fontWeight: FontWeight.w700,
                letterSpacing: -0.3)),
            const SizedBox(height: 4),
            Text('Send a short message to the hiring manager.',
              style: FursafyTheme.bodyStyle.copyWith(
                fontSize: 14, color: FursafyTheme.onSurfaceVariant)),
            const SizedBox(height: 24),

            // Job summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: FursafyTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.work, color: FursafyTheme.onPrimaryContainer, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title, style: FursafyTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(job.providerName.toUpperCase(),
                      style: FursafyTheme.labelStyle.copyWith(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        letterSpacing: 1.2, color: FursafyTheme.onSurfaceVariant)),
                  ],
                )),
              ]),
            ),
            const SizedBox(height: 24),

            // Intro message label
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text('INTRO MESSAGE', style: FursafyTheme.labelStyle.copyWith(
                fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 2.0, color: FursafyTheme.onSurfaceVariant)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: coverController,
                maxLines: 4,
                style: FursafyTheme.bodyStyle.copyWith(
                  color: FursafyTheme.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tell them why you\'re a great fit...',
                  hintStyle: FursafyTheme.bodyStyle.copyWith(
                    color: FursafyTheme.outline.withValues(alpha: 0.6), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16)),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Application button
            SizedBox(width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(ctx); _showSuccessDialog(); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FursafyTheme.primary,
                  foregroundColor: FursafyTheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                  elevation: 4,
                  shadowColor: FursafyTheme.primary.withValues(alpha: 0.2)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Confirm Application',
                    style: FursafyTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(width: 8),
                  const Icon(Icons.send, size: 18),
                ]),
              ),
            ),
            const SizedBox(height: 8),

            // Cancel button
            SizedBox(width: double.infinity, height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  foregroundColor: FursafyTheme.onSurfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100))),
                child: Text('Cancel', style: FursafyTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600, color: FursafyTheme.onSurfaceVariant)),
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
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: FursafyTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Column(mainAxisSize: MainAxisSize.min, children: [
            // Green gradient accent strip
            Container(height: 8,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [FursafyTheme.primary, FursafyTheme.primaryContainer]))),

            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
              child: Column(children: [
                // Celebratory icon with pulse rings
                SizedBox(width: 100, height: 100,
                  child: Stack(alignment: Alignment.center, children: [
                    Container(width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FursafyTheme.primary.withValues(alpha: 0.05))),
                    Container(width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FursafyTheme.primary.withValues(alpha: 0.1))),
                    Container(width: 64, height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: FursafyTheme.primary),
                      child: const Icon(Icons.check_circle,
                        color: Colors.white, size: 36)),
                  ]),
                ),
                const SizedBox(height: 24),

                // Title
                Text('Application Sent!',
                  style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    letterSpacing: -0.3)),
                const SizedBox(height: 8),
                Text(
                  'Your professional journey starts here. We\'ve notified the team.',
                  textAlign: TextAlign.center,
                  style: FursafyTheme.bodyStyle.copyWith(
                    color: FursafyTheme.onSurfaceVariant, height: 1.5)),
                const SizedBox(height: 28),

                // View My Applications
                SizedBox(width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FursafyTheme.primary,
                      foregroundColor: FursafyTheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                      elevation: 0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('View My Applications',
                        style: FursafyTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ]),
                  ),
                ),
                const SizedBox(height: 8),

                // Return to Explore
                SizedBox(width: double.infinity, height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Return to Explore',
                      style: FursafyTheme.bodyStyle.copyWith(
                        color: FursafyTheme.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 16),

                // Social proof footer
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(
                      color: FursafyTheme.surfaceContainerHigh, width: 1))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    // Avatar stack
                    SizedBox(width: 56, height: 28,
                      child: Stack(children: [
                        Positioned(left: 0, child: CircleAvatar(radius: 14,
                          backgroundColor: FursafyTheme.surfaceContainerHigh,
                          child: const Icon(Icons.person, size: 14,
                            color: FursafyTheme.onSurfaceVariant))),
                        Positioned(left: 14, child: CircleAvatar(radius: 14,
                          backgroundColor: FursafyTheme.primaryFixed,
                          child: const Icon(Icons.person, size: 14,
                            color: FursafyTheme.primary))),
                        Positioned(left: 28, child: CircleAvatar(radius: 14,
                          backgroundColor: FursafyTheme.secondaryFixed,
                          child: const Icon(Icons.person, size: 14,
                            color: FursafyTheme.secondary))),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Text('JOIN 2.4K+ APPLICANTS',
                      style: FursafyTheme.labelStyle.copyWith(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        letterSpacing: 2.0, color: FursafyTheme.onSurfaceVariant)),
                  ]),
                ),
              ]),
            ),
          ]),
          // Close button
          Positioned(top: 16, right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FursafyTheme.surfaceContainerHigh.withValues(alpha: 0.5)),
                child: const Icon(Icons.close,
                  size: 18, color: FursafyTheme.outline)),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: FursafyTheme.surface,
        body: Center(child: CircularProgressIndicator(color: FursafyTheme.primary)));
    }
    if (_job == null) {
      return Scaffold(
        backgroundColor: FursafyTheme.surface,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
          leading: const BackButton(color: FursafyTheme.onSurface)),
        body: Center(child: Text('Job not found',
          style: FursafyTheme.headlineStyle.copyWith(
            color: FursafyTheme.onSurfaceVariant))));
    }

    final job = _job!;

    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      // ─── Flat AppBar (Stitch: glass surface, no elevation) ───
      appBar: AppBar(
        backgroundColor: FursafyTheme.surface.withValues(alpha: 0.8),
        elevation: 0, scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FursafyTheme.onSurface),
          onPressed: () => Navigator.pop(context)),
        title: Text('Fursafy', style: FursafyTheme.headlineStyle.copyWith(
          fontSize: 18, fontWeight: FontWeight.w900, color: FursafyTheme.primary)),
        actions: [
          Container(
            width: 32, height: 32,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: FursafyTheme.surfaceContainerHighest),
            child: const Icon(Icons.notifications_none,
              size: 18, color: FursafyTheme.onSurfaceVariant)),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        children: [
          // ─── Job Header ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title side
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trending badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: FursafyTheme.secondaryFixed,
                      borderRadius: BorderRadius.circular(100)),
                    child: Text('Trending Now', style: FursafyTheme.labelStyle.copyWith(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, color: FursafyTheme.onSecondaryFixed)),
                  ),
                  const SizedBox(height: 12),
                  Text(job.title, style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    height: 1.15, letterSpacing: -0.5)),
                ],
              )),
              const SizedBox(width: 16),
              // Icon card
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: FursafyTheme.onSurface.withValues(alpha: 0.04),
                    blurRadius: 12, offset: const Offset(0, 2))]),
                child: const Icon(Icons.design_services,
                  color: FursafyTheme.primary, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Skill Chips ───
          Wrap(spacing: 8, runSpacing: 8,
            children: [
              ...job.skillsRequired.take(3).map((s) => _chip(s,
                bg: FursafyTheme.primaryFixed, fg: FursafyTheme.onPrimaryFixed)),
              if (job.locationName != null)
                _chip(job.locationName!, bg: FursafyTheme.surfaceContainerHigh,
                  fg: FursafyTheme.onSurfaceVariant),
              _chip(timeago.format(job.createdAt),
                bg: FursafyTheme.surfaceContainerHigh,
                fg: FursafyTheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 20),

          // ─── Bento Meta Stats ───
          Row(children: [
            Expanded(child: _bentoStat('SALARY RANGE',
              '${job.payAmount.toStringAsFixed(0)} TZS /mo')),
            const SizedBox(width: 12),
            Expanded(child: _bentoStat('POSTED',
              timeago.format(job.createdAt))),
          ]),
          const SizedBox(height: 28),

          // ─── Provider Summary Card ───
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FursafyTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(
                color: FursafyTheme.onSurface.withValues(alpha: 0.02),
                blurRadius: 30, offset: const Offset(0, 8))]),
            child: Row(children: [
              // Provider avatar with verified badge
              Stack(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: FursafyTheme.surfaceContainerHighest),
                  child: job.providerAvatarUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(job.providerAvatarUrl!, fit: BoxFit.cover))
                      : Center(child: Text(
                          job.providerName.isNotEmpty
                              ? job.providerName[0].toUpperCase() : '?',
                          style: FursafyTheme.headlineStyle.copyWith(
                            fontSize: 24, fontWeight: FontWeight.w800,
                            color: FursafyTheme.primary))),
                ),
                Positioned(bottom: -2, right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: FursafyTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)),
                    child: const Icon(Icons.verified, size: 10, color: Colors.white))),
              ]),
              const SizedBox(width: 16),
              // Name + rating
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.providerName, style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star, size: 16, color: FursafyTheme.secondary),
                    const SizedBox(width: 4),
                    Text(job.providerRating.toStringAsFixed(1),
                      style: FursafyTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(' (${job.providerJobsDone} jobs)',
                      style: FursafyTheme.bodyStyle.copyWith(
                        color: FursafyTheme.onSurfaceVariant, fontSize: 13)),
                  ]),
                ],
              )),
              // Profile button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(100)),
                child: Text('Profile', style: FursafyTheme.labelStyle.copyWith(
                  fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ]),
          ),
          const SizedBox(height: 28),

          // ─── Job Description ───
          Text('Job Description', style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Text(job.description,
            style: FursafyTheme.bodyStyle.copyWith(
              color: FursafyTheme.onSurfaceVariant, height: 1.7, fontSize: 15)),
          const SizedBox(height: 28),

          // ─── Location Map Preview ───
          Text('Location', style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: FursafyTheme.surfaceContainerHighest),
            child: Stack(children: [
              // Placeholder map surface
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [
                      FursafyTheme.surfaceContainerHigh,
                      FursafyTheme.surfaceContainerHighest,
                    ]))),
              // Dark gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)])))),
              // Center pin
              Center(child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: FursafyTheme.primary, shape: BoxShape.circle),
                child: const Icon(Icons.location_on, color: Colors.white, size: 24))),
              // Bottom location label
              Positioned(bottom: 16, left: 16, right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(job.locationName ?? 'Location TBD',
                        style: FursafyTheme.bodyStyle.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    ]),
                  ],
                )),
            ]),
          ),
        ],
      ),

      // ─── Sticky Bottom: Bookmark + Apply ───
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: FursafyTheme.surface.withValues(alpha: 0.9)),
        child: Row(children: [
          // Bookmark button
          GestureDetector(
            onTap: () => setState(() => _bookmarked = !_bookmarked),
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: FursafyTheme.surfaceContainerHighest),
              child: Icon(
                _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _bookmarked ? FursafyTheme.primary : FursafyTheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 16),
          // Apply button
          Expanded(child: SizedBox(height: 56,
            child: ElevatedButton(
              onPressed: _showApplySheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: FursafyTheme.primary,
                foregroundColor: FursafyTheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: FursafyTheme.primary.withValues(alpha: 0.3)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Apply Now', style: FursafyTheme.headlineStyle.copyWith(
                  fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(width: 8),
                const Icon(Icons.bolt, size: 20),
              ]),
            ),
          )),
        ]),
      ),
    );
  }

  Widget _chip(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(text, style: FursafyTheme.labelStyle.copyWith(
        fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _bentoStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FursafyTheme.labelStyle.copyWith(
            fontSize: 10, fontWeight: FontWeight.w600,
            letterSpacing: 1.5, color: FursafyTheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text(value, style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
