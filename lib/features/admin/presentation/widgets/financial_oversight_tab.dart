import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';

class FinancialOversightTab extends StatelessWidget {
  final double totalTxVolume;
  final double platformFeesPercentage;
  final int completedJobs;

  const FinancialOversightTab({
    super.key,
    required this.totalTxVolume,
    required this.platformFeesPercentage,
    required this.completedJobs,
  });

  @override
  Widget build(BuildContext context) {
    final platformFees = totalTxVolume * (platformFeesPercentage / 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Oversight',
          style: FursafyTheme.headlineStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Oversee total transactional value aggregated dynamically from completed jobs.',
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [FursafyTheme.primary, FursafyTheme.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL TRANSACTION VOLUME',
                    style: FursafyTheme.labelStyle.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'TZS ${totalTxVolume.toStringAsFixed(0)}',
                    style: FursafyTheme.headlineStyle.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          '+12.5%',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'vs last 30 days',
                        style: FursafyTheme.bodyStyle.copyWith(
                            color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _metricBentoCard(
              icon: Icons.account_balance_wallet,
              label: 'Platform Fees (${platformFeesPercentage.toStringAsFixed(0)}%)',
              value: 'TZS ${platformFees.toStringAsFixed(0)}',
              trend: 'Net Revenue',
              trendColor: FursafyTheme.primary,
            ),
            _metricBentoCard(
              icon: Icons.pending_actions,
              label: 'Payouts Pending Verification',
              value: '$completedJobs Jobs',
              trend: 'Awaiting Verification',
              trendColor: FursafyTheme.secondary,
            ),
          ],
        ),
        const SizedBox(height: 36),

        Text(
          'Recent Transactions Ledger',
          style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(FirestorePaths.jobs).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data?.docs ?? [];
            final completedJobsList = docs.where((doc) {
              final status = doc.data()['status'] ?? '';
              return status == 'completed' || status == 'closed';
            }).toList();

            if (completedJobsList.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                ),
                alignment: Alignment.center,
                child: Text('No transaction history on the platform yet.', style: FursafyTheme.bodyStyle),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: completedJobsList.length,
                separatorBuilder: (c, i) => const Divider(height: 1, color: FursafyTheme.outlineVariant),
                itemBuilder: (context, index) {
                  final data = completedJobsList[index].data();
                  final title = data['title'] ?? 'Job';
                  final provider = data['providerName'] ?? 'Provider';
                  final pay = (data['payAmount'] ?? 0.0) as num;
                  final fee = pay * (platformFeesPercentage / 100.0);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: FursafyTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        provider.isNotEmpty ? provider.substring(0, 1).toUpperCase() : 'P',
                        style: FursafyTheme.bodyStyle
                            .copyWith(fontWeight: FontWeight.bold, color: FursafyTheme.primary),
                      ),
                    ),
                    title: Text(title, style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text('Provider: $provider',
                        style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, color: FursafyTheme.onSurfaceVariant)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TZS ${pay.toStringAsFixed(0)}',
                          style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Fee: TZS ${fee.toStringAsFixed(0)}',
                          style: FursafyTheme.bodyStyle.copyWith(
                              fontSize: 11, color: FursafyTheme.outline, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
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
}
