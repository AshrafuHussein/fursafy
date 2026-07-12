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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header info
        Text(
          'Financial Oversight',
          style: FursafyTheme.headlineStyle.copyWith(fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Oversee total transactional value aggregated dynamically from completed jobs.',
          style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),

        // Bento Grid
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            // Total Volume (Large Bento)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [FursafyTheme.primaryContainer, FursafyTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Transaction Volume'.toUpperCase(),
                    style: FursafyTheme.labelStyle.copyWith(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'TZS ${_formatPrice(totalTxVolume)}',
                    style: FursafyTheme.headlineStyle.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.trending_up, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              '+12.5%',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'vs last 30 days',
                        style: FursafyTheme.bodyStyle.copyWith(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Platform Fees
            _statsCard(
              icon: Icons.account_balance_wallet,
              label: 'Platform Fees (${platformFeesPercentage.toStringAsFixed(0)}%)',
              value: 'TZS ${_formatPrice(platformFees)}',
              bottomLabel: 'Net Revenue',
              iconBg: FursafyTheme.primary.withValues(alpha: 0.05),
              iconColor: FursafyTheme.primary,
            ),
            // Worker Payouts Pending
            Container(
              padding: const EdgeInsets.all(16),
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
                          color: FursafyTheme.secondary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.pending_actions, color: FursafyTheme.secondary, size: 20),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Worker Payouts Pending',
                        style: FursafyTheme.bodyStyle.copyWith(fontSize: 13, color: FursafyTheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedJobs Jobs',
                        style: FursafyTheme.headlineStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w900, color: FursafyTheme.onSurface),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _avatarsStack(),
                      const SizedBox(width: 8),
                      Text(
                        'Awaiting Verification',
                        style: FursafyTheme.labelStyle.copyWith(fontSize: 10, color: FursafyTheme.outline, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),

        // Main layout split
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Table of Recent Transactions (2/3 width)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chevron_right, size: 16),
                        label: const Text('View Full Ledger'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                    ),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection(FirestorePaths.jobs).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(28.0),
                              child: CircularProgressIndicator(color: FursafyTheme.primary),
                            ),
                          );
                        }
                        final docs = snapshot.data?.docs ?? [];
                        final completedJobsList = docs.where((doc) {
                          final status = doc.data()['status'] ?? '';
                          return status == 'completed' || status == 'closed' || status == 'open';
                        }).take(5).toList(); // Show top 5 recent jobs

                        if (completedJobsList.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(
                              child: Text('No transaction history on the platform yet.'),
                            ),
                          );
                        }

                        return DataTable(
                          headingRowColor: WidgetStateProperty.all(FursafyTheme.surfaceContainerLow.withValues(alpha: 0.5)),
                          horizontalMargin: 24,
                          columns: const [
                            DataColumn(label: Text('ENTITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                            DataColumn(label: Text('SERVICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                            DataColumn(label: Text('AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                            DataColumn(label: Text('FEE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                            DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                          ],
                          rows: completedJobsList.map<DataRow>((doc) {
                            final data = doc.data();
                            final title = data['title'] ?? 'Job';
                            final provider = data['providerName'] ?? 'Provider';
                            final pay = (data['payAmount'] ?? 0.0) as num;
                            final fee = pay * (platformFeesPercentage / 100.0);
                            final status = data['status'] ?? 'open';
                            final isCompleted = status == 'completed';

                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: FursafyTheme.primary.withValues(alpha: 0.1),
                                        child: Text(
                                          provider.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FursafyTheme.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(provider, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                          Text('Youth Worker', style: TextStyle(fontSize: 11, color: FursafyTheme.onSurfaceVariant)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                      Text('Provider: $provider', style: TextStyle(fontSize: 11, color: FursafyTheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                DataCell(Text('TZS ${_formatPrice(pay.toDouble())}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                                DataCell(Text('TZS ${_formatPrice(fee)}', style: TextStyle(fontSize: 12, color: FursafyTheme.outline))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCompleted ? FursafyTheme.primary.withValues(alpha: 0.1) : FursafyTheme.secondary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      isCompleted ? 'PAID' : 'PENDING',
                                      style: TextStyle(
                                        color: isCompleted ? FursafyTheme.primary : FursafyTheme.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 28),

            // Right Column: Revenue Breakdown + Dispute Warnings (1/3 width)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Revenue Breakdown',
                    style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _breakdownRow('Worker Payouts', 0.97, '97%', FursafyTheme.primary),
                        const SizedBox(height: 16),
                        _breakdownRow('Platform Fee', 0.03, '3%', FursafyTheme.secondary),
                        const SizedBox(height: 24),
                        const Divider(color: FursafyTheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text(
                          'PAYOUT CHANNELS',
                          style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 16),
                        _channelRow(Colors.green, 'M-Pesa', '68%'),
                        const SizedBox(height: 10),
                        _channelRow(Colors.red, 'Airtel Money', '22%'),
                        const SizedBox(height: 10),
                        _channelRow(Colors.blue, 'Tigo Pesa', '10%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reconciliation needed card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceBright,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: FursafyTheme.primary.withValues(alpha: 0.15), width: 2),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -16,
                          bottom: -16,
                          child: Opacity(
                            opacity: 0.05,
                            child: Icon(Icons.gavel, size: 80, color: FursafyTheme.primary),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reconciliation Needed',
                              style: FursafyTheme.headlineStyle.copyWith(color: FursafyTheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '4 transactions flagged for provider-worker dispute. Review required before payout.',
                              style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.outline, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _showBatchPayoutModal(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FursafyTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                elevation: 0,
                              ),
                              child: const Text('Open Dispute Center', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),

        // Footer Meta
        const Divider(color: FursafyTheme.outlineVariant),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('System Status: ', style: TextStyle(fontSize: 11, color: FursafyTheme.outline)),
                const Text('Operational', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                const Text(' • Last Sync: 2m ago', style: TextStyle(fontSize: 11, color: FursafyTheme.outline)),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('EXPORT CSV', style: FursafyTheme.labelStyle.copyWith(fontSize: 11, color: FursafyTheme.outline, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {},
                  child: Text('GENERATE PDF REPORT', style: FursafyTheme.labelStyle.copyWith(fontSize: 11, color: FursafyTheme.outline, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _statsCard({
    required IconData icon,
    required String label,
    required String value,
    required String bottomLabel,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FursafyTheme.bodyStyle.copyWith(fontSize: 13, color: FursafyTheme.onSurfaceVariant, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: FursafyTheme.headlineStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w900, color: FursafyTheme.onSurface),
              ),
            ],
          ),
          Text(
            bottomLabel.toUpperCase(),
            style: FursafyTheme.labelStyle.copyWith(fontSize: 10, color: FursafyTheme.outline, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _avatarsStack() {
    return SizedBox(
      width: 50,
      height: 20,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=150&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(String title, double fraction, String pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant, fontSize: 13),
            ),
            Text(
              pct,
              style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: FursafyTheme.surfaceContainerHigh,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _channelRow(Color dotColor, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(
              label,
              style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Text(
          value,
          style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatPrice(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    // Add comma format manually
    final str = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  // Batch Payout Authorization Modal matching design exactly!
  void _showBatchPayoutModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 550,
            decoration: BoxDecoration(
              color: FursafyTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // Left Column: Green background
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: const BoxDecoration(
                      color: FursafyTheme.primary,
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.payments_outlined, color: Colors.white70, size: 28),
                        const SizedBox(height: 24),
                        Text(
                          'Batch Payout Authorization',
                          style: FursafyTheme.headlineStyle.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cycle: Oct 15 - Oct 30',
                          style: FursafyTheme.labelStyle.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'TOTAL AMOUNT',
                          style: FursafyTheme.labelStyle.copyWith(
                            color: Colors.white70,
                            fontSize: 9,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'TZS 1.2M',
                          style: FursafyTheme.headlineStyle.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Column: White background details
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Confirm Batch Release',
                          style: FursafyTheme.headlineStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Review the recipient summary before authorizing the transaction.',
                          style: FursafyTheme.bodyStyle.copyWith(
                            color: FursafyTheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Itemized summaries
                        _itemizedRow(Icons.people_outline, '32 Approved Recipients', 'TZS 850,000'),
                        const SizedBox(height: 12),
                        _itemizedRow(Icons.account_balance, 'Platform Commissions (15%)', 'TZS 180,000'),
                        const SizedBox(height: 12),
                        _itemizedRow(Icons.receipt_long_outlined, 'Tax Deductions', 'TZS 170,000'),
                        const SizedBox(height: 24),

                        Row(
                          children: const [
                            Icon(Icons.info_outline, size: 14, color: FursafyTheme.outline),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Funds will be available in 2-4 hours.',
                                style: TextStyle(fontSize: 11, color: FursafyTheme.outline),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Modify'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF855400), // secondary/amber
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              child: Row(
                                children: const [
                                  Text('Release Funds', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.send, size: 14),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _itemizedRow(IconData icon, String label, String amount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: FursafyTheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            amount,
            style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Helper to support gridIndex attribute used above
extension on Widget {
  Widget get gridIndex => this;
}
