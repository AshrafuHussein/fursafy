import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';

class JobModerationTab extends StatefulWidget {
  final String jobSearchQuery;
  final String jobFilterStatus;
  final ValueChanged<String> onJobFilterStatusChanged;
  final Function(String jobId, String action, {Map<String, dynamic>? jobData}) onJobAction;

  const JobModerationTab({
    super.key,
    required this.jobSearchQuery,
    required this.jobFilterStatus,
    required this.onJobFilterStatusChanged,
    required this.onJobAction,
  });

  @override
  State<JobModerationTab> createState() => _JobModerationTabState();
}

class _JobModerationTabState extends State<JobModerationTab> {
  int _currentPage = 0;
  static const int _pageSize = 10;

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: FursafyTheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Review and curate high-impact opportunities for the community.',
                  style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showPostJobDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Post Opportunity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FursafyTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Stream jobs to aggregate tab badges dynamically
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(FirestorePaths.jobs).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: FursafyTheme.primary),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            int pendingCount = docs.where((doc) => (doc.data()['status'] ?? 'open') == 'pending').length;
            int flaggedCount = docs.where((doc) => (doc.data()['status'] ?? 'open') == 'flagged').length;
            
            // Calculate dynamic flag rate
            final double flagRate = docs.isNotEmpty ? flaggedCount / docs.length : 0.12;

            // Filter jobs based on selected tab + search query
            final filteredDocs = docs.where((doc) {
              final data = doc.data();
              final status = data['status'] ?? 'open';
              final title = (data['title'] ?? '').toString().toLowerCase();

              if (widget.jobSearchQuery.isNotEmpty && !title.contains(widget.jobSearchQuery.toLowerCase())) {
                return false;
              }

              if (widget.jobFilterStatus == 'pending') {
                return status == 'pending';
              } else if (widget.jobFilterStatus == 'flagged') {
                return status == 'flagged';
              } else {
                // history
                return status == 'closed' || status == 'completed' || status == 'open';
              }
            }).toList();

            // Pagination
            final totalFiltered = filteredDocs.length;
            final totalPages = (totalFiltered / _pageSize).ceil();
            if (_currentPage >= totalPages && totalPages > 0) {
              _currentPage = totalPages - 1;
            } else if (totalFiltered == 0) {
              _currentPage = 0;
            }

            final startIndex = _currentPage * _pageSize;
            final endIndex = (startIndex + _pageSize).clamp(0, totalFiltered);
            final paginatedDocs = filteredDocs.isEmpty ? [] : filteredDocs.sublist(startIndex, endIndex);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subtabs with badges
                Row(
                  children: [
                    _subTabButton('Pending Review', 'pending', badgeCount: pendingCount),
                    const SizedBox(width: 24),
                    _subTabButton('Flagged Content', 'flagged', badgeCount: flaggedCount),
                    const SizedBox(width: 24),
                    _subTabButton('History', 'history'),
                  ],
                ),
                const Divider(height: 1, color: FursafyTheme.outlineVariant),
                const SizedBox(height: 24),

                // Table grid of opportunities
                Container(
                  decoration: BoxDecoration(
                    color: FursafyTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Headers
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        color: FursafyTheme.surfaceContainer.withValues(alpha: 0.5),
                        child: Row(
                          children: const [
                            Expanded(flex: 5, child: Text('OPPORTUNITY DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                            Expanded(flex: 3, child: Text('PROVIDER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                            Expanded(flex: 2, child: Text('POSTED DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                            Expanded(flex: 3, child: SizedBox.shrink()),
                          ],
                        ),
                      ),

                      // Rows
                      if (paginatedDocs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Center(child: Text('No opportunities listed here.')),
                        )
                      else
                        Column(
                          children: paginatedDocs.map<Widget>((doc) {
                            final data = doc.data();
                            final jobId = doc.id;
                            final title = data['title'] ?? 'No Title';
                            final providerName = data['providerName'] ?? 'Unknown Provider';
                            final category = data['category'] ?? 'Other';
                            final desc = data['description'] ?? 'No Description provided.';
                            final status = data['status'] ?? 'open';
                            final isPending = status == 'pending';
                            final isFlagged = status == 'flagged';
                            final payAmount = (data['payAmount'] ?? 0.0) as num;
                            final payType = data['payType'] ?? 'fixed';
                            final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

                            // Map custom tags
                            List<String> tags = [category];
                            if (payAmount > 300000) tags.add('High Priority');
                            if (payType == 'hourly') tags.add('Remote');

                            // Random provider logos
                            final logoUrl = category.toString().toLowerCase() == 'tech'
                                ? 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=150&q=80'
                                : 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=150&q=80';

                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: const BoxDecoration(
                                color: FursafyTheme.surfaceContainerLowest,
                                border: Border(bottom: BorderSide(color: FursafyTheme.outlineVariant, width: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  // Opportunity details
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: FursafyTheme.headlineStyle.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: FursafyTheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          desc,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: FursafyTheme.bodyStyle.copyWith(
                                            fontSize: 13,
                                            color: FursafyTheme.onSurfaceVariant,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: tags.map((tag) => Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: tag == 'High Priority'
                                                  ? FursafyTheme.primaryFixed
                                                  : tag == 'Trending'
                                                      ? FursafyTheme.secondaryFixed
                                                      : FursafyTheme.surfaceContainer,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              tag.toUpperCase(),
                                              style: FursafyTheme.labelStyle.copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: tag == 'High Priority'
                                                    ? FursafyTheme.onPrimaryFixed
                                                    : tag == 'Trending'
                                                        ? FursafyTheme.onSecondaryFixed
                                                        : FursafyTheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                          ).toList(),
                                        )
                                      ],
                                    ),
                                  ),

                                  // Provider logo + text
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: NetworkImage(logoUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              providerName,
                                              style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            Text(
                                              'Kinondoni',
                                              style: FursafyTheme.bodyStyle.copyWith(fontSize: 11, color: FursafyTheme.onSurfaceVariant),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),

                                  // Posted Date
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _formatDate(createdAt),
                                      style: FursafyTheme.bodyStyle.copyWith(fontSize: 13, color: FursafyTheme.onSurfaceVariant),
                                    ),
                                  ),

                                  // Moderation actions
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility_outlined, size: 20),
                                          onPressed: () => _showJobDetailsDialog(context, title, providerName, desc, payAmount.toDouble(), category),
                                          tooltip: 'View Details',
                                        ),
                                        const SizedBox(width: 8),
                                        if (isPending) ...[
                                          // Flag button
                                          ElevatedButton.icon(
                                            onPressed: () => widget.onJobAction(jobId, 'flag'),
                                            icon: const Icon(Icons.flag, size: 14),
                                            label: const Text('Flag'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: FursafyTheme.errorContainer,
                                              foregroundColor: FursafyTheme.error,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Approve button
                                          ElevatedButton.icon(
                                            onPressed: () => widget.onJobAction(jobId, 'approve'),
                                            icon: const Icon(Icons.check_circle_outline, size: 14),
                                            label: const Text('Approve'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: FursafyTheme.primary,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                            ),
                                          ),
                                        ] else if (isFlagged) ...[
                                          ElevatedButton(
                                            onPressed: () => widget.onJobAction(jobId, 'approve'),
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
                                            onPressed: () => widget.onJobAction(jobId, 'delete'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: FursafyTheme.error,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ] else ...[
                                          // History / Closed
                                          ElevatedButton(
                                            onPressed: () => widget.onJobAction(jobId, 'close'),
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
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                      // Pagination
                      if (totalPages > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          color: FursafyTheme.surfaceContainerLow,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Showing ${startIndex + 1}-${endIndex} of $totalFiltered listings requiring review',
                                style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, color: FursafyTheme.onSurfaceVariant, fontStyle: FontStyle.italic),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left, size: 20),
                                    onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                                  ),
                                  ...List.generate(totalPages, (index) {
                                    final isSelected = index == _currentPage;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: InkWell(
                                        onTap: () => setState(() => _currentPage = index),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: isSelected ? FursafyTheme.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : FursafyTheme.onSurfaceVariant,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right, size: 20),
                                    onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Bento Stats Grid (Editorial Scale)
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.2,
                  children: [
                    // Queue Velocity
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: FursafyTheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: FursafyTheme.primary.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.bolt, color: FursafyTheme.primary, size: 28),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Queue Velocity',
                                style: TextStyle(fontFamily: FursafyTheme.headlineFont, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Average moderation time has decreased by 14% this week.',
                                style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, color: FursafyTheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: const [
                              Text('4.2m', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: FursafyTheme.primary, letterSpacing: -1)),
                              SizedBox(width: 6),
                              Text('avg. review time', style: TextStyle(fontSize: 11, color: FursafyTheme.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Top Reviewer
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: FursafyTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.verified_user, color: FursafyTheme.secondary, size: 24),
                          Text(
                            'TOP REVIEWER',
                            style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline, letterSpacing: 1.2),
                          ),
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=150&q=80'),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fatuma M.', style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('84 reviews today', style: FursafyTheme.bodyStyle.copyWith(fontSize: 11, color: FursafyTheme.onSurfaceVariant)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Flag Rate
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: FursafyTheme.errorContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: FursafyTheme.error.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.report, color: FursafyTheme.error, size: 24),
                          Text(
                            'FLAG RATE',
                            style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.error, letterSpacing: 1.2),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${(flagRate * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: FursafyTheme.error)),
                              Text('+2% from last week', style: FursafyTheme.bodyStyle.copyWith(fontSize: 10, color: FursafyTheme.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _subTabButton(String label, String statusKey, {int? badgeCount}) {
    final isSelected = widget.jobFilterStatus == statusKey;
    return TextButton(
      onPressed: () {
        setState(() {
          _currentPage = 0;
        });
        widget.onJobFilterStatusChanged(statusKey);
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.only(bottom: 16),
        shape: const RoundedRectangleBorder(),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? FursafyTheme.primary : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Text(
              label,
              style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? FursafyTheme.primary : FursafyTheme.outline,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? FursafyTheme.primary.withValues(alpha: 0.1) : FursafyTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontFamily: FursafyTheme.bodyFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: isSelected ? FursafyTheme.primary : FursafyTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  void _showJobDetailsDialog(BuildContext context, String title, String provider, String desc, double pay, String category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FursafyTheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  void _showPostJobDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final payAmountController = TextEditingController();
    final locationController = TextEditingController(text: 'Kinondoni, Dar es Salaam');
    final skillsController = TextEditingController();
    String category = 'Tech';
    String payType = 'fixed';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: FursafyTheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Post New Opportunity',
            style: FursafyTheme.headlineStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Opportunity Title',
                        hintText: 'e.g. Graphic Designer, Assistant Mason',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the role, responsibilities, and requirements...',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'Tech', child: Text('Technology & Tech')),
                        DropdownMenuItem(value: 'Tutoring', child: Text('Academic & Tutoring')),
                        DropdownMenuItem(value: 'Cleaning', child: Text('Home Cleaning & Services')),
                        DropdownMenuItem(value: 'Construction', child: Text('Construction & Labor')),
                        DropdownMenuItem(value: 'Other', child: Text('Other Sectors')),
                      ],
                      onChanged: (val) {
                        if (val != null) category = val;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: payAmountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Pay Amount (TZS)',
                              hintText: 'e.g. 50000',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: payType,
                            decoration: const InputDecoration(labelText: 'Pay Type'),
                            items: const [
                              DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                              DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
                            ],
                            onChanged: (val) {
                              if (val != null) payType = val;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location Name',
                        hintText: 'e.g. Kinondoni, Dar es Salaam',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: skillsController,
                      decoration: const InputDecoration(
                        labelText: 'Skills Required (comma separated)',
                        hintText: 'e.g. Photoshop, Illustrator',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FursafyTheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final skillsList = skillsController.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();

                  final Map<String, dynamic> jobData = {
                    'providerId': 'admin_portal',
                    'providerName': 'Fursafy Admin',
                    'providerAvatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCCapGDi6ZqtA7fbJVA8YOlbXsJ9RcuW9X9JzFMRqlC3XBexBohqrDnaLhdKOYsfJxgbNG6K-NCG9bO0S9xR4RW5sGbxqHETn0n_VYIhL6M7FTOJGcm0VCmemzlu0198FQtf-rCQFG3akTfsq69k1jCcx_SGP9ZgW6KAKwgEwbCtIgqT8Qn6cKW4uVfFifcKNoAvRev2oquKeAhY0kysQ8uPSwsaU7nIQ1E-8x9l_J-4-qppif8fTHdM66tAOp2HDXpcxVciyDBbRWk',
                    'providerRating': 5.0,
                    'providerJobsDone': 42,
                    'title': titleController.text.trim(),
                    'description': descController.text.trim(),
                    'skillsRequired': skillsList,
                    'locationName': locationController.text.trim(),
                    'payAmount': double.parse(payAmountController.text.trim()),
                    'payType': payType,
                    'category': category,
                    'status': 'open',
                    'createdAt': Timestamp.now(),
                  };

                  widget.onJobAction('', 'post', jobData: jobData); // trigger reload or call direct repository save if BLoC is hooked
                  Navigator.pop(dialogCtx);
                }
              },
              child: const Text('Post Opportunity'),
            ),
          ],
        );
      },
    );
  }
}
