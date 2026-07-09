import 'package:flutter/material.dart';
import 'package:fursafy/app/theme.dart';

class AnalyticsReportsTab extends StatelessWidget {
  final int totalJobs;
  final int completedJobs;
  final int totalApplications;

  const AnalyticsReportsTab({
    super.key,
    required this.totalJobs,
    required this.completedJobs,
    required this.totalApplications,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Reports',
          style: FursafyTheme.headlineStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'In-depth statistical insights tracking the matching growth index.',
          style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),

        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _metricBentoCard(
              icon: Icons.trending_up,
              label: 'Youth Growth Index',
              value: '1.24x',
              trend: '+24%',
              trendColor: FursafyTheme.primary,
            ),
            _metricBentoCard(
              icon: Icons.business_center,
              label: 'Active Providers',
              value: '180',
              trend: 'Optimal',
              trendColor: FursafyTheme.secondary,
            ),
            _metricBentoCard(
              icon: Icons.insights,
              label: 'Match Conversion Ratio',
              value: totalApplications > 0 ? '${(completedJobs / totalApplications * 100).toStringAsFixed(0)}%' : '48%',
              trend: 'High',
              trendColor: FursafyTheme.primaryContainer,
            ),
          ],
        ),
        const SizedBox(height: 36),

        // Sector rankings card
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
              Text(
                'Top Performing Sectors',
                style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _sectorRow('Technology & Software Design', 0.85, '85% active matches'),
              const SizedBox(height: 16),
              _sectorRow('Academic Tutoring', 0.65, '65% active matches'),
              const SizedBox(height: 16),
              _sectorRow('Home Cleaning & Services', 0.50, '50% active matches'),
              const SizedBox(height: 16),
              _sectorRow('Logistics & Delivery', 0.35, '35% active matches'),
            ],
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

  Widget _sectorRow(String sector, double fillFactor, String stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sector,
              style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              stats,
              style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, color: FursafyTheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: fillFactor,
          backgroundColor: FursafyTheme.surfaceContainerLow,
          color: FursafyTheme.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(100),
        ),
      ],
    );
  }
}
