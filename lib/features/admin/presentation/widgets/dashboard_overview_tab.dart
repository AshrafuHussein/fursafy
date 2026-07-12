import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';

class DashboardOverviewTab extends StatelessWidget {
  final int totalUsers;
  final int totalJobs;
  final int totalApplications;
  final int completedJobs;
  final int flaggedJobsCount;
  final double totalTxVolume;
  final List<Map<String, dynamic>> weeklyJobsData;
  final VoidCallback onVerifyUsers;
  final VoidCallback onModerateListings;
  final VoidCallback onSystemLogs;

  const DashboardOverviewTab({
    super.key,
    required this.totalUsers,
    required this.totalJobs,
    required this.totalApplications,
    required this.completedJobs,
    required this.flaggedJobsCount,
    required this.totalTxVolume,
    required this.weeklyJobsData,
    required this.onVerifyUsers,
    required this.onModerateListings,
    required this.onSystemLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Habari, Admin.',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: FursafyTheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Here\'s what\'s happening across the Fursafy ecosystem today.',
          style: FursafyTheme.bodyStyle.copyWith(
            fontSize: 15,
            color: FursafyTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),

        // Metrics Grid
        GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _metricBentoCard(
              icon: Icons.group,
              label: 'Total Users',
              value: _formatNumber(totalUsers),
              trend: '+12%',
              trendColor: FursafyTheme.primary,
            ),
            _metricBentoCard(
              icon: Icons.work,
              label: 'Active Jobs',
              value: _formatNumber(totalJobs),
              trend: '+4.2%',
              trendColor: FursafyTheme.secondary,
            ),
            _metricBentoCard(
              icon: Icons.verified,
              label: 'Fill Rate',
              value: totalJobs > 0 ? '${(completedJobs / totalJobs * 100).toStringAsFixed(0)}%' : '68%',
              trend: 'Optimal',
              trendColor: FursafyTheme.primaryContainer,
            ),
            _metricBentoCard(
              icon: Icons.flag,
              label: 'Flagged Items',
              value: '$flaggedJobsCount',
              trend: 'Attention',
              trendColor: FursafyTheme.error,
            ),
          ],
        ),
        const SizedBox(height: 36),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Area Chart Trajectory + Quick Operations (2/3 width)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jobs Posted per Week',
                                  style: FursafyTheme.headlineStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Opportunity trajectory over the last 3 months',
                                  style: FursafyTheme.bodyStyle.copyWith(
                                    fontSize: 13,
                                    color: FursafyTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            // Toggle
                            Row(
                              children: [
                                _chartToggleButton('12 Weeks', isActive: true),
                                const SizedBox(width: 8),
                                _chartToggleButton('Monthly', isActive: false),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Custom Area Chart bars representation
                        SizedBox(
                          height: 180,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: weeklyJobsData.isEmpty
                                ? List.generate(12, (index) => _chartBar(0.1))
                                : weeklyJobsData.map((data) {
                                    final scale = (data['scale'] as num?)?.toDouble() ?? 0.1;
                                    final count = (data['count'] as num?)?.toInt() ?? 0;
                                    final isLast = weeklyJobsData.indexOf(data) == weeklyJobsData.length - 1;
                                    return _chartBar(
                                      scale,
                                      isHighlight: isLast,
                                      label: count > 0 ? '$count' : null,
                                    );
                                  }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('WEEK 1', style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                            Text('WEEK 4', style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                            Text('WEEK 8', style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                            Text('CURRENT', style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Quick Operations Section
                  Text(
                    'Quick Operations',
                    style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _operationButton(
                          title: 'Verify Users',
                          icon: Icons.person_add_alt_1_outlined,
                          color: FursafyTheme.primary,
                          onTap: onVerifyUsers,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _operationButton(
                          title: 'Moderate Jobs',
                          icon: Icons.gavel_outlined,
                          color: FursafyTheme.secondary,
                          onTap: onModerateListings,
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _operationButton(
                          title: 'Export Reports',
                          icon: Icons.cloud_download_outlined,
                          color: FursafyTheme.primary,
                          onTap: () {},
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 28),

            // Right Column: Platform Pulse Feed (1/3 width)
            Expanded(
              child: _buildPlatformPulseFeed(),
            ),
          ],
        ),
        const SizedBox(height: 48),

        // Hero Spotlight Banner
        _buildHeroSpotlightBanner(context),
        const SizedBox(height: 32),

        // Footer
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '© 2024 Fursafy Admin Ecosystem. Built for growth and precision.',
              style: TextStyle(
                fontFamily: FursafyTheme.bodyFont,
                fontSize: 12,
                color: FursafyTheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _metricBentoCard({
    required IconData icon,
    required String label,
    required String value,
    required String trend,
    required Color trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: trendColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  trend,
                  style: FursafyTheme.labelStyle.copyWith(
                    color: trendColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FursafyTheme.bodyStyle.copyWith(
                  fontSize: 13,
                  color: FursafyTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: FursafyTheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartBar(double scale, {bool isHighlight = false, String? label}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (label != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: FursafyTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Expanded(
              child: FractionallySizedBox(
                heightFactor: scale,
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: isHighlight ? FursafyTheme.primary : FursafyTheme.primary.withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _operationButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isPrimary ? FursafyTheme.primary : FursafyTheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.white.withValues(alpha: 0.15) : color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isPrimary ? Colors.white : color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.white : FursafyTheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: isPrimary ? Colors.white70 : FursafyTheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return '$number';
  }

  Widget _chartToggleButton(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? FursafyTheme.primaryFixed : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: FursafyTheme.labelStyle.copyWith(
          color: isActive ? FursafyTheme.onPrimaryFixed : FursafyTheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPlatformPulseFeed() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Platform Pulse',
                style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: FursafyTheme.onSurface,
                ),
              ),
              const Icon(Icons.sensors, color: FursafyTheme.primary),
            ],
          ),
          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('system_logs')
                .orderBy('timestamp', descending: true)
                .limit(4)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: FursafyTheme.primary),
                  ),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No active system logs.',
                    style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant),
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data();
                  final title = data['title'] ?? 'System Event';
                  final desc = data['desc'] ?? '';
                  final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final severity = data['severity'] ?? 'info';

                  IconData iconData = Icons.description;
                  Color iconColor = FursafyTheme.onSurfaceVariant;
                  if (title.toString().toLowerCase().contains('signup') ||
                      title.toString().toLowerCase().contains('user') ||
                      title.toString().toLowerCase().contains('invite')) {
                    iconData = Icons.person_add;
                    iconColor = FursafyTheme.primary;
                  } else if (severity == 'critical' ||
                      title.toString().toLowerCase().contains('flag') ||
                      title.toString().toLowerCase().contains('fail')) {
                    iconData = Icons.report_problem;
                    iconColor = FursafyTheme.error;
                  } else if (title.toString().toLowerCase().contains('payment') ||
                      title.toString().toLowerCase().contains('tx') ||
                      title.toString().toLowerCase().contains('payout') ||
                      title.toString().toLowerCase().contains('fee')) {
                    iconData = Icons.payments;
                    iconColor = FursafyTheme.primary;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(iconData, color: iconColor, size: 20),
                            ),
                            if (iconData == Icons.person_add)
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    color: FursafyTheme.primaryFixedDim,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.check, size: 8, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: FursafyTheme.bodyStyle.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: severity == 'critical' ? FursafyTheme.error : FursafyTheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _timeAgo(timestamp),
                                    style: FursafyTheme.labelStyle.copyWith(
                                      fontSize: 10,
                                      color: FursafyTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                desc,
                                style: FursafyTheme.bodyStyle.copyWith(
                                  fontSize: 12,
                                  color: FursafyTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSystemLogs,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VIEW COMPLETE AUDIT LOG',
                  style: FursafyTheme.labelStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FursafyTheme.primary,
                    letterSpacing: 1.2,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildHeroSpotlightBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FursafyTheme.primary,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        children: [
          // Graphic overlap texture background
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 400,
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuB6tXRG5poF-41GJnnp1dFMqkPrGHllcriGA9YbYH_Q2NKRe3bPl3uE9i2c-_hlAp7zWj3eVi_CfBKIKqPCvfh6l0e09fPOWSVmzb22BVD22lU9PwMoN8ZCA3hzkFFoyTmE6QePIJ8sgAotlfKuopUAl-HFl66WSXO07wjGyOp3Q1BetbE19xH_7zm8Urn5TUMXrIk442acNTPh2L8RAmvvEhpIiQvN73opweWf0KZCUJNFAQIJMxfWREtmn06s0viWvpRY48oJnqXR',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: FursafyTheme.primaryFixedDim,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'SYSTEM STATUS: HEALTHY',
                          style: FursafyTheme.labelStyle.copyWith(
                            color: FursafyTheme.onPrimaryFixed,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Empowering Tanzania\'s next generation of talent.',
                        style: FursafyTheme.headlineStyle.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your actions today influence the career paths of 12,000+ young professionals. Keep up the great curation.',
                        style: FursafyTheme.bodyStyle.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Action to settings
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: FursafyTheme.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            ),
                            child: const Text('Platform Settings'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: onSystemLogs,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24, width: 1.5),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            ),
                            child: const Text('Launch System Audit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                // Holographic Workspace Image from HTML Code
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: RotationTransition(
                      turns: const AlwaysStoppedAnimation(3 / 360),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuD2yWgehRnFSsjGdLxfKbpPa86vwYh3BBfURubccgwiWmhh_W4GReZaVIMgBLhWFTKapyo-AD9jc1-N21DB2m7lFgQt6RdiVeDCkXuBwUkCkwczt-ogVcjjiBPnZj3p1QHz8iWq0UseYTvGyUkwjERi1avOMO3AEP2-bfsjsuurONHZFQHZraOtmlkNo5uNVsa8gPmOtUft6MssSoMoPL4WqLvrbwkvXD-fGkog_b4eSEnzn4MMu3Z3POD6T5Lukj9M3YDL0H52RRhk',
                            height: 256,
                            width: 400,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
