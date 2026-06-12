import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/profile/presentation/widgets/skill_picker_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// S12 — Youth Profile screen — Editorial hero design.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _profileData;
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
      final profileDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.youthProfiles)
          .doc(uid)
          .get();

      setState(() {
        _userData = userDoc.data();
        _profileData = profileDoc.data();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _openSkillPicker(List<String> currentSkills) async {
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (context) =>
            SkillPickerDialog(initialSelectedSkills: currentSkills),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      setState(() => _loading = true);
      try {
        await FirebaseFirestore.instance
            .collection(FirestorePaths.youthProfiles)
            .doc(uid)
            .set({'skills': result}, SetOptions(merge: true));

        await _loadProfile();
      } catch (e) {
        setState(() => _loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating skills: $e'),
            backgroundColor: FursafyTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userData?['role'] == 'provider') {
      return const Center(child: Text('Redirecting to Provider Profile...'));
    }

    final avatarUrl = _userData?['avatarUrl'] as String?;

    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: FursafyTheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: FursafyTheme.surfaceContainerHighest,
              ),
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          color: FursafyTheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: FursafyTheme.onSurfaceVariant,
                    ),
            ),
            const SizedBox(width: 12),
            Text(
              'FURSAFY',
              style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: FursafyTheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: FursafyTheme.primary),
            onPressed: () => context.go(AppRoutes.notifications),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FursafyTheme.primary),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image Section
                  _buildHeroSection(context),
                  const SizedBox(height: 32),

                  // Stats Bento Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildStatsGrid(),
                  ),
                  const SizedBox(height: 32),

                  // Skills Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSkillsSection(),
                  ),
                  const SizedBox(height: 32),

                  // Professional Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildBioSection(),
                  ),
                  const SizedBox(height: 32),

                  // Location Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildLocationCard(),
                  ),
                  const SizedBox(height: 32),

                  // Sign Out
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSignOutButton(context),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                context,
                Icons.home_max_rounded,
                'HOME',
                false,
                onTap: () => context.go(AppRoutes.home),
              ),
              _navItem(
                context,
                Icons.search_rounded,
                'SEARCH',
                false,
                onTap: () => context.push(AppRoutes.search),
              ),
              _navItem(
                context,
                Icons.description_outlined,
                'APPLIED',
                false,
                onTap: () => context.go(AppRoutes.myApplications),
              ),
              _navItem(
                context,
                Icons.notifications_none_rounded,
                'ALERTS',
                false,
                onTap: () => context.go(AppRoutes.notifications),
              ),
              _navItem(context, Icons.person_outline_rounded, 'PROFILE', true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? FursafyTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? FursafyTheme.primary : FursafyTheme.outline,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: FursafyTheme.labelStyle.copyWith(
                color: isActive ? FursafyTheme.primary : FursafyTheme.outline,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final name = _userData?['displayName'] ?? 'Youth Worker';
    final avatarUrl = _userData?['avatarUrl'] as String?;
    final rating = _profileData?['averageRating'] ?? 0.0;
    final ratingVal = rating is num
        ? rating.toDouble()
        : double.tryParse('$rating') ?? 0.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Large portrait image
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Container(
                decoration: const BoxDecoration(
                  color: FursafyTheme.surfaceContainerHigh,
                ),
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: FursafyTheme.primary,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildAvatarPlaceholder(),
                      )
                    : _buildAvatarPlaceholder(),
              ),
            ),
          ),
        ),
        // Gradient overlay
        Positioned(
          left: 24,
          right: 24,
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Star Rating
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 20,
                          color: i < ratingVal.round()
                              ? FursafyTheme.secondaryContainer
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${ratingVal.toStringAsFixed(1)} Rating',
                        style: FursafyTheme.bodyStyle.copyWith(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Floating Edit Profile Button
        Positioned(
          bottom: -24,
          right: 32,
          child: GestureDetector(
            onTap: () async {
              final result = await context.push<bool>(AppRoutes.editProfile);
              if (result == true) {
                _loadProfile();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: FursafyTheme.primary,
                borderRadius: BorderRadius.circular(100),
                boxShadow: FursafyTheme.floatingShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit,
                    color: FursafyTheme.onPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Profile',
                    style: FursafyTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: FursafyTheme.onPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: FursafyTheme.surfaceContainerHigh,
      child: const Center(
        child: Icon(Icons.person, size: 80, color: FursafyTheme.outlineVariant),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final jobsCompleted = _profileData?['completedJobsCount'] ?? 0;
    final clientRating = _profileData?['averageRating'] ?? 0.0;
    final ratingStr = clientRating is num
        ? clientRating.toDouble().toStringAsFixed(2)
        : '$clientRating';

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: FursafyTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: FursafyTheme.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$jobsCompleted',
                  style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: FursafyTheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'JOBS COMPLETED',
                  style: FursafyTheme.labelStyle.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: FursafyTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: FursafyTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: FursafyTheme.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Text(
                  ratingStr,
                  style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: FursafyTheme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CLIENT RATING',
                  style: FursafyTheme.labelStyle.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: FursafyTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    final skills =
        (_profileData?['skills'] as List?)?.map((s) => s.toString()).toList() ??
        [];

    // Material icon mapping for common skills
    IconData skillIcon(String skill) {
      final lower = skill.toLowerCase();
      if (lower.contains('plumb')) return Icons.plumbing;
      if (lower.contains('clean')) return Icons.cleaning_services;
      if (lower.contains('electric')) return Icons.electrical_services;
      if (lower.contains('carpen')) return Icons.carpenter;
      if (lower.contains('cook')) return Icons.restaurant;
      if (lower.contains('driv')) return Icons.local_shipping;
      if (lower.contains('paint')) return Icons.format_paint;
      if (lower.contains('manage') || lower.contains('project')) {
        return Icons.trending_up;
      }
      if (lower.contains('tutor') || lower.contains('teach')) {
        return Icons.school;
      }
      if (lower.contains('design')) return Icons.design_services;
      if (lower.contains('photo')) return Icons.camera_alt;
      return Icons.build;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Skills',
                  style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: FursafyTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verified professional capabilities',
                  style: FursafyTheme.bodyStyle.copyWith(
                    fontSize: 13,
                    color: FursafyTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _openSkillPicker(skills),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: FursafyTheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: FursafyTheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.verified,
                  color: FursafyTheme.primary,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (skills.isEmpty)
          GestureDetector(
            onTap: () => _openSkillPicker(skills),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FursafyTheme.outlineVariant.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 32,
                    color: FursafyTheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No skills added yet. Tap here to add your skills.',
                    style: FursafyTheme.bodyStyle.copyWith(
                      color: FursafyTheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () => _openSkillPicker(skills),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.asMap().entries.map((entry) {
                final index = entry.key;
                final skill = entry.value;
                // Alternate between primary-fixed and secondary-fixed-dim
                final isPrimaryStyle = index % 4 != 3;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isPrimaryStyle
                        ? FursafyTheme.primaryFixed
                        : FursafyTheme.secondaryFixedDim,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        skillIcon(skill),
                        size: 16,
                        color: isPrimaryStyle
                            ? const Color(0xFF00513A)
                            : const Color(0xFF653E00),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        skill,
                        style: FursafyTheme.bodyStyle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isPrimaryStyle
                              ? const Color(0xFF00513A)
                              : const Color(0xFF653E00),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildBioSection() {
    final bio =
        _profileData?['bio'] ??
        'Dedicated worker passionate about delivering premium quality and ensuring satisfaction in every project.';

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Decorative quote icon
          Positioned(
            top: -4,
            right: -4,
            child: Icon(
              Icons.format_quote,
              size: 48,
              color: FursafyTheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROFESSIONAL BIO',
                style: FursafyTheme.labelStyle.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                  color: FursafyTheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                bio,
                style: FursafyTheme.bodyStyle.copyWith(
                  fontSize: 15,
                  color: FursafyTheme.onSurface,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final location = _userData?['locationName'] ?? 'Dar es Salaam, TZ';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: FursafyTheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.map,
              color: FursafyTheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: FursafyTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: FursafyTheme.onSurface,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Available for service within 20km',
                style: FursafyTheme.bodyStyle.copyWith(
                  fontSize: 13,
                  color: FursafyTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (!context.mounted) return;
          context.go(AppRoutes.login);
        },
        icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
        label: Text(
          'Sign Out',
          style: FursafyTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
