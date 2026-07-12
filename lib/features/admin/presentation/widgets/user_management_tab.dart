import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';

class UserManagementTab extends StatefulWidget {
  final String userSearchQuery;
  final String userFilterRole;
  final ValueChanged<String> onUserFilterRoleChanged;
  final Function(String uid, String currentStatus) onUserStatusToggle;
  final Function(String email) onInviteAdmin;

  const UserManagementTab({
    super.key,
    required this.userSearchQuery,
    required this.userFilterRole,
    required this.onUserFilterRoleChanged,
    required this.onUserStatusToggle,
    required this.onInviteAdmin,
  });

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .orderBy('createdAt', descending: true)
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
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                'Error loading users: ${snapshot.error}',
                style: FursafyTheme.bodyStyle,
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // Aggregate statistics dynamically
        final totalCount = docs.length;
        int verifiedCount = 0;
        int pendingCount = 0;
        int activeNowCount = 0;

        for (var doc in docs) {
          final status = (doc.data()['status'] ?? 'active').toString().toLowerCase();
          if (status == 'active' || status == 'verified') {
            verifiedCount++;
          } else if (status == 'pending') {
            pendingCount++;
          }
          // Mock active now count (e.g. users with recent activity or 8% of total)
        }
        activeNowCount = (totalCount * 0.08).round().clamp(1, 1000);

        // Filter and Sort users
        var filteredDocs = docs.where((doc) {
          final data = doc.data();
          final name = (data['displayName'] ?? '').toString().toLowerCase();
          final role = (data['role'] ?? 'youth').toString().toLowerCase();
          final status = (data['status'] ?? 'active').toString().toLowerCase();

          // Search query filter
          if (widget.userSearchQuery.isNotEmpty && !name.contains(widget.userSearchQuery.toLowerCase())) {
            return false;
          }

          // Role/status filter tabs
          if (widget.userFilterRole == 'youth') {
            return role == 'youth';
          } else if (widget.userFilterRole == 'provider') {
            return role == 'provider';
          } else if (widget.userFilterRole == 'pending') {
            return status == 'pending';
          } else if (widget.userFilterRole == 'suspended') {
            return status == 'suspended';
          }

          return true;
        }).toList();

        // Sorting
        filteredDocs.sort((a, b) {
          final nameA = (a.data()['displayName'] ?? '').toString().toLowerCase();
          final nameB = (b.data()['displayName'] ?? '').toString().toLowerCase();
          return _sortAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
        });

        // Pagination calculations
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Invite admin row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Management',
                      style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: FursafyTheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Oversee the growth of the Fursafy community. Verify and moderate identities.',
                      style: FursafyTheme.bodyStyle.copyWith(
                        fontSize: 15,
                        color: FursafyTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showInviteAdminDialog(context),
                  icon: const Icon(Icons.person_add_alt_1, size: 16),
                  label: const Text('Invite Administrator'),
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

            // Statistics boxes row
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              children: [
                _statsBentoCard('Total Users', '$totalCount', '+12%', isPrimaryColor: true),
                _statsBentoCard('Verified', '$verifiedCount', '${totalCount > 0 ? ((verifiedCount / totalCount) * 100).toStringAsFixed(0) : 71}%', isPrimaryColor: false),
                _statsBentoCard('Pending', '$pendingCount', 'High', isPrimaryColor: false, isAmberColor: true),
                _statsBentoCard('Active Now', '$activeNowCount', '', isPrimaryColor: false, isPulse: true),
              ],
            ),
            const SizedBox(height: 32),

