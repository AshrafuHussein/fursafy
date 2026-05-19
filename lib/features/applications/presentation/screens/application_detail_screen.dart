import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/applications/domain/entities/application_entity.dart';

/// Application Detail — Accepted status view with provider contact,
/// salary info, and next steps checklist (Stitch design).
class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;
  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  ApplicationEntity? _app;
  Map<String, dynamic>? _job;
  Map<String, dynamic>? _provider;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final appDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.applications)
          .doc(widget.applicationId).get();
      if (!appDoc.exists) { setState(() => _loading = false); return; }

      final appData = appDoc.data()!;
      final app = ApplicationEntity.fromMap(appDoc.id, appData);

      final jobDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs).doc(app.jobId).get();

      final providerId = appData['providerId'] as String? ?? '';
      Map<String, dynamic>? providerData;
      if (providerId.isNotEmpty) {
        final provDoc = await FirebaseFirestore.instance
            .collection(FirestorePaths.users).doc(providerId).get();
        providerData = provDoc.data();
      }

      setState(() {
        _app = app;
        _job = jobDoc.data();
        _provider = providerData;
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: FursafyTheme.surface.withValues(alpha: 0.8),
        elevation: 0, scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FursafyTheme.onSurface),
          onPressed: () => Navigator.pop(context)),
        title: Text('Application Details',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 18, fontWeight: FontWeight.w700, color: FursafyTheme.primary)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: FursafyTheme.primary))
          : _app == null
              ? const Center(child: Text('Application not found'))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  children: [
                    // Status Badge
                    _statusBadge(),
                    const SizedBox(height: 16),

                    // Job Title
                    Text(_app!.jobTitle,
                      style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 32, fontWeight: FontWeight.w800,
                        height: 1.1)),
                    const SizedBox(height: 12),

                    // Provider row
                    Row(children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: FursafyTheme.surfaceContainerHigh),
                        child: Center(child: Text(
                          (_provider?['displayName'] as String?)?.isNotEmpty == true
                              ? (_provider!['displayName'] as String)[0].toUpperCase()
                              : '?',
                          style: FursafyTheme.headlineStyle.copyWith(
                            fontSize: 20, fontWeight: FontWeight.w800,
                            color: FursafyTheme.primary))),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_provider?['displayName'] ?? 'Provider',
                            style: FursafyTheme.headlineStyle.copyWith(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                          Text('${_job?['locationName'] ?? 'Remote'} • Full-time',
                            style: FursafyTheme.bodyStyle.copyWith(
                              fontSize: 13, color: FursafyTheme.onSurfaceVariant)),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Bento Stats
                    Row(children: [
                      Expanded(child: _statCard(
                        icon: Icons.payments, iconColor: FursafyTheme.secondary,
                        label: 'ESTIMATED SALARY',
                        value: 'TZS ${((_job?['payAmount'] as num?) ?? 0).toStringAsFixed(0)}')),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard(
                        icon: Icons.event_available, iconColor: FursafyTheme.primary,
                        label: 'STARTING DATE',
                        value: 'To be confirmed')),
                    ]),
                    const SizedBox(height: 24),

                    // Provider Contact Card
                    _contactCard(),
                    const SizedBox(height: 24),

                    // Next Steps
                    _nextSteps(),
                    const SizedBox(height: 100),
                  ],
                ),
      // Bottom CTA
      bottomNavigationBar: _app != null && _app!.status == ApplicationStatus.accepted
          ? Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [FursafyTheme.surface.withValues(alpha: 0), FursafyTheme.surface])),
              child: SizedBox(height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FursafyTheme.primary,
                    foregroundColor: FursafyTheme.onPrimary,
                    elevation: 8,
                    shadowColor: FursafyTheme.primary.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100))),
                  child: Text('Confirm Arrival for Onboarding',
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            )
          : null,
    );
  }

  Widget _statusBadge() {
    final isAccepted = _app!.status == ApplicationStatus.accepted;
    return Align(alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isAccepted
              ? FursafyTheme.primary.withValues(alpha: 0.1)
              : FursafyTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(100)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(isAccepted ? Icons.check_circle : Icons.pending,
            size: 18,
            color: isAccepted ? FursafyTheme.primary : FursafyTheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            _app!.status.name.toUpperCase(),
            style: FursafyTheme.labelStyle.copyWith(
              fontSize: 11, fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: isAccepted ? FursafyTheme.primary : FursafyTheme.onSurfaceVariant)),
        ]),
      ),
    );
  }

  Widget _statCard({required IconData icon, required Color iconColor,
      required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(label, style: FursafyTheme.labelStyle.copyWith(
            fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 1.5, color: FursafyTheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _contactCard() {
    final name = _provider?['displayName'] as String? ?? 'Provider';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: FursafyTheme.primary.withValues(alpha: 0.05),
          blurRadius: 24, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Point of Contact', style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Your assigned coordinator.',
                  style: FursafyTheme.bodyStyle.copyWith(
                    fontSize: 13, color: FursafyTheme.onSurfaceVariant)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: FursafyTheme.secondaryFixed,
                  borderRadius: BorderRadius.circular(100)),
                child: Text('VERIFIED', style: FursafyTheme.labelStyle.copyWith(
                  fontSize: 10, fontWeight: FontWeight.w900,
                  color: FursafyTheme.onSecondaryFixed)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Provider info row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FursafyTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Stack(children: [
                CircleAvatar(radius: 24,
                  backgroundColor: FursafyTheme.surfaceContainerHigh,
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 20, fontWeight: FontWeight.w800,
                      color: FursafyTheme.primary))),
                Positioned(bottom: 0, right: 0,
                  child: Container(width: 14, height: 14,
                    decoration: BoxDecoration(
                      color: FursafyTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: FursafyTheme.surface, width: 2)))),
              ]),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 16, fontWeight: FontWeight.w700)),
                Text(_provider?['phone'] as String? ?? 'Operations Lead',
                  style: FursafyTheme.bodyStyle.copyWith(
                    fontSize: 13, color: FursafyTheme.onSurfaceVariant)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(children: [
            Expanded(child: SizedBox(height: 48,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat, size: 18),
                label: Text('Message', style: FursafyTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FursafyTheme.primary,
                  foregroundColor: FursafyTheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100))),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 48,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call, size: 18),
                label: Text('Call', style: FursafyTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FursafyTheme.surfaceContainerHigh,
                  foregroundColor: FursafyTheme.onSurface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100))),
              ),
            )),
          ]),
        ],
      ),
    );
  }

  Widget _nextSteps() {
    final steps = [
      {'title': 'Review Offer Letter', 'desc': 'Check your email for the document.', 'done': true},
      {'title': 'Background Check', 'desc': 'Upload your national ID via the portal.', 'done': false},
      {'title': 'Equipment Setup', 'desc': 'Coordinate with the provider for pickup.', 'done': false},
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Next Steps', style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          ...steps.map((s) {
            final done = s['done'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done ? FursafyTheme.primary : FursafyTheme.outlineVariant,
                        width: 2)),
                    child: done
                        ? const Icon(Icons.check, size: 14, color: FursafyTheme.primary)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Opacity(
                    opacity: done ? 1.0 : 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['title'] as String,
                          style: FursafyTheme.bodyStyle.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(s['desc'] as String,
                          style: FursafyTheme.bodyStyle.copyWith(
                            fontSize: 12, color: FursafyTheme.onSurfaceVariant)),
                      ],
                    ),
                  )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
