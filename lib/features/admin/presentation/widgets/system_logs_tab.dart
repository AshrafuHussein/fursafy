import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';

class SystemLogsTab extends StatelessWidget {
  const SystemLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Logs Console',
                  style: FursafyTheme.headlineStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time monitoring of database integrity and platform event traffic.',
                  style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant),
                ),
              ],
            ),
            // Health Score Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: FursafyTheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Health', style: FursafyTheme.labelStyle.copyWith(fontSize: 10, color: FursafyTheme.outline)),
                      Text('99.8% Online', style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('system_logs').orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                child: const Text('No system logs generated yet.'),
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
                itemCount: docs.length,
                separatorBuilder: (c, i) => const Divider(height: 1, color: FursafyTheme.outlineVariant),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final severity = data['severity'] ?? 'info';
                  final title = data['title'] ?? 'System Event';
                  final desc = data['desc'] ?? '';
                  final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

                  Color severityColor = FursafyTheme.primary;
                  if (severity == 'critical') {
                    severityColor = FursafyTheme.error;
                  } else if (severity == 'warning') {
                    severityColor = FursafyTheme.secondary;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: severityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            severity.toUpperCase(),
                            style: FursafyTheme.labelStyle.copyWith(
                              color: severityColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                desc,
                                style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, color: FursafyTheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          timestamp.toLocal().toString().substring(0, 19),
                          style: FursafyTheme.bodyStyle.copyWith(fontSize: 11, color: FursafyTheme.outline),
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
}
