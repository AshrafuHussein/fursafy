import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/core/constants/app_constants.dart';

/// Admin Dashboard Screen (Web Optimized) — Sourced from Stitch MCP "Digital Curator" design system.
///
/// Layout:
/// - Sidebar: Sidebar navigation tabs (Overview, Users, Jobs).
/// - Main Content Area: Responsive bento analytics grid, interactive tables, and control modals.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _activeTabIndex = 0; // 0: Overview, 1: Users, 2: Jobs
  bool _loading = false;
  
  // Stats counters
  int _totalUsers = 0;
  int _totalJobs = 0;
  int _totalApplications = 0;
  int _completedJobs = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _loading = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final results = await Future.wait([
        firestore.collection(FirestorePaths.users).get(),
        firestore.collection(FirestorePaths.jobs).get(),
        firestore.collection(FirestorePaths.applications).get(),
      ]);

      final usersSnap = results[0];
      final jobsSnap = results[1];
      final appsSnap = results[2];

      int completedCount = 0;
      for (var doc in appsSnap.docs) {
        if (doc.data()['status'] == 'accepted') {
          completedCount++;
        }
      }

      if (!mounted) return;
      setState(() {
        _totalUsers = usersSnap.docs.length;
        _totalJobs = jobsSnap.docs.length;
        _totalApplications = appsSnap.docs.length;
        _completedJobs = completedCount;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleUserStatus(String uid, String currentStatus) async {
    final newStatus = currentStatus == 'suspended' ? 'active' : 'suspended';
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({'status': newStatus});
      
      // Also update the matching youth_profiles document status if it exists
      final youthRef = FirebaseFirestore.instance.collection(FirestorePaths.youthProfiles).doc(uid);
      final youthDoc = await youthRef.get();
      if (youthDoc.exists) {
        await youthRef.update({'status': newStatus == 'active' ? 'available' : 'inactive'});
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User status updated to $newStatus'),
          backgroundColor: FursafyTheme.primary,
        ),
      );
      _fetchStats(); // refresh counts
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user: $e'),
          backgroundColor: FursafyTheme.error,
        ),
      );
    }
  }

  Future<void> _moderateJob(String jobId, String action) async {
    try {
      final jobRef = FirebaseFirestore.instance.collection(FirestorePaths.jobs).doc(jobId);
      if (action == 'delete') {
        await jobRef.delete();
      } else if (action == 'close') {
        await jobRef.update({'status': 'closed'});
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job Listing $action success'),
          backgroundColor: FursafyTheme.primary,
        ),
      );
      _fetchStats(); // refresh counts
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Action failed: $e'),
          backgroundColor: FursafyTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      body: Row(
        children: [
          // Sticky left navigation sidebar (Digital Curator theme)
          _buildSidebar(),

          // Main content area
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: FursafyTheme.primary))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 32),
                          Expanded(
                            child: _buildMainView(),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(
            color: FursafyTheme.outlineVariant.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 40, 24, 40),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: FursafyTheme.primary,
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'FURSAFY',
                  style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: FursafyTheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          _sidebarItem(0, 'System Overview', Icons.analytics_outlined),
          _sidebarItem(1, 'User Accounts', Icons.people_outline),
          _sidebarItem(2, 'Job Listings', Icons.work_outline),

          const Spacer(),

          // Admin user profile info at bottom
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Logged in as Admin',
                  style: FursafyTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: FursafyTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!mounted) return;
                    context.go(AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout, size: 16, color: Colors.redAccent),
                  label: Text(
                    'Sign Out',
                    style: FursafyTheme.bodyStyle.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, String title, IconData icon) {
    final isActive = _activeTabIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => setState(() => _activeTabIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? FursafyTheme.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? FursafyTheme.primary : FursafyTheme.outline,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: FursafyTheme.bodyStyle.copyWith(
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive ? FursafyTheme.onSurface : FursafyTheme.outline,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = 'System Overview';
    String subtitle = 'Bento analytics and real-time operations overview.';
    if (_activeTabIndex == 1) {
      title = 'User Accounts';
      subtitle = 'Manage youth workers and job providers details and status.';
    } else if (_activeTabIndex == 2) {
      title = 'Job Listings';
      subtitle = 'Moderate and clean up platform job listings.';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: FursafyTheme.bodyStyle.copyWith(
                color: FursafyTheme.onSurfaceVariant,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // Refresh Button
        IconButton(
          icon: const Icon(Icons.refresh, color: FursafyTheme.primary),
          onPressed: _fetchStats,
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  Widget _buildMainView() {
    switch (_activeTabIndex) {
      case 0:
        return _buildOverviewGrid();
      case 1:
        return _buildUserManagementView();
      case 2:
        return _buildJobManagementView();
      default:
        return _buildOverviewGrid();
    }
  }

  Widget _buildOverviewGrid() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bento Grid Statistics (matching Stitch layout rules)
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              return GridView.count(
                crossAxisCount: isDesktop ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.6,
                children: [
                  _bentoStatCard('group', 'Total Users', '$_totalUsers', FursafyTheme.primary),
                  _bentoStatCard('work', 'Active Listings', '$_totalJobs', FursafyTheme.secondary),
                  _bentoStatCard('description', 'Applications', '$_totalApplications', FursafyTheme.tertiary),
                  _bentoStatCard('check_circle', 'Completed Jobs', '$_completedJobs', FursafyTheme.primaryContainer),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Overview Graph Placeholder / System Health panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: FursafyTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: FursafyTheme.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM HEALTH STATUS',
                  style: FursafyTheme.labelStyle.copyWith(
                    fontSize: 11,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w700,
                    color: FursafyTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.cloud_done, color: FursafyTheme.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'All Firebase services (Auth, DB, Functions) operational',
                      style: FursafyTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bentoStatCard(String iconName, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FursafyTheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: FursafyTheme.labelStyle.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: FursafyTheme.onSurfaceVariant,
                ),
              ),
              Icon(_getIconData(iconName), color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: FursafyTheme.headlineStyle.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: FursafyTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'group':
        return Icons.group;
      case 'work':
        return Icons.work;
      case 'description':
        return Icons.description;
      case 'check_circle':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Widget _buildUserManagementView() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: FursafyTheme.primary));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading users: ${snapshot.error}'));
        }

        final users = snapshot.data?.docs ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('No users registered on the platform.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final data = users[index].data();
            final uid = users[index].id;
            final name = data['displayName'] ?? 'No Name';
            final email = data['email'] ?? 'No Email';
            final role = data['role'] ?? 'youth';
            final status = data['status'] ?? 'active';

            final isSuspended = status == 'suspended';
            final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FursafyTheme.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSuspended ? FursafyTheme.error.withValues(alpha: 0.1) : FursafyTheme.primary.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: FursafyTheme.headlineStyle.copyWith(
                        color: isSuspended ? FursafyTheme.error : FursafyTheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: FursafyTheme.headlineStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: FursafyTheme.onSurface,
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
                                role.toUpperCase(),
                                style: FursafyTheme.labelStyle.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: FursafyTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          email,
                          style: FursafyTheme.bodyStyle.copyWith(
                            fontSize: 13,
                            color: FursafyTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSuspended ? FursafyTheme.error.withValues(alpha: 0.1) : FursafyTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: FursafyTheme.labelStyle.copyWith(
                        color: isSuspended ? FursafyTheme.error : FursafyTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _toggleUserStatus(uid, status),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuspended ? FursafyTheme.primary : FursafyTheme.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      isSuspended ? 'Activate' : 'Suspend',
                      style: FursafyTheme.bodyStyle.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJobManagementView() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(FirestorePaths.jobs)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: FursafyTheme.primary));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading jobs: ${snapshot.error}'));
        }

        final jobs = snapshot.data?.docs ?? [];
        if (jobs.isEmpty) {
          return const Center(child: Text('No jobs listed on the platform.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final data = jobs[index].data();
            final jobId = jobs[index].id;
            final title = data['title'] ?? 'No Title';
            final providerName = data['providerName'] ?? 'Unknown';
            final category = data['category'] ?? 'Other';
            final status = data['status'] ?? 'open';
            final payAmount = (data['payAmount'] ?? 0.0) as double;
            final payType = data['payType'] ?? 'fixed';

            final isClosed = status == 'closed';
            final payLabel = '${payAmount.toStringAsFixed(0)} TZS${payType == 'hourly' ? '/hr' : ''}';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FursafyTheme.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isClosed ? FursafyTheme.outlineVariant.withValues(alpha: 0.15) : FursafyTheme.secondary.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _getCategoryIcon(category),
                      color: isClosed ? FursafyTheme.outline : FursafyTheme.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: FursafyTheme.headlineStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: FursafyTheme.onSurface,
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
                                  fontWeight: FontWeight.bold,
                                  color: FursafyTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Posted by $providerName',
                              style: FursafyTheme.bodyStyle.copyWith(
                                fontSize: 13,
                                color: FursafyTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: FursafyTheme.outlineVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              payLabel,
                              style: FursafyTheme.bodyStyle.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: FursafyTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isClosed ? FursafyTheme.outlineVariant.withValues(alpha: 0.15) : FursafyTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: FursafyTheme.labelStyle.copyWith(
                        color: isClosed ? FursafyTheme.outline : FursafyTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isClosed) ...[
                        ElevatedButton(
                          onPressed: () => _moderateJob(jobId, 'close'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FursafyTheme.secondary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          child: Text(
                            'Close',
                            style: FursafyTheme.bodyStyle.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      ElevatedButton(
                        onPressed: () => _moderateJob(jobId, 'delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FursafyTheme.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        child: Text(
                          'Delete',
                          style: FursafyTheme.bodyStyle.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
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
