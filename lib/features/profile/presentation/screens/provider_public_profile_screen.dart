import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:fursafy/features/ratings/domain/entities/rating_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Provider Public Profile screen — Viewed by youth from job details or application details.
class ProviderPublicProfileScreen extends StatefulWidget {
  final String uid;
  const ProviderPublicProfileScreen({super.key, required this.uid});

  @override
  State<ProviderPublicProfileScreen> createState() => _ProviderPublicProfileScreenState();
}

class _ProviderPublicProfileScreenState extends State<ProviderPublicProfileScreen> {
  Map<String, dynamic>? _userData;
  List<JobEntity> _activeJobs = [];
  List<RatingEntity> _reviews = [];
  bool _loading = true;
  int _totalJobsPosted = 0;
  int _trustedYouthCount = 0;
  double _ratingAvg = 0.0;
  int _ratingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final db = FirebaseFirestore.instance;

      // 1. Fetch user doc
      final userDoc = await db.collection(FirestorePaths.users).doc(widget.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _userData = data;
          _ratingAvg = (data?['ratingAvg'] ?? data?['averageRating'] ?? 0.0) as double;
          _ratingCount = (data?['ratingCount'] ?? data?['totalRatings'] ?? 0) as int;
        });
      }

      // 2. Fetch active postings
      final activeJobSnap = await db
          .collection(FirestorePaths.jobs)
          .where('providerId', isEqualTo: widget.uid)
          .where('status', isEqualTo: 'open')
          .get();
      
      final totalJobSnap = await db
          .collection(FirestorePaths.jobs)
          .where('providerId', isEqualTo: widget.uid)
          .get();

      final jobs = activeJobSnap.docs
          .map((d) => JobEntity.fromMap(d.id, d.data()))
          .toList();

      // 3. Fetch unique youth applicant counts (trusted count)
      final uniqueYouthSnap = await db
          .collection(FirestorePaths.applications)
          .where('providerId', isEqualTo: widget.uid)
          .get();
      final uniqueYouthCount = uniqueYouthSnap.docs
          .map((d) => d.data()['youthId'] as String?)
          .where((id) => id != null)
          .toSet()
          .length;

      // 4. Fetch ratings/reviews
      final ratingsSnap = await db
          .collection(FirestorePaths.ratings)
          .where('rateeId', isEqualTo: widget.uid)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      final reviews = ratingsSnap.docs
          .map((d) => RatingEntity.fromMap(d.id, d.data()))
          .toList();

      setState(() {
        _activeJobs = jobs;
        _totalJobsPosted = totalJobSnap.docs.length;
        _trustedYouthCount = uniqueYouthCount;
        _reviews = reviews;
        _loading = false;
      });
    } catch (e) {
      debugPrint('ProviderPublicProfileScreen._loadProfile error: $e');
      setState(() => _loading = false);
    }
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

    if (_userData == null) {
      return Scaffold(
        backgroundColor: FursafyTheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: FursafyTheme.onSurface),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.business_sharp, size: 64, color: FursafyTheme.outline),
              const SizedBox(height: 16),
              Text(
                'Provider profile not found',
                style: FursafyTheme.headlineStyle.copyWith(
                  color: FursafyTheme.onSurfaceVariant,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: FursafyTheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FursafyTheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Provider Profile',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Hero
            _buildCoverHero(context),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: _buildStatsRow(),
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

            // Reviews Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildReviewsSection(),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverHero(BuildContext context) {
    final name = _userData?['displayName'] ?? 'No Name Provided';
    final avatarUrl = _userData?['avatarUrl'] as String?;
    final industry = _userData?['industry'] as String? ?? 'Opportunity Provider';
    final location = _userData?['locationName'] ?? 'No location specified';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              color: FursafyTheme.primaryContainer,
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? Opacity(
                      opacity: 0.8,
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: FursafyTheme.primaryContainer),
                        errorWidget: (context, url, error) => Container(color: FursafyTheme.primaryContainer),
                      ),
                    )
                  : null,
            ),
            // Profile logo overlapping cover
            Positioned(
              left: 24,
              bottom: -40,
              child: Container(
                width: 80,
                height: 80,
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
                            child: CircularProgressIndicator(strokeWidth: 2, color: FursafyTheme.primary),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.business,
                            size: 32,
                            color: FursafyTheme.primary,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.business,
                        size: 32,
                        color: FursafyTheme.primary,
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
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
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: FursafyTheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.verified,
                    color: FursafyTheme.primary,
                    size: 20,
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

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('⭐', _ratingAvg.toStringAsFixed(1), 'Rating ($_ratingCount)'),
          Container(width: 1, height: 40, color: FursafyTheme.outlineVariant),
          _buildStatItem('💼', '$_totalJobsPosted', 'Jobs Posted'),
          Container(width: 1, height: 40, color: FursafyTheme.outlineVariant),
          _buildStatItem('🤝', '$_trustedYouthCount', 'Trusted Youth'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: FursafyTheme.headlineStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: FursafyTheme.labelStyle.copyWith(
              color: FursafyTheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final bio = _userData?['bio'] ?? 'No bio added yet.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Company',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: FursafyTheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: FursafyTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FursafyTheme.surfaceContainer),
          ),
          child: Text(
            bio,
            style: FursafyTheme.bodyStyle.copyWith(
              fontSize: 14,
              color: FursafyTheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivePostings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Postings',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: FursafyTheme.onSurface,
          ),
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
                'No active job listings currently.',
                style: FursafyTheme.bodyStyle.copyWith(
                  color: FursafyTheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ..._activeJobs.map((job) => _buildJobCard(job, context)),
      ],
    );
  }

  Widget _buildJobCard(JobEntity job, BuildContext context) {
    final payStr = '${(job.payAmount / 1000).toStringAsFixed(0)}k TZS';

    return GestureDetector(
      onTap: () => context.push('/jobs/${job.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FursafyTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: FursafyTheme.onSurface.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: FursafyTheme.surfaceContainer),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: FursafyTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  payStr,
                  style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: FursafyTheme.primary,
                  ),
                ),
                Text(
                  '/day',
                  style: FursafyTheme.bodyStyle.copyWith(
                    fontSize: 11,
                    color: FursafyTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews (${_reviews.length})',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: FursafyTheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        if (_reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: FursafyTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No reviews yet',
                style: FursafyTheme.bodyStyle.copyWith(
                  color: FursafyTheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ..._reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(RatingEntity review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FursafyTheme.surfaceContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: FursafyTheme.surfaceContainerHighest,
                backgroundImage: review.raterAvatarUrl != null && review.raterAvatarUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(review.raterAvatarUrl!)
                    : null,
                child: review.raterAvatarUrl == null || review.raterAvatarUrl!.isEmpty
                    ? const Icon(Icons.person, size: 18, color: FursafyTheme.outline)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.raterName,
                      style: FursafyTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < review.score ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 16,
                          color: i < review.score ? FursafyTheme.secondary : FursafyTheme.outlineVariant,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: FursafyTheme.bodyStyle.copyWith(
                color: FursafyTheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
