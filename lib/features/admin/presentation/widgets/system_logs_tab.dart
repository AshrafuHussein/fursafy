import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';

class SystemLogsTab extends StatefulWidget {
  const SystemLogsTab({super.key});

  @override
  State<SystemLogsTab> createState() => _SystemLogsTabState();
}

class _SystemLogsTabState extends State<SystemLogsTab> {
  String _selectedSeverity = 'all'; // all, info, warning, critical
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('system_logs')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: FursafyTheme.primary),
            ),
          );
        }

        final allDocs = snapshot.data?.docs ?? [];

        // Dynamic metrics
        final totalCount = allDocs.length;
        int activeErrors = allDocs.where((doc) {
          final severity = (doc.data()['severity'] ?? 'info').toString().toLowerCase();
          return severity == 'critical' || severity == 'error';
        }).length;

        // Filtering
        final filteredDocs = allDocs.where((doc) {
          final severity = (doc.data()['severity'] ?? 'info').toString().toLowerCase();
          if (_selectedSeverity == 'all') return true;
          if (_selectedSeverity == 'critical') return severity == 'critical' || severity == 'error';
          return severity == _selectedSeverity;
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

        // Severity Trend percentages
        int infoCount = allDocs.where((doc) => (doc.data()['severity'] ?? 'info').toString().toLowerCase() == 'info').length;
        int warnCount = allDocs.where((doc) => (doc.data()['severity'] ?? 'info').toString().toLowerCase() == 'warning').length;
        int errorCount = allDocs.where((doc) {
          final s = (doc.data()['severity'] ?? 'info').toString().toLowerCase();
          return s == 'error' || s == 'critical';
        }).length;

        double infoPct = totalCount > 0 ? (infoCount / totalCount) : 0.64;
        double warnPct = totalCount > 0 ? (warnCount / totalCount) : 0.25;
        double errorPct = totalCount > 0 ? (errorCount / totalCount) : 0.11;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Health/Error cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Logs Console',
                      style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: FursafyTheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Real-time monitoring of server events, database integrity, and authentication traffic.',
                      style: FursafyTheme.bodyStyle.copyWith(
                        fontSize: 15,
                        color: FursafyTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Health Score Box
                    _buildStatsCard(
                      label: 'Health Score',
                      value: '99.8%',
                      indicator: const Icon(Icons.check_circle, color: FursafyTheme.primary, size: 20),
                      bottomWidget: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: const LinearProgressIndicator(
                          value: 0.998,
                          backgroundColor: FursafyTheme.surfaceContainer,
                          color: FursafyTheme.primary,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Active Errors Box
                    _buildStatsCard(
                      label: 'Active Errors',
                      value: '$activeErrors',
                      indicator: const Icon(Icons.error, color: FursafyTheme.error, size: 20),
                      bottomWidget: Text(
                        '+2 since last hour',
                        style: FursafyTheme.bodyStyle.copyWith(
                          fontSize: 12,
                          color: FursafyTheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Filters Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _severityFilterButton('All Logs', 'all'),
                      const SizedBox(width: 8),
                      _severityFilterButton('Info', 'info'),
                      const SizedBox(width: 8),
                      _severityFilterButton('Warning', 'warning'),
                      const SizedBox(width: 8),
                      _severityFilterButton('Critical', 'critical', isCritical: true),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: FursafyTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: FursafyTheme.outline),
                            const SizedBox(width: 8),
                            Text(
                              'Last 24 Hours',
                              style: FursafyTheme.labelStyle.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: FursafyTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.download, size: 18),
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          backgroundColor: FursafyTheme.surfaceContainerLowest,
                          side: BorderSide(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Table Container
            Container(
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Headers
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    color: FursafyTheme.surfaceContainerLow.withValues(alpha: 0.5),
                    child: const Row(
                      children: [
                        Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                        Expanded(flex: 2, child: Text('EVENT ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                        Expanded(flex: 3, child: Text('TIMESTAMP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                        Expanded(flex: 8, child: Text('DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                        Expanded(flex: 2, child: SizedBox.shrink()),
                      ],
                    ),
                  ),

                  // Entries
                  if (paginatedDocs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Center(child: Text('No system logs found matching the filter.')),
                    )
                  else
                    Column(
                      children: paginatedDocs.map<Widget>((doc) {
                        final data = doc.data();
                        final severity = (data['severity'] ?? 'info').toString();
                        final eventId = data['eventId'] ?? 'EX-0000';
                        final title = data['title'] ?? 'System Event';
                        final desc = data['desc'] ?? '';
                        final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

                        Color severityBg = FursafyTheme.primary.withValues(alpha: 0.1);
                        Color severityFg = FursafyTheme.primary;
                        if (severity == 'critical' || severity == 'error') {
                          severityBg = FursafyTheme.error.withValues(alpha: 0.1);
                          severityFg = FursafyTheme.error;
                        } else if (severity == 'warning') {
                          severityBg = FursafyTheme.secondary.withValues(alpha: 0.1);
                          severityFg = FursafyTheme.secondary;
                        } else if (severity == 'sync') {
                          severityBg = FursafyTheme.primaryContainer.withValues(alpha: 0.1);
                          severityFg = FursafyTheme.primaryContainer;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: FursafyTheme.surfaceContainerLow)),
                          ),
                          child: Row(
                            children: [
                              // Status badge
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: severityBg,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      severity.toUpperCase(),
                                      style: FursafyTheme.labelStyle.copyWith(
                                        color: severityFg,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Event ID
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '#$eventId',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: FursafyTheme.outline,
                                  ),
                                ),
                              ),
                              // Timestamp
                              Expanded(
                                flex: 3,
                                child: Text(
                                  timestamp.toLocal().toString().substring(0, 19),
                                  style: FursafyTheme.bodyStyle.copyWith(
                                    fontSize: 12,
                                    color: FursafyTheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              // Description
                              Expanded(
                                flex: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: FursafyTheme.bodyStyle.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: FursafyTheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      desc,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: FursafyTheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Inspect Action
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text('Inspect'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  // Pagination Section
                  if (totalPages > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: const BoxDecoration(
                        color: FursafyTheme.surfaceContainerLow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${startIndex + 1}-$endIndex of $totalFiltered events',
                            style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, color: FursafyTheme.outline),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected ? FursafyTheme.primary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
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
            const SizedBox(height: 40),

            // Terminal-style Live Feed Aside & Severity trends
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dark Terminal
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                  ],
                                ),
                                const SizedBox(width: 24),
                                const Text(
                                  'fursafy-live-tail --follow',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: Colors.white30,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'LIVE STREAM',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Terminal text
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _terminalLine('14:05:01', 'Worker[3]:', 'Received JOB_SYNC_REQ for category \'Agriculture\''),
                              _terminalLine('14:05:05', 'AuthSvc:', 'JWT validated for user_id: 88291'),
                              _terminalLine('14:05:12', 'Gateway:', 'Incoming POST /api/v2/opportunities - status: 201'),
                              _terminalLine('14:05:18', 'DB_Cluster:', 'Latency spike detected on node-02 (+240ms)', isError: true),
                              _terminalLine('14:05:22', 'Storage:', 'S3 Upload success (profile_images/user_992.jpg)'),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  border: const Border(left: BorderSide(color: Colors.green, width: 3)),
                                ),
                                child: const Text(
                                  'SYSTEM_HEARTBEAT: ALL_MODULES_NOMINAL',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(
                                    '[14:05:25] Waiting for events...',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(width: 8, height: 16, color: Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 28),

                // Severity Trends & System Availability
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics, color: FursafyTheme.secondary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Severity Trends',
                              style: TextStyle(
                                fontFamily: FursafyTheme.headlineFont,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _severityTrendRow('INFO', infoPct, '$infoCount (${(infoPct * 100).toStringAsFixed(0)}%)', FursafyTheme.primary),
                        const SizedBox(height: 16),
                        _severityTrendRow('WARNING', warnPct, '$warnCount (${(warnPct * 100).toStringAsFixed(0)}%)', FursafyTheme.secondary),
                        const SizedBox(height: 16),
                        _severityTrendRow('ERROR', errorPct, '$errorCount (${(errorPct * 100).toStringAsFixed(0)}%)', FursafyTheme.error),

                        const SizedBox(height: 32),
                        // System Availability
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: FursafyTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'SYSTEM AVAILABILITY',
                                style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _bar(0.90, isError: false),
                                  _bar(0.95, isError: false),
                                  _bar(0.99, isError: false),
                                  _bar(0.92, isError: false),
                                  _bar(0.40, isError: true),
                                  _bar(0.96, isError: false),
                                  _bar(0.98, isError: false),
                                  _bar(0.99, isError: false),
                                  _bar(1.0, isError: false),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Downtime detected 4h ago (3m duration)',
                                style: FursafyTheme.bodyStyle.copyWith(fontSize: 11, color: FursafyTheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard({required String label, required String value, required Widget indicator, required Widget bottomWidget}) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: FursafyTheme.labelStyle.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: FursafyTheme.outline,
                  letterSpacing: 1.2,
                ),
              ),
              indicator,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: FursafyTheme.headlineStyle.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: FursafyTheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          bottomWidget,
        ],
      ),
    );
  }

  Widget _severityFilterButton(String label, String key, {bool isCritical = false}) {
    final isSelected = _selectedSeverity == key;
    Color bg = isSelected
        ? isCritical
            ? FursafyTheme.errorContainer
            : FursafyTheme.primary
        : FursafyTheme.surfaceContainerLowest;
    Color fg = isSelected
        ? isCritical
            ? FursafyTheme.error
            : Colors.white
        : FursafyTheme.onSurfaceVariant;

    return InkWell(
      onTap: () => setState(() {
        _selectedSeverity = key;
        _currentPage = 0;
      }),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            if (key == 'all') ...[
              Icon(Icons.filter_list, size: 14, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: FursafyTheme.labelStyle.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _terminalLine(String time, String tag, String message, {bool isError = false}) {
    Color timeColor = Colors.green;
    Color tagColor = isError ? Colors.redAccent : Colors.white70;
    Color msgColor = isError ? Colors.red.shade100 : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[$time] ',
            style: TextStyle(fontFamily: 'monospace', color: timeColor, fontSize: 12),
          ),
          Text(
            '$tag ',
            style: TextStyle(fontFamily: 'monospace', color: tagColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontFamily: 'monospace', color: msgColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _severityTrendRow(String title, double fraction, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: FursafyTheme.labelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: FursafyTheme.outline),
            ),
            Text(
              value,
              style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: FursafyTheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: FursafyTheme.surfaceContainer,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _bar(double fraction, {required bool isError}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        height: 48 * fraction,
        decoration: BoxDecoration(
          color: isError ? FursafyTheme.error : FursafyTheme.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ),
    );
  }
}
