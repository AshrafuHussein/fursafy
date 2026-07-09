import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';

class JobModerationTab extends StatelessWidget {
  final String jobSearchQuery;
  final String jobFilterStatus;
  final ValueChanged<String> onJobFilterStatusChanged;
  final Function(String jobId, String action) onJobAction;

  const JobModerationTab({
    super.key,
    required this.jobSearchQuery,
    required this.jobFilterStatus,
    required this.onJobFilterStatusChanged,
    required this.onJobAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title block
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Moderation',
                  style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review and curate high-impact opportunities for the community.',
                  style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant),
                ),
              ],
            ),
            // Actions
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Post Opportunity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FursafyTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Subtabs
        Row(
          children: [
            _subTabButton('Pending Review', 'pending'),
            const SizedBox(width: 16),
            _subTabButton('Flagged Content', 'flagged'),
            const SizedBox(width: 16),
            _subTabButton('History', 'history'),
          ],
        ),
        const Divider(height: 1, color: FursafyTheme.outlineVariant),
        const SizedBox(height: 24),

        // Query Stream
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(FirestorePaths.jobs).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading listings: ${snapshot.error}'));
            }

            final docs = snapshot.data?.docs ?? [];
            final filteredDocs = docs.where((doc) {
              final data = doc.data();
              final status = data['status'] ?? 'open';
              final title = (data['title'] ?? '').toString().toLowerCase();

              // Search query check
              if (jobSearchQuery.isNotEmpty && !title.contains(jobSearchQuery.toLowerCase())) {
                return false;
              }

              // Status filtering check
              if (jobFilterStatus == 'pending') {
                return status == 'pending';
              } else if (jobFilterStatus == 'flagged') {
                return status == 'flagged';
              } else {
                // history
                return status == 'closed' || status == 'completed' || status == 'open';
              }
            }).toList();

            if (filteredDocs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.work_off_outlined, size: 48, color: FursafyTheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No jobs listed under "$jobFilterStatus".',
                      style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                final doc = filteredDocs[index];
                final data = doc.data();
                final jobId = doc.id;
                final title = data['title'] ?? 'No Title';
                final providerName = data['providerName'] ?? 'Unknown Provider';
                final category = data['category'] ?? 'Other';
                final desc = data['description'] ?? 'No Description provided.';
                final status = data['status'] ?? 'open';
                final payAmount = (data['payAmount'] ?? 0.0) as num;
                final payType = data['payType'] ?? 'fixed';

                final isPending = status == 'pending';
                final isFlagged = status == 'flagged';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: FursafyTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      // Category circle icon
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: FursafyTheme.secondary.withValues(alpha: 0.08),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _getCategoryIcon(category),
                          color: FursafyTheme.secondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  title,
                                  style: FursafyTheme.headlineStyle.copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: FursafyTheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    category.toUpperCase(),
                                    style: FursafyTheme.labelStyle.copyWith(
                                      fontSize: 10,
                                      color: FursafyTheme.onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: FursafyTheme.bodyStyle.copyWith(
                                  fontSize: 13, color: FursafyTheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Posted by $providerName',
                                  style: FursafyTheme.bodyStyle.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: FursafyTheme.outline,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${payAmount.toStringAsFixed(0)} TZS${payType == 'hourly' ? '/hr' : ''}',
                                  style: FursafyTheme.bodyStyle.copyWith(
                                    fontSize: 12,
                                    color: FursafyTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Actions Block
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined, color: FursafyTheme.outline),
                            onPressed: () => _showJobDetailsDialog(context, title, providerName, desc, payAmount.toDouble(), category),
                            tooltip: 'View Details',
                          ),
                          const SizedBox(width: 8),
                          if (isPending) ...[
                            ElevatedButton(
                              onPressed: () => onJobAction(jobId, 'flag'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FursafyTheme.error.withValues(alpha: 0.1),
                                foregroundColor: FursafyTheme.error,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              child: const Text('Flag'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => onJobAction(jobId, 'approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FursafyTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              child: const Text('Approve'),
                            ),
                          ] else if (isFlagged) ...[
                            ElevatedButton(
                              onPressed: () => onJobAction(jobId, 'approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FursafyTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              child: const Text('Approve'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => onJobAction(jobId, 'delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FursafyTheme.error,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              child: const Text('Delete'),
                            ),
                          ] else ...[
                            // history options
                            ElevatedButton(
                              onPressed: () => onJobAction(jobId, 'close'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FursafyTheme.secondary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              child: const Text('Close'),
                            ),
                          ]
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _subTabButton(String label, String statusKey) {
    final isSelected = jobFilterStatus == statusKey;
    return Column(
      children: [
        TextButton(
          onPressed: () => onJobFilterStatusChanged(statusKey),
          child: Text(
            label,
            style: FursafyTheme.headlineStyle.copyWith(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? FursafyTheme.primary : FursafyTheme.outline,
            ),
          ),
        ),
        Container(
          height: 2,
          width: 80,
          color: isSelected ? FursafyTheme.primary : Colors.transparent,
        ),
      ],
    );
  }

  void _showJobDetailsDialog(BuildContext context, String title, String provider, String desc, double pay, String category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FursafyTheme.surface,
          title: Text(title, style: FursafyTheme.headlineStyle.copyWith(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Provider: $provider', style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Category: $category', style: FursafyTheme.bodyStyle),
                Text('Pay Amount: ${pay.toStringAsFixed(0)} TZS', style: FursafyTheme.bodyStyle),
                const SizedBox(height: 16),
                Text(desc, style: FursafyTheme.bodyStyle),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tech':
        return Icons.computer_outlined;
      case 'cleaning':
        return Icons.cleaning_services_outlined;
      case 'construction':
        return Icons.construction_outlined;
      case 'tutoring':
        return Icons.school_outlined;
      case 'delivery':
        return Icons.local_shipping_outlined;
      case 'cooking':
        return Icons.restaurant_outlined;
      case 'repair':
        return Icons.build_outlined;
      default:
        return Icons.work_outline;
    }
  }
}
