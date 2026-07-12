import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/ratings/data/repositories/rating_repository_impl.dart';

/// Rating Screen — Provider rates Youth after job completion (Stitch design).
class ProviderRatingScreen extends StatefulWidget {
  final String jobId;
  const ProviderRatingScreen({super.key, required this.jobId});

  @override
  State<ProviderRatingScreen> createState() => _ProviderRatingScreenState();
}

class _ProviderRatingScreenState extends State<ProviderRatingScreen> {
  final _commentCtrl = TextEditingController();
  int _score = 4;
  bool _submitting = false;
  bool _loading = true;
  String _youthName = '';
  String _youthId = '';
  String _jobTitle = '';
  final Set<String> _selectedTraits = {'Communicative'};
  final _traits = ['Reliable', 'Communicative', 'High Quality', 'Punctual'];
  final _ratingLabels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Very Good!',
    'Excellent!',
  ];

  @override
  void initState() {
    super.initState();
    _loadContext();
  }

  Future<void> _loadContext() async {
    try {
      final jobDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs)
          .doc(widget.jobId)
          .get();
      final data = jobDoc.data();
      if (data == null) {
        setState(() => _loading = false);
        return;
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      // Find the accepted applicant for this job
      final appSnap = await FirebaseFirestore.instance
          .collection(FirestorePaths.applications)
          .where('jobId', isEqualTo: widget.jobId)
          .where('status', whereIn: const ['accepted', 'completed'])
          .where('providerId', isEqualTo: uid)
          .limit(1)
          .get();

      if (appSnap.docs.isNotEmpty) {
        final appData = appSnap.docs.first.data();
        _youthName = appData['youthName'] as String? ?? '';
        _youthId = appData['youthId'] as String? ?? '';
      }
      _jobTitle = data['title'] as String? ?? '';
      setState(() => _loading = false);
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    if (uid == null || _youthId.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final traitStr = _selectedTraits.isNotEmpty
          ? ' [${_selectedTraits.join(', ')}]'
          : '';
      final comment = '${_commentCtrl.text.trim()}$traitStr';
      final repo = RatingRepositoryImpl();
      final res = await repo.submitRating(
        raterId: uid,
        raterName: userName,
        rateeId: _youthId,
        jobId: widget.jobId,
        score: _score,
        comment: comment,
      );

      if (res.failure != null) {
        throw Exception(res.failure!.message);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Review submitted!'),
          backgroundColor: FursafyTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: FursafyTheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: FursafyTheme.onSurfaceVariant,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Fursafy',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: FursafyTheme.primary,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FursafyTheme.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Job context card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: FursafyTheme.surfaceContainerHigh,
                          ),
                          child: Center(
                            child: Text(
                              _youthName.isNotEmpty
                                  ? _youthName[0].toUpperCase()
                                  : '?',
                              style: FursafyTheme.headlineStyle.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: FursafyTheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COMPLETED PROJECT',
                                style: FursafyTheme.labelStyle.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: FursafyTheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rate $_youthName\'s Performance',
                                style: FursafyTheme.headlineStyle.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                _jobTitle,
                                style: FursafyTheme.bodyStyle.copyWith(
                                  fontSize: 13,
                                  color: FursafyTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Rating section
                  Text(
                    'Overall Experience',
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the stars to rate your experience with $_youthName',
                    style: FursafyTheme.bodyStyle.copyWith(
                      color: FursafyTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => GestureDetector(
                        onTap: () => setState(() => _score = i + 1),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(
                            i < _score
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 48,
                            color: i < _score
                                ? FursafyTheme.secondary
                                : FursafyTheme.outlineVariant.withValues(
                                    alpha: 0.4,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Rating label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: FursafyTheme.secondaryFixed,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      _ratingLabels[_score],
                      style: FursafyTheme.labelStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: FursafyTheme.onSecondaryFixed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Comment
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'How was $_youthName\'s performance on this job?',
                      style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _commentCtrl,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        hintText:
                            'Share details about the work quality, communication, and timeliness...',
                        hintStyle: FursafyTheme.bodyStyle.copyWith(
                          color: FursafyTheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 14,
                        ),
                      ),
                      style: FursafyTheme.bodyStyle.copyWith(
                        color: FursafyTheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Trait chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _traits.map((t) {
                      final sel = _selectedTraits.contains(t);
                      return GestureDetector(
                        onTap: () => setState(() {
                          sel
                              ? _selectedTraits.remove(t)
                              : _selectedTraits.add(t);
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? FursafyTheme.primary
                                : FursafyTheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            t,
                            style: FursafyTheme.bodyStyle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: sel
                                  ? FursafyTheme.onPrimary
                                  : FursafyTheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FursafyTheme.primary,
                        foregroundColor: FursafyTheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Submit Review',
                                  style: FursafyTheme.headlineStyle.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your review will be public on $_youthName\'s profile',
                    style: FursafyTheme.labelStyle.copyWith(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: FursafyTheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }
}
