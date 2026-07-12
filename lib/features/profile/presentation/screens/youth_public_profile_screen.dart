import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/auth/domain/entities/user_entity.dart';
import 'package:fursafy/features/ratings/domain/entities/rating_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// S18 — Youth Public Profile screen. Viewed by providers from applicant list.
class YouthPublicProfileScreen extends StatefulWidget {
  final String uid;
  const YouthPublicProfileScreen({super.key, required this.uid});

  @override
  State<YouthPublicProfileScreen> createState() =>
      _YouthPublicProfileScreenState();
}

class _YouthPublicProfileScreenState extends State<YouthPublicProfileScreen> {
  bool _loading = true;
  UserEntity? _user;
  YouthProfile? _youthProfile;
  List<RatingEntity> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final db = FirebaseFirestore.instance;

      // Load user + youth profile + ratings + real completed count in parallel
      final results = await Future.wait([
        db.collection(FirestorePaths.users).doc(widget.uid).get(),
        db.collection(FirestorePaths.youthProfiles).doc(widget.uid).get(),
        db
            .collection(FirestorePaths.ratings)
            .where('rateeId', isEqualTo: widget.uid)
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get(),
        db
            .collection(FirestorePaths.applications)
            .where('youthId', isEqualTo: widget.uid)
            .where('status', isEqualTo: 'accepted')
            .count()
            .get(),
      ]);

      final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final profileDoc = results[1] as DocumentSnapshot<Map<String, dynamic>>;
      final ratingsSnap = results[2] as QuerySnapshot<Map<String, dynamic>>;
      final completedSnap = results[3] as AggregateQuerySnapshot;
      final realCompletedCount = completedSnap.count ?? 0;

      if (!mounted) return;

      setState(() {
        if (userDoc.exists && userDoc.data() != null) {
          _user = UserEntity.fromMap(userDoc.data()!);
        }
        if (profileDoc.exists && profileDoc.data() != null) {
          final data = profileDoc.data()!;
          data['uid'] = widget.uid;
          data['jobsCompleted'] = realCompletedCount;
          data['completedJobsCount'] = realCompletedCount;
          _youthProfile = YouthProfile.fromMap(data);
        } else {
          _youthProfile = YouthProfile(
            uid: widget.uid,
            jobsCompleted: realCompletedCount,
          );
        }
        _reviews = ratingsSnap.docs
            .map((d) => RatingEntity.fromMap(d.id, d.data()))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: FursafyTheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Worker Profile',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FursafyTheme.primary))
          : _user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_off_rounded,
                          size: 64, color: FursafyTheme.outline),
                      const SizedBox(height: 16),
                      Text('Profile not found',
                          style: FursafyTheme.bodyStyle
                              .copyWith(color: FursafyTheme.onSurfaceVariant)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar + Name
                      _buildHeader(),
                      const SizedBox(height: 32),

                      // Stats Row
                      _buildStatsRow(),
                      const SizedBox(height: 24),

                      // Bio
                      if (_youthProfile?.bio != null &&
                          _youthProfile!.bio!.isNotEmpty)
                        _buildSection('About', _buildBio()),

                      // Skills
                      if (_youthProfile != null &&
                          _youthProfile!.skills.isNotEmpty)
                        _buildSection('Skills', _buildSkillChips()),

                      // Reviews
                      _buildSection(
                        'Reviews (${_reviews.length})',
                        _buildReviews(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: FursafyTheme.primaryFixed.withValues(alpha: 0.3),
              width: 4,
            ),
          ),
          child: CircleAvatar(
            radius: 46,
            backgroundColor: FursafyTheme.surfaceContainerHighest,
            backgroundImage: _user?.avatarUrl != null &&
                    _user!.avatarUrl!.isNotEmpty
                ? CachedNetworkImageProvider(_user!.avatarUrl!)
                : null,
            child: _user?.avatarUrl == null || _user!.avatarUrl!.isEmpty
                ? const Icon(Icons.person, size: 48, color: FursafyTheme.outline)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _user?.displayName ?? 'Unknown',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        if (_user?.locationName != null && _user!.locationName!.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 16, color: FursafyTheme.primary),
              const SizedBox(width: 4),
              Text(
                _user!.locationName!,
                style: FursafyTheme.bodyStyle.copyWith(
                  color: FursafyTheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final rating = _youthProfile?.ratingAvg ?? 0.0;
    final jobs = _youthProfile?.jobsCompleted ?? 0;
    final reviewCount = _youthProfile?.ratingCount ?? _reviews.length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('⭐', rating.toStringAsFixed(1), 'Rating'),
          Container(width: 1, height: 40, color: FursafyTheme.outlineVariant),
          _statItem('✅', '$jobs', 'Jobs Done'),
          Container(width: 1, height: 40, color: FursafyTheme.outlineVariant),
          _statItem('💬', '$reviewCount', 'Reviews'),
        ],
      ),
    );
  }

  Widget _statItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: FursafyTheme.labelStyle.copyWith(
            color: FursafyTheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: FursafyTheme.labelStyle.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: FursafyTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildBio() {
    return Text(
      _youthProfile!.bio!,
      style: FursafyTheme.bodyStyle.copyWith(
        color: FursafyTheme.onSurface,
        height: 1.6,
      ),
    );
  }

  Widget _buildSkillChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _youthProfile!.skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: FursafyTheme.primaryFixed.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: FursafyTheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            skill,
            style: FursafyTheme.bodyStyle.copyWith(
              color: FursafyTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviews() {
    if (_reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: FursafyTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No reviews yet',
            style: FursafyTheme.bodyStyle.copyWith(
              color: FursafyTheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: _reviews.map((review) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FursafyTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Rater avatar
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: FursafyTheme.surfaceContainerHighest,
                    backgroundImage: review.raterAvatarUrl != null &&
                            review.raterAvatarUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(review.raterAvatarUrl!)
                        : null,
                    child: review.raterAvatarUrl == null ||
                            review.raterAvatarUrl!.isEmpty
                        ? const Icon(Icons.person,
                            size: 18, color: FursafyTheme.outline)
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
                              i < review.score
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 16,
                              color: i < review.score
                                  ? FursafyTheme.secondaryContainer
                                  : FursafyTheme.outlineVariant,
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
      }).toList(),
    );
  }
}
