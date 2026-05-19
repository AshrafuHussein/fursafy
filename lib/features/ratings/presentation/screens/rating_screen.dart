import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/ratings/domain/entities/rating_entity.dart';

/// S19 — Rating Screen (Stitch editorial design).
class RatingScreen extends StatefulWidget {
  final String jobId;
  const RatingScreen({super.key, required this.jobId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _commentCtrl = TextEditingController();
  int _score = 4;
  bool _submitting = false;
  bool _loading = true;
  String _rateeName = '';
  String _rateeId = '';
  final Set<String> _selectedTraits = {'Timely Communication'};
  final _traits = [
    'Timely Communication', 'Quality of Work',
    'Professionalism', 'Problem Solving',
  ];

  @override
  void initState() {
    super.initState();
    _loadJobContext();
  }

  Future<void> _loadJobContext() async {
    try {
      final jobDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs).doc(widget.jobId).get();
      final data = jobDoc.data();
      if (data != null) {
        setState(() {
          _rateeName = data['providerName'] as String? ?? '';
          _rateeId = data['providerId'] as String? ?? '';
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    if (uid == null || _rateeId.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final comment = _commentCtrl.text.trim();
      final traitStr = _selectedTraits.isNotEmpty
          ? ' [${_selectedTraits.join(', ')}]' : '';
      final rating = RatingEntity(
        id: '',
        raterId: uid,
        raterName: userName,
        rateeId: _rateeId,
        jobId: widget.jobId,
        score: _score,
        comment: '$comment$traitStr',
        createdAt: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection(FirestorePaths.ratings).add(rating.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Review submitted!'),
        backgroundColor: FursafyTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context);
    } catch (e) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
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
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: FursafyTheme.secondaryFixed,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text('FEEDBACK LOOP', style: FursafyTheme.labelStyle.copyWith(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      letterSpacing: 2.0, color: FursafyTheme.onSecondaryFixed)),
                  ),
                  const SizedBox(height: 16),

                  // Hero Title
                  RichText(text: TextSpan(
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 36, fontWeight: FontWeight.w800,
                      color: FursafyTheme.onSurface, height: 1.2),
                    children: [
                      const TextSpan(text: 'Rate your '),
                      TextSpan(text: 'collaboration', style: TextStyle(
                        color: FursafyTheme.primary, fontStyle: FontStyle.italic)),
                      const TextSpan(text: '.'),
                    ],
                  )),
                  const SizedBox(height: 12),
                  Text('Your professional insights help our community grow stronger.',
                    style: FursafyTheme.bodyStyle.copyWith(
                      fontSize: 16, color: FursafyTheme.onSurfaceVariant, height: 1.5)),
                  const SizedBox(height: 32),

                  // Rating Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(children: [
                      // Ratee avatar
                      Transform.rotate(
                        angle: 0.05,
                        child: Container(
                          width: 96, height: 96,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: FursafyTheme.surfaceContainerHighest,
                            boxShadow: FursafyTheme.ambientShadow,
                          ),
                          child: Center(child: Text(
                            _rateeName.isNotEmpty ? _rateeName[0].toUpperCase() : '?',
                            style: FursafyTheme.headlineStyle.copyWith(
                              fontSize: 40, fontWeight: FontWeight.w800,
                              color: FursafyTheme.primary),
                          )),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(_rateeName, style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Opportunity Provider', style: FursafyTheme.bodyStyle.copyWith(
                        color: FursafyTheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 32),

                      // Stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) => GestureDetector(
                          onTap: () => setState(() => _score = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              i < _score ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 48,
                              color: i < _score
                                  ? FursafyTheme.secondaryContainer
                                  : FursafyTheme.surfaceContainerHighest,
                            ),
                          ),
                        )),
                      ),
                      const SizedBox(height: 32),

                      // Comment
                      Align(alignment: Alignment.centerLeft,
                        child: Text('SHARE YOUR EXPERIENCE',
                          style: FursafyTheme.labelStyle.copyWith(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: FursafyTheme.primary, letterSpacing: 1.5)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: FursafyTheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _commentCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                            hintText: 'How was your experience working with $_rateeName?',
                            hintStyle: FursafyTheme.bodyStyle.copyWith(
                              color: FursafyTheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          ),
                          style: FursafyTheme.bodyStyle.copyWith(
                            color: FursafyTheme.onSurface),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Trait Chips
                      Align(alignment: Alignment.centerLeft,
                        child: Text('What stood out the most?',
                          style: FursafyTheme.bodyStyle.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: FursafyTheme.onSurfaceVariant)),
                      ),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 8,
                        children: _traits.map((t) {
                          final sel = _selectedTraits.contains(t);
                          return GestureDetector(
                            onTap: () => setState(() {
                              sel ? _selectedTraits.remove(t) : _selectedTraits.add(t);
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? FursafyTheme.primaryFixed : FursafyTheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(t, style: FursafyTheme.labelStyle.copyWith(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: sel ? FursafyTheme.onPrimaryFixed : FursafyTheme.onSurfaceVariant,
                              )),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // Submit
                      SizedBox(width: double.infinity, height: 56,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FursafyTheme.primary,
                            foregroundColor: FursafyTheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          ),
                          child: _submitting
                              ? const SizedBox(width: 20, height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Text('Submit Review', style: FursafyTheme.bodyStyle.copyWith(
                                    fontWeight: FontWeight.w700, fontSize: 18)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 20),
                                ]),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Maybe Later', style: FursafyTheme.bodyStyle.copyWith(
                          color: FursafyTheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 32),

                  // Trust Banners
                  Row(children: [
                    Expanded(child: _trustBanner(
                      icon: Icons.verified_user,
                      iconColor: FursafyTheme.tertiary,
                      bg: FursafyTheme.tertiaryFixed.withValues(alpha: 0.3),
                      title: 'Verified Feedback',
                      desc: 'Reviews are processed securely for transparency.',
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _trustBanner(
                      icon: Icons.auto_awesome,
                      iconColor: FursafyTheme.secondary,
                      bg: FursafyTheme.secondaryFixed.withValues(alpha: 0.3),
                      title: 'Impact Score',
                      desc: 'Top reviewers gain Curator Status.',
                    )),
                  ]),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _trustBanner({required IconData icon, required Color iconColor,
      required Color bg, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 16),
          Text(title, style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(desc, style: FursafyTheme.bodyStyle.copyWith(
            fontSize: 13, color: FursafyTheme.onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }
}