            // Main Table Container
            Container(
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filter Toolbar
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'FILTER BY:',
                              style: FursafyTheme.labelStyle.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: FursafyTheme.onSurfaceVariant,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 16),
                            _filterChipButton('All Users', 'all'),
                            const SizedBox(width: 8),
                            _filterChipButton('Youth Workers', 'youth'),
                            const SizedBox(width: 8),
                            _filterChipButton('Job Providers', 'provider'),
                            const SizedBox(width: 8),
                            _filterChipButton('Pending Verification', 'pending', isAmber: true),
                            const SizedBox(width: 8),
                            _filterChipButton('Suspended', 'suspended'),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _sortAscending = !_sortAscending;
                                });
                              },
                              icon: const Icon(Icons.sort, size: 18),
                              label: const Text('Sort'),
                              style: TextButton.styleFrom(
                                foregroundColor: FursafyTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Export CSV'),
                              style: TextButton.styleFrom(
                                foregroundColor: FursafyTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Data Table
                  if (paginatedDocs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Center(
                        child: Text(
                          'No users match the search or filter query.',
                          style: TextStyle(fontFamily: FursafyTheme.bodyFont),
                        ),
                      ),
                    )
                  else
                    DataTable(
                      headingRowColor: WidgetStateProperty.all(FursafyTheme.surfaceContainerLow.withValues(alpha: 0.5)),
                      dataRowMinHeight: 72,
                      dataRowMaxHeight: 72,
                      horizontalMargin: 24,
                      columns: const [
                        DataColumn(label: Text('NAME & IDENTITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                        DataColumn(label: Text('ROLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                        DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                        DataColumn(label: Text('JOIN DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                        DataColumn(label: Text('', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                      ],
                      rows: paginatedDocs.map<DataRow>((doc) {
                        final data = doc.data();
                        final uid = doc.id;
                        final name = data['displayName'] ?? 'No Name';
                        final email = data['email'] ?? 'No Email';
                        final role = (data['role'] ?? 'youth').toString();
                        final status = (data['status'] ?? 'active').toString();

                        // Get random/consistent Unsplash avatar image
                        final avatarUrl = role == 'youth'
                            ? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80'
                            : 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=150&q=80';

                        final isPending = status == 'pending';
                        final isSuspended = status == 'suspended';

                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(avatarUrl),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        name,
                                        style: FursafyTheme.bodyStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        email,
                                        style: FursafyTheme.bodyStyle.copyWith(
                                          color: FursafyTheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: FursafyTheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      role == 'youth' ? Icons.school : Icons.business,
                                      size: 14,
                                      color: FursafyTheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      role == 'youth' ? 'Youth Worker' : 'Job Provider',
                                      style: FursafyTheme.labelStyle.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: FursafyTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSuspended
                                      ? FursafyTheme.error.withValues(alpha: 0.1)
                                      : isPending
                                          ? FursafyTheme.secondary.withValues(alpha: 0.1)
                                          : FursafyTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: FursafyTheme.labelStyle.copyWith(
                                    color: isSuspended
                                        ? FursafyTheme.error
                                        : isPending
                                            ? FursafyTheme.secondary
                                            : FursafyTheme.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                'Oct 12, 2023',
                                style: FursafyTheme.bodyStyle.copyWith(
                                  color: FursafyTheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (isPending)
                                    ElevatedButton(
                                      onPressed: () => _showVerifyUserModal(context, name, uid),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: FursafyTheme.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Verify Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    )
                                  else ...[
                                    IconButton(
                                      icon: const Icon(Icons.visibility, size: 20),
                                      onPressed: () {},
                                      color: FursafyTheme.onSurfaceVariant,
                                      tooltip: 'View Details',
                                    ),
                                    IconButton(
                                      icon: Icon(isSuspended ? Icons.check_circle : Icons.block, size: 20),
                                      onPressed: () => _showSuspendUserModal(context, name, uid, status),
                                      color: isSuspended ? FursafyTheme.primary : FursafyTheme.error,
                                      tooltip: isSuspended ? 'Activate' : 'Suspend',
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),

                  // Pagination Section
                  if (totalPages > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: FursafyTheme.surfaceContainerLow.withValues(alpha: 0.3),
                        border: const Border(top: BorderSide(color: FursafyTheme.surfaceContainerHigh)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${startIndex + 1}-${endIndex} of $totalFiltered users',
                            style: FursafyTheme.bodyStyle.copyWith(
                              fontSize: 13,
                              color: FursafyTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.first_page, size: 20),
                                onPressed: _currentPage > 0 ? () => setState(() => _currentPage = 0) : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_left, size: 20),
                                onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                              ),
                              const SizedBox(width: 8),
                              ...List.generate(totalPages, (index) {
                                if (totalPages > 5 && (index > 2 && index < totalPages - 1)) {
                                  if (index == 3) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('...'),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }
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
                                          fontFamily: FursafyTheme.bodyFont,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isSelected ? Colors.white : FursafyTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, size: 20),
                                onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.last_page, size: 20),
                                onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage = totalPages - 1) : null,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Bottom Section: Verification Spotlight (2/3) + Quick Insights (1/3)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verification Spotlight
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [FursafyTheme.primary, FursafyTheme.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Opacity(
                            opacity: 0.1,
                            child: Icon(
                              Icons.verified_user,
                              size: 160,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verification Spotlight',
                              style: FursafyTheme.headlineStyle.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'System flags show a 15% increase in job provider sign-ups this week. Automated verification is processing 80% of applicants; 412 users require manual review of credentials.',
                              style: FursafyTheme.bodyStyle.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                widget.onUserFilterRoleChanged('pending');
                              },
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              label: const Text('Go to Queue'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FursafyTheme.surfaceBright,
                                foregroundColor: FursafyTheme.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 28),

                // Quick Insights
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerLow.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Insights',
                          style: FursafyTheme.headlineStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: FursafyTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _insightRow(Icons.trending_up, 'Growth Spike', 'In Dar es Salaam region', FursafyTheme.secondary),
                        const SizedBox(height: 16),
                        _insightRow(Icons.groups, 'Engagement', 'Daily active users +8%', FursafyTheme.primary),
                        const SizedBox(height: 16),
                        _insightRow(Icons.priority_high, 'Support Load', '14 tickets pending', FursafyTheme.tertiary),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _statsBentoCard(String title, String count, String trend, {required bool isPrimaryColor, bool isAmberColor = false, bool isPulse = false}) {
    Color titleColor = FursafyTheme.onSurfaceVariant;
    Color countColor = isPrimaryColor
        ? FursafyTheme.primary
        : isAmberColor
            ? FursafyTheme.secondary
            : FursafyTheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: FursafyTheme.labelStyle.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: titleColor,
              letterSpacing: 1.2,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                count,
                style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: countColor,
                ),
              ),
              if (trend.isNotEmpty) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPrimaryColor ? FursafyTheme.primary : FursafyTheme.secondary,
                    ),
                  ),
                ),
              ],
              if (isPulse) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: FursafyTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ]
            ],
          )
        ],
      ),
    );
  }

  Widget _filterChipButton(String label, String filterKey, {bool isAmber = false}) {
    final isSelected = widget.userFilterRole == filterKey;
    Color bg = isSelected
        ? isAmber
            ? FursafyTheme.secondaryFixed
            : FursafyTheme.primaryFixed
        : FursafyTheme.surfaceContainer;
    Color fg = isSelected
        ? isAmber
            ? FursafyTheme.onSecondaryFixed
            : FursafyTheme.onPrimaryFixed
        : FursafyTheme.onSurfaceVariant;

    return InkWell(
      onTap: () => widget.onUserFilterRoleChanged(filterKey),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAmber && isSelected) ...[
              const Icon(Icons.pending_actions, size: 14, color: FursafyTheme.onSecondaryFixed),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: FursafyTheme.labelStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightRow(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FursafyTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: FursafyTheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: FursafyTheme.bodyStyle.copyWith(
                fontSize: 12,
                color: FursafyTheme.onSurfaceVariant,
              ),
            ),
          ],
        )
      ],
    );
  }

  void _showInviteAdminDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FursafyTheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Invite Administrator', style: FursafyTheme.headlineStyle.copyWith(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              hintText: 'Enter email address...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FursafyTheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  widget.onInviteAdmin(email);
                  Navigator.pop(context);
                }
              },
              child: const Text('Send Invitation'),
            ),
          ],
        );
      },
    );
  }

  // Verify User Modal matching Design exactly!
  void _showVerifyUserModal(BuildContext context, String name, String uid) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              color: FursafyTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Teal background)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: const BoxDecoration(
                    color: FursafyTheme.primary,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verify User',
                            style: FursafyTheme.headlineStyle.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Application ID: #VF-${uid.substring(0, 4).toUpperCase()}',
                            style: FursafyTheme.labelStyle.copyWith(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Body content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80'),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: FursafyTheme.headlineStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Applied: Oct 24, 2023 • Dar es Salaam',
                                style: FursafyTheme.bodyStyle.copyWith(
                                  color: FursafyTheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'DOCUMENT PREVIEW',
                        style: FursafyTheme.labelStyle.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: FursafyTheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Mock National ID Image preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1554774853-aae0a22c8aa4?auto=format&fit=crop&w=600&q=80',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onUserStatusToggle(uid, 'pending'); // Set state back/toggle
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: FursafyTheme.error,
                              side: const BorderSide(color: FursafyTheme.error),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                            child: const Text('Reject Case'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onUserStatusToggle(uid, 'pending'); // Marks active
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FursafyTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                            child: const Text('Approve'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Suspend User Modal matching Design exactly!
  void _showSuspendUserModal(BuildContext context, String name, String uid, String currentStatus) {
    if (currentStatus == 'suspended') {
      widget.onUserStatusToggle(uid, currentStatus);
      return;
    }

    String selectedReason = 'Terms of Service Violation';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FursafyTheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: FursafyTheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: FursafyTheme.error, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                'Suspend Account',
                style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You are about to restrict access for $name. This action is reversible.',
                textAlign: TextAlign.center,
                style: FursafyTheme.bodyStyle.copyWith(
                  color: FursafyTheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'REASON FOR SUSPENSION',
                  style: FursafyTheme.labelStyle.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: FursafyTheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedReason,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Terms of Service Violation', child: Text('Terms of Service Violation')),
                  DropdownMenuItem(value: 'Fraudulent Activity', child: Text('Fraudulent Activity')),
                  DropdownMenuItem(value: 'Spam / Harassment', child: Text('Spam / Harassment')),
                ],
                onChanged: (val) {
                  if (val != null) selectedReason = val;
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'INTERNAL NOTES',
                  style: FursafyTheme.labelStyle.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: FursafyTheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Provide detailed context for this action...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onUserStatusToggle(uid, currentStatus);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FursafyTheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: const Text('Confirm Suspension'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
