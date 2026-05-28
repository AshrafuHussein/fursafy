import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/applications/domain/entities/application_entity.dart';
import 'package:go_router/go_router.dart';

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
  Map<String, bool> _appChecklist = {
    'reviewOffer': true,
    'backgroundCheck': false,
    'equipmentSetup': false,
  };

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
        _appChecklist = app.checklist ?? {
          'reviewOffer': true,
          'backgroundCheck': false,
          'equipmentSetup': false,
        };
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _toggleChecklistItem(String key) async {
    if (_app == null) return;
    final currentVal = _appChecklist[key] ?? false;
    final newVal = !currentVal;

    setState(() {
      _appChecklist[key] = newVal;
    });

    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.applications)
          .doc(_app!.id)
          .update({'checklist': _appChecklist});
    } catch (e) {
      setState(() {
        _appChecklist[key] = currentVal;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update checklist: $e')),
        );
      }
    }
  }

  Future<void> _confirmArrival() async {
    if (_app == null) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.applications)
          .doc(widget.applicationId)
          .update({'arrived': true});
      
      setState(() {
        _app = _app!.copyWith(arrived: true);
        _loading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Arrival confirmed! You can now rate the provider.'),
        backgroundColor: FursafyTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to confirm arrival: $e'),
      ));
    }
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
                        value: 'Oct 15, 2023')),
                    ]),
                    const SizedBox(height: 24),

                    // Provider Contact Card
                    _contactCard(),
                    const SizedBox(height: 24),

                    // Location & Office (Map Section)
                    _locationOffice(),
                    const SizedBox(height: 24),

                    // Next Steps
                    _nextSteps(),
                    const SizedBox(height: 120),
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
                  onPressed: _app!.arrived
                      ? () => context.push('/rate/${_app!.jobId}')
                      : _confirmArrival,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _app!.arrived ? FursafyTheme.secondary : FursafyTheme.primary,
                    foregroundColor: _app!.arrived ? FursafyTheme.onSecondary : FursafyTheme.onPrimary,
                    elevation: 8,
                    shadowColor: (_app!.arrived ? FursafyTheme.secondary : FursafyTheme.primary).withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100))),
                  child: Text(_app!.arrived ? 'Rate Provider' : 'Confirm Arrival for Onboarding',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700, fontSize: 16,
                      color: Colors.white)),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting chat...')),
                  );
                },
                icon: const Icon(Icons.chat, size: 18),
                label: const Text('Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FursafyTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  textStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100))),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling coordinator...')),
                  );
                },
                icon: const Icon(Icons.call, size: 18),
                label: const Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FursafyTheme.surfaceContainerHigh,
                  foregroundColor: FursafyTheme.onSurface,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  textStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100))),
              ),
            )),
          ]),
        ],
      ),
    );
  }

  Widget _locationOffice() {
    final locationName = _job?['locationName'] as String? ?? 'Arusha';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Location & Office',
              style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 20, fontWeight: FontWeight.w700)),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Full Map...')),
                );
              },
              icon: const Icon(Icons.open_in_new, size: 16, color: FursafyTheme.primary),
              label: Text('Full Map',
                style: FursafyTheme.bodyStyle.copyWith(
                  color: FursafyTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 192,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: FursafyTheme.surfaceContainerHighest,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Map Background Image
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDcOphAbOCDauBa3erj3-fXuSybsj0Pu7CJovpscNNclpgqAhOweKYVU0TIYdkV_tQYjiZL74i2HnwPH4coIaZT-tL9lHXzfLiY9EU5tUDr8ty5DClZjZjEy8gow83KY-eoHiAtFBoeN0Dei53ycT_t-NNDgRwapL-Yj9MW4QdGG5EkaIaJaOr36Sj-80XtymrZ8quT_DlawkGyXsgfH733NwT9vVB6p7O9vw_-IxDSwKK7wA_daEI9g85VywnGtsNC0AgN5XTAlUmV',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
                      ),
                    ),
                  ),
                ),
                // Pulse Center Pin
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FursafyTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: FursafyTheme.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                  ),
                ),
                // Bottom banner on map
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      // Address card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('GreenRoots Hub',
                                style: FursafyTheme.headlineStyle.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: FursafyTheme.primary)),
                              const SizedBox(height: 2),
                              Text('Plot 45, Nyerere Road, $locationName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FursafyTheme.bodyStyle.copyWith(
                                  fontSize: 10,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // View Directions Button
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Calculating Route...')),
                          );
                        },
                        icon: const Icon(Icons.directions, size: 16),
                        label: const Text('Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FursafyTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          textStyle: FursafyTheme.bodyStyle.copyWith(
                            fontSize: 11, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _nextSteps() {
    final steps = [
      {'key': 'reviewOffer', 'title': 'Review Offer Letter', 'desc': 'The document was sent to your email yesterday.'},
      {'key': 'backgroundCheck', 'title': 'Background Check Verification', 'desc': 'Upload your national ID via the portal.'},
      {'key': 'equipmentSetup', 'title': 'Equipment Setup', 'desc': 'Coordinate with Baraka for laptop pickup.'},
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
            final key = s['key'] as String;
            final done = _appChecklist[key] ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => _toggleChecklistItem(key),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
