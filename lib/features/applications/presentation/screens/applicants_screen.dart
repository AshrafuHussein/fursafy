import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/applications/domain/entities/application_entity.dart';

/// S17 — Job Detail (Provider) + Applicants list — Stitch design.
class ApplicantsScreen extends StatefulWidget {
  final String jobId;
  const ApplicantsScreen({super.key, required this.jobId});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  Map<String, dynamic>? _job;
  List<ApplicationEntity> _applicants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final jobDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs).doc(widget.jobId).get();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final appSnap = await FirebaseFirestore.instance
          .collection(FirestorePaths.applications)
          .where('jobId', isEqualTo: widget.jobId)
          .where('providerId', isEqualTo: uid)
          .get();

      final applicants = appSnap.docs
          .map((d) => ApplicationEntity.fromMap(d.id, d.data())).toList();

      // Sort in-memory descending by appliedAt
      applicants.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

      setState(() {
        _job = jobDoc.data();
        _applicants = applicants;
        _loading = false;
      });
    } catch (e) {
      debugPrint('ApplicantsScreen._load error: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(ApplicationEntity app, ApplicationStatus status) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.applications).doc(app.id)
          .update({'status': status.name});

      debugPrint('[Applicants] Status updated to ${status.name} for app=${app.id}');
      debugPrint('[Applicants] Writing notification for youthId=${app.youthId}');

      // Write notification for the youth in user-specific sub-collection
      final notifPath = 'notifications/${app.youthId}/items';
      debugPrint('[Applicants] Notification path: $notifPath');

      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(app.youthId)
          .collection('items')
          .add({
        'type': status == ApplicationStatus.accepted ? 'application_accepted' : 'application_rejected',
        'title': status == ApplicationStatus.accepted ? 'Application Accepted' : 'Application Rejected',
        'message': status == ApplicationStatus.accepted
            ? 'Your application for ${app.jobTitle} has been accepted!'
            : 'Your application for ${app.jobTitle} was not selected.',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'jobId': app.jobId,
        'applicationId': app.id,
      });

      debugPrint('[Applicants] Notification written successfully!');

      setState(() {
        final i = _applicants.indexWhere((a) => a.id == app.id);
        if (i != -1) _applicants[i] = app.copyWith(status: status);
      });
    } catch (e, stack) {
      debugPrint('[Applicants] ERROR in _updateStatus: $e');
      debugPrint('[Applicants] Stack: $stack');
    }
  }

  void _showConfirmDialog(ApplicationEntity app, bool isAccept) {
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: FursafyTheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Icon
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: isAccept
                  ? FursafyTheme.primary.withValues(alpha: 0.1)
                  : FursafyTheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAccept ? Icons.check_circle : Icons.person_remove,
              color: isAccept ? FursafyTheme.primary : FursafyTheme.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(isAccept ? 'Accept Applicant?' : 'Reject Applicant?',
            style: FursafyTheme.headlineStyle.copyWith(
              fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(
            isAccept
                ? 'This will hire ${app.youthName} for the job. We\'ll notify them immediately.'
                : 'Are you sure? ${app.youthName} will be notified and removed from your active pool.',
            textAlign: TextAlign.center,
            style: FursafyTheme.bodyStyle.copyWith(
              color: FursafyTheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 24),
          // Confirm
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus(app,
                    isAccept ? ApplicationStatus.accepted : ApplicationStatus.rejected);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isAccept ? FursafyTheme.primary : FursafyTheme.error,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
              ),
              child: Text(isAccept ? 'Confirm' : 'Reject',
                style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
          // Cancel
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: FursafyTheme.bodyStyle.copyWith(
              color: isAccept ? FursafyTheme.onSurfaceVariant : FursafyTheme.primary,
              fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final title = _job?['title'] as String? ?? 'Job';
    final pay = _job?['payAmount'] as num? ?? 0;

    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: FursafyTheme.surface.withValues(alpha: 0.8),
        elevation: 0, scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FursafyTheme.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Fursafy', style: FursafyTheme.headlineStyle.copyWith(
          fontSize: 20, fontWeight: FontWeight.w900, color: FursafyTheme.primary)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: FursafyTheme.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: FursafyTheme.primary,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Editorial Job Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: FursafyTheme.secondaryFixed,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text('ACTIVE LISTING', style: FursafyTheme.labelStyle.copyWith(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      letterSpacing: 2.0, color: FursafyTheme.onSecondaryFixed)),
                  ).wrapAlign(Alignment.centerLeft),
                  const SizedBox(height: 16),
                  Text(title, style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 36, fontWeight: FontWeight.w800,
                    color: FursafyTheme.primary, height: 1.1)),
                  const SizedBox(height: 16),
                  // Meta
                  Wrap(spacing: 24, runSpacing: 8, children: [
                    _meta(Icons.payments, 'TZS ${pay.toStringAsFixed(0)}'),
                    _meta(Icons.location_on, _job?['locationName'] ?? 'Remote'),
                  ]),
                  const SizedBox(height: 24),

                  // Application count card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('APPLICATIONS', style: FursafyTheme.labelStyle.copyWith(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          letterSpacing: 2.0, color: FursafyTheme.outline)),
                        const SizedBox(height: 4),
                        Text('${_applicants.length}',
                            style: FursafyTheme.headlineStyle.copyWith(
                              fontSize: 32, fontWeight: FontWeight.w900,
                              color: FursafyTheme.primary)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: (_applicants.length / 20).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: FursafyTheme.surfaceContainerHigh,
                            color: FursafyTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Section: Recent Applicants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Applicants', style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                      Text('Filter by Rating', style: FursafyTheme.bodyStyle.copyWith(
                        fontSize: 14, fontWeight: FontWeight.w500, color: FursafyTheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Applicant Cards
                  if (_applicants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: Column(children: [
                        const Icon(Icons.people_outline, size: 48,
                            color: FursafyTheme.outlineVariant),
                        const SizedBox(height: 12),
                        Text('No applicants yet', style: FursafyTheme.bodyStyle.copyWith(
                          color: FursafyTheme.onSurfaceVariant)),
                      ])),
                    )
                  else
                    ...List.generate(_applicants.length, (i) =>
                        _applicantCard(_applicants[i])),
                  const SizedBox(height: 32),
                ],
              ),
            ),
      // Floating Edit Job button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/provider/jobs/${widget.jobId}/edit'),
        backgroundColor: FursafyTheme.secondary,
        foregroundColor: FursafyTheme.onSecondary,
        elevation: 8,
        icon: const Icon(Icons.edit),
        label: const Text('Edit Job', style: TextStyle(
          fontFamily: 'Manrope', fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  Widget _applicantCard(ApplicationEntity app) {
    final statusColor = app.status == ApplicationStatus.accepted
        ? FursafyTheme.primary
        : app.status == ApplicationStatus.rejected
            ? FursafyTheme.error
            : FursafyTheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => _showApplicantProfile(app),
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: FursafyTheme.ambientShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: FursafyTheme.surfaceContainerHigh,
              ),
              child: app.youthAvatarUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(app.youthAvatarUrl!, fit: BoxFit.cover))
                  : Center(child: Text(
                      app.youthName.isNotEmpty ? app.youthName[0].toUpperCase() : '?',
                      style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 28, fontWeight: FontWeight.w800,
                        color: FursafyTheme.primary),
                    )),
            ),
          ]),
          const SizedBox(width: 20),
          // Info
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(app.youthName,
                      style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 18, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis)),
                  if (app.status != ApplicationStatus.pending)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(app.status.name.toUpperCase(),
                          style: FursafyTheme.labelStyle.copyWith(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: statusColor, letterSpacing: 0.5)),
                    ),
                ],
              ),
              if (app.coverMessage != null && app.coverMessage!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(app.coverMessage!, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FursafyTheme.bodyStyle.copyWith(
                      fontSize: 14, color: FursafyTheme.onSurfaceVariant)),
              ],
              const SizedBox(height: 16),
              // Action Buttons
              if (app.status == ApplicationStatus.pending)
                Row(children: [
                  Expanded(child: SizedBox(height: 40,
                    child: ElevatedButton(
                      onPressed: () => _showConfirmDialog(app, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FursafyTheme.primary,
                        foregroundColor: FursafyTheme.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                      ),
                      child: const Text('Accept', style: TextStyle(
                        fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                    ),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: SizedBox(height: 40,
                    child: ElevatedButton(
                      onPressed: () => _showConfirmDialog(app, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FursafyTheme.surfaceContainerHigh,
                        foregroundColor: FursafyTheme.onSurfaceVariant,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                      ),
                      child: const Text('Reject', style: TextStyle(
                        fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14, color: FursafyTheme.onSurfaceVariant)),
                    ),
                  )),
                ])
              else if (app.status == ApplicationStatus.accepted)
                Row(children: [
                  Expanded(child: SizedBox(height: 40,
                    child: ElevatedButton(
                      onPressed: () => context.push('/provider/rate/${app.jobId}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FursafyTheme.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                      ),
                      child: const Text('Rate Worker', style: TextStyle(
                        fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                    ),
                  )),
                ]),
            ],
          )),
        ],
      ),
    ),
    );
  }

  void _showApplicantProfile(ApplicationEntity app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FursafyTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollCtrl) => FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection(FirestorePaths.youthProfiles)
              .doc(app.youthId).get(),
          builder: (ctx, snap) {
            final profileData = snap.data?.data() as Map<String, dynamic>?;
            final skills = List<String>.from(profileData?['skills'] ?? []);
            final bio = profileData?['bio'] as String? ?? '';
            final rating = (profileData?['ratingAvg'] as num?)?.toDouble() ?? 0.0;
            final jobsDone = (profileData?['jobsCompleted'] as num?)?.toInt() ?? 0;

            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(32),
              children: [
                // Handle
                Center(child: Container(width: 48, height: 6,
                  decoration: BoxDecoration(
                    color: FursafyTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(100)))),
                const SizedBox(height: 32),

                // Avatar + Name
                Center(child: Column(children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: FursafyTheme.surfaceContainerHigh),
                    child: app.youthAvatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.network(app.youthAvatarUrl!, fit: BoxFit.cover))
                        : Center(child: Text(
                            app.youthName.isNotEmpty ? app.youthName[0].toUpperCase() : '?',
                            style: FursafyTheme.headlineStyle.copyWith(
                              fontSize: 40, fontWeight: FontWeight.w800,
                              color: FursafyTheme.primary))),
                  ),
                  const SizedBox(height: 16),
                  Text(app.youthName, style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 24, fontWeight: FontWeight.w800)),
                  if (bio.isNotEmpty) ...[                    const SizedBox(height: 8),
                    Text(bio, textAlign: TextAlign.center,
                      style: FursafyTheme.bodyStyle.copyWith(
                        color: FursafyTheme.onSurfaceVariant, height: 1.5)),
                  ],
                ])),
                const SizedBox(height: 24),

                // Stats row
                Row(children: [
                  Expanded(child: _profileStat('Rating', rating > 0 ? rating.toStringAsFixed(1) : '—')),
                  Expanded(child: _profileStat('Jobs Done', '$jobsDone')),
                  Expanded(child: _profileStat('Skills', '${skills.length}')),
                ]),
                const SizedBox(height: 24),

                // Skills
                if (skills.isNotEmpty) ...[                  Text('SKILLS', style: FursafyTheme.labelStyle.copyWith(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    letterSpacing: 2.0, color: FursafyTheme.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8,
                    children: skills.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: FursafyTheme.primaryFixed,
                        borderRadius: BorderRadius.circular(100)),
                      child: Text(s, style: FursafyTheme.labelStyle.copyWith(
                        fontWeight: FontWeight.w700, fontSize: 13,
                        color: FursafyTheme.onPrimaryFixed)),
                    )).toList()),
                  const SizedBox(height: 24),
                ],

                // Cover message
                if (app.coverMessage != null && app.coverMessage!.isNotEmpty) ...[                  Text('COVER MESSAGE', style: FursafyTheme.labelStyle.copyWith(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    letterSpacing: 2.0, color: FursafyTheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16)),
                    child: Text(app.coverMessage!,
                      style: FursafyTheme.bodyStyle.copyWith(
                        color: FursafyTheme.onSurface, height: 1.6)),
                  ),
                  const SizedBox(height: 24),
                ],

                // Actions
                if (app.status == ApplicationStatus.pending) ...[                  SizedBox(height: 52, width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () { Navigator.pop(ctx); _showConfirmDialog(app, true); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FursafyTheme.primary,
                        foregroundColor: FursafyTheme.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100))),
                      child: const Text('Accept Applicant', style: TextStyle(
                        fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(height: 48, width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () { Navigator.pop(ctx); _showConfirmDialog(app, false); },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: FursafyTheme.error,
                        side: BorderSide(color: FursafyTheme.error.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100))),
                      child: const Text('Reject', style: TextStyle(
                        fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 16, color: FursafyTheme.error)),
                    ),
                  ),
                ] else if (app.status == ApplicationStatus.accepted) ...[
                  SizedBox(height: 52, width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () { Navigator.pop(ctx); context.push('/provider/rate/${app.jobId}'); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FursafyTheme.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100))),
                      child: const Text('Rate Worker', style: TextStyle(
                        fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _profileStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(value, style: FursafyTheme.headlineStyle.copyWith(
          fontSize: 22, fontWeight: FontWeight.w800, color: FursafyTheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: FursafyTheme.labelStyle.copyWith(
          fontSize: 11, color: FursafyTheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: FursafyTheme.primary),
      const SizedBox(width: 6),
      Text(text, style: FursafyTheme.bodyStyle.copyWith(
        color: FursafyTheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
    ],
  );
}

extension _WidgetX on Widget {
  Widget wrapAlign(Alignment alignment) =>
      Align(alignment: alignment, child: this);
}
