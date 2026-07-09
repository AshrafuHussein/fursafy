import 'package:flutter/material.dart';
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
              value: '$totalUsers',
              trend: '+12%',
              trendColor: FursafyTheme.primary,
            ),
            _metricBentoCard(
              icon: Icons.work,
              label: 'Active Jobs',
              value: '$totalJobs',
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
            // Left Column: Area Chart Trajectory
            Expanded(
              flex: 2,
              child: Container(
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: FursafyTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '12 WEEKS',
                            style: FursafyTheme.labelStyle.copyWith(
                              color: FursafyTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
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
            ),
            const SizedBox(width: 28),

            // Right Column: Operations & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Operations',
                    style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _operationButton(
                    title: 'Verify Users',
                    icon: Icons.person_add_alt_1_outlined,
                    color: FursafyTheme.primary,
                    onTap: onVerifyUsers,
                  ),
                  const SizedBox(height: 12),
                  _operationButton(
                    title: 'Moderate Listings',
                    icon: Icons.gavel_outlined,
                    color: FursafyTheme.secondary,
                    onTap: onModerateListings,
                  ),
                  const SizedBox(height: 12),
                  _operationButton(
                    title: 'System Health Logs',
                    icon: Icons.terminal_outlined,
                    color: FursafyTheme.primaryContainer,
                    onTap: onSystemLogs,
                  ),
                ],
              ),
            ),
          ],
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: FursafyTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: FursafyTheme.outline),
          ],
        ),
      ),
    );
  }
}
