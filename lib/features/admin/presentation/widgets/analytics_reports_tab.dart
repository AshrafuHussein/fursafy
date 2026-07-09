import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';

class AnalyticsReportsTab extends StatelessWidget {
  final int totalJobs;
  final int completedJobs;
  final int totalApplications;
  final int totalProviders;

  const AnalyticsReportsTab({
    super.key,
    required this.totalJobs,
    required this.completedJobs,
    required this.totalApplications,
    required this.totalProviders,
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
              value: '$totalProviders',
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
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection(FirestorePaths.jobs).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator(color: FursafyTheme.primary)),
                );
              }
              final jobs = snapshot.data?.docs ?? [];
              
              final counts = <String, int>{
                'Tech': 0,
                'Tutoring': 0,
                'Cleaning': 0,
                'Construction': 0,
                'Other': 0,
              };
              
              for (var doc in jobs) {
                final data = doc.data();
                final category = data['category'] as String? ?? 'Other';
                String mappedKey = 'Other';
                if (category.toLowerCase().contains('tech')) {
                  mappedKey = 'Tech';
                } else if (category.toLowerCase().contains('tutor') || category.toLowerCase().contains('teach')) {
                  mappedKey = 'Tutoring';
                } else if (category.toLowerCase().contains('clean')) {
                  mappedKey = 'Cleaning';
                } else if (category.toLowerCase().contains('construct') || category.toLowerCase().contains('ujenzi')) {
                  mappedKey = 'Construction';
                }
                
                counts[mappedKey] = (counts[mappedKey] ?? 0) + 1;
              }
              
              final totalActive = jobs.length;
              final sortedSectors = counts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
                
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Performing Sectors',
                    style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ...sortedSectors.map((entry) {
                    final category = entry.key;
                    final count = entry.value;
                    final ratio = totalActive > 0 ? count / totalActive : 0.0;
                    final percentage = (ratio * 100).toStringAsFixed(0);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _sectorRow(
                        category == 'Tech' ? 'Technology & Software Design' :
                        category == 'Tutoring' ? 'Academic Tutoring' :
                        category == 'Cleaning' ? 'Home Cleaning & Services' :
                        category == 'Construction' ? 'Construction & Hard Labor' : 'Other Sectors & Miscellaneous',
                        ratio,
                        '$percentage% active matches ($count jobs)',
                      ),
                    );
                  }),
                ],
              );
            }
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
