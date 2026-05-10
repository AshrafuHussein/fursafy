import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';

/// S12 — Youth Profile screen (Stitch Exact Match).
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

  @override
  Widget build(BuildContext context) {
    if (_userData?['role'] == 'provider') {
        // Redirection logic should ideally be in router, 
        // but for immediate fix if they land here:
        return const Center(child: Text('Redirecting to Provider Profile...'));
    }

    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FursafyTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.editProfile),
            icon: const Icon(Icons.settings_outlined, color: FursafyTheme.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: FursafyTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Editorial Header
                  Text(
                    'CURATOR OF PROGRESS',
                    style: FursafyTheme.labelStyle.copyWith(
                      color: FursafyTheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: FursafyTheme.surfaceContainerHighest,
                        backgroundImage: _userData?['avatarUrl'] != null
                            ? NetworkImage(_userData!['avatarUrl'] as String)
                            : null,
                        child: _userData?['avatarUrl'] == null
                            ? const Icon(Icons.person, size: 40, color: FursafyTheme.outline)
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userData?['displayName'] ?? 'Alex Johnson',
                              style: FursafyTheme.headlineStyle.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userData?['locationName'] ?? 'Dar es Salaam, TZ',
                              style: FursafyTheme.bodyStyle.copyWith(
                                color: FursafyTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Bio Section
                  _buildSectionHeader('About', FursafyTheme.primary),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _profileData?['bio'] ?? 'Crafting digital experiences with a focus on human connection and community growth.',
                      style: FursafyTheme.bodyStyle.copyWith(
                        height: 1.6,
                        color: FursafyTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Expertise Section (Skills)
                  _buildSectionHeader('Expertise', FursafyTheme.secondary),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ((_profileData?['skills'] as List?) ?? ['UX Design', 'Branding', 'Project Management'])
                          .map<Widget>((s) => Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: FursafyTheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  s.toString(),
                                  style: FursafyTheme.labelStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: FursafyTheme.onSurface,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Experience Section
                  _buildSectionHeader('Experience', FursafyTheme.tertiary),
                  const SizedBox(height: 16),
                  _buildExperienceCard(
                    'Lead Designer',
                    'Fursafy Creative',
                    '2022 - Present',
                    true,
                  ),
                  _buildExperienceCard(
                    'Freelance Illustrator',
                    'Global Logistics',
                    '2020 - 2022',
                    false,
                  ),
                  const SizedBox(height: 48),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FursafyTheme.primary,
                        foregroundColor: FursafyTheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        elevation: 0,
                      ),
                      child: Text(
                        'View Public Profile',
                        style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push(AppRoutes.editProfile),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: const BorderSide(color: FursafyTheme.outlineVariant),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          ),
                          child: Text(
                            'Edit Profile',
                            style: FursafyTheme.bodyStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: FursafyTheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (!context.mounted) return;
                            context.go(AppRoutes.login);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            foregroundColor: Colors.redAccent,
                          ),
                          child: Text(
                            'Sign Out',
                            style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: FursafyTheme.labelStyle.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1.5,
            color: FursafyTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceCard(String role, String company, String date, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: FursafyTheme.headlineStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  company,
                  style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isCurrent)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: FursafyTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'CURRENT',
                    style: FursafyTheme.labelStyle.copyWith(fontSize: 8, color: FursafyTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              Text(
                date,
                style: FursafyTheme.labelStyle.copyWith(color: FursafyTheme.outline, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
