import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:fursafy/features/admin/presentation/bloc/admin_event.dart';
import 'package:fursafy/features/admin/presentation/bloc/admin_state.dart';

// Extracted UI Components
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_app_bar.dart';
import '../widgets/dashboard_overview_tab.dart';
import '../widgets/job_moderation_tab.dart';
import '../widgets/analytics_reports_tab.dart';
import '../widgets/user_management_tab.dart';
import '../widgets/financial_oversight_tab.dart';
import '../widgets/system_logs_tab.dart';
import '../widgets/configuration_hub_tab.dart';

/// Admin Dashboard Screen (Web Optimized) — Orchestrates the modular widgets of the admin portal.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _activeTabIndex = 0; // 0: Dashboard, 1: Opportunities (Jobs), 2: Analytics, 3: Users, 4: Financials, 5: Logs, 6: Settings

  // Search & Filter state
  String _userSearchQuery = '';
  String _userFilterRole = 'all'; // all, youth, provider, suspended
  String _jobSearchQuery = '';
  String _jobFilterStatus = 'pending'; // pending, flagged, history

  @override
  void initState() {
    super.initState();
    // Dispatch initial load requests
    _refresh();
  }

  void _refresh() {
    context.read<AdminBloc>().add(AdminStatsFetchRequested());
    context.read<AdminBloc>().add(AdminPlatformConfigLoadRequested());
    context.read<AdminBloc>().add(AdminWeeklySignupsFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: FursafyTheme.primary,
            ),
          );
          // Auto refresh stats/config/weekly on successful operations
          _refresh();
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: FursafyTheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: FursafyTheme.surface,
        body: Row(
          children: [
            // Sidebar Navigation
            AdminSidebar(
              activeTabIndex: _activeTabIndex,
              onTabChanged: (index) {
                setState(() => _activeTabIndex = index);
              },
            ),

            // Main Space containing TopAppBar and active Tab contents
            Expanded(
              child: Column(
                children: [
                  AdminTopAppBar(
                    onSearchChanged: (val) {
                      setState(() {
                        _userSearchQuery = val;
                        _jobSearchQuery = val;
                      });
                    },
                    onRefresh: _refresh,
                  ),
                  Expanded(
                    child: BlocBuilder<AdminBloc, AdminState>(
                      builder: (context, state) {
                        if (state.isLoading && _activeTabIndex != 1 && _activeTabIndex != 3 && _activeTabIndex != 5) {
                          // Only show full-screen loader for non-streaming pages on initial loads
                          return const Center(child: CircularProgressIndicator(color: FursafyTheme.primary));
                        }

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(40),
                          child: _buildTabView(state),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabView(AdminState state) {
    switch (_activeTabIndex) {
      case 0:
        return DashboardOverviewTab(
          totalUsers: state.totalUsers,
          totalJobs: state.totalJobs,
          totalApplications: state.totalApplications,
          completedJobs: state.completedJobs,
          flaggedJobsCount: state.flaggedJobsCount,
          totalTxVolume: state.totalTxVolume,
          weeklyJobsData: state.weeklyJobsData,
          onVerifyUsers: () => setState(() => _activeTabIndex = 3),
          onModerateListings: () => setState(() => _activeTabIndex = 1),
          onSystemLogs: () => setState(() => _activeTabIndex = 5),
        );
      case 1:
        return JobModerationTab(
          jobSearchQuery: _jobSearchQuery,
          jobFilterStatus: _jobFilterStatus,
          onJobFilterStatusChanged: (val) => setState(() => _jobFilterStatus = val),
          onJobAction: (jobId, action) {
            context.read<AdminBloc>().add(AdminJobModerateRequested(jobId: jobId, action: action));
          },
        );
      case 2:
        return AnalyticsReportsTab(
          totalJobs: state.totalJobs,
          completedJobs: state.completedJobs,
          totalApplications: state.totalApplications,
          totalProviders: state.totalProviders,
        );
      case 3:
        return UserManagementTab(
          userSearchQuery: _userSearchQuery,
          userFilterRole: _userFilterRole,
          onUserFilterRoleChanged: (val) => setState(() => _userFilterRole = val),
          onUserStatusToggle: (uid, status) {
            context.read<AdminBloc>().add(AdminUserStatusToggleRequested(uid: uid, currentStatus: status));
          },
          onInviteAdmin: (email) {
            context.read<AdminBloc>().add(AdminInviteRequested(email));
          },
        );
      case 4:
        final platformFee = (state.platformConfig['platformFee'] ?? 3.0) as double;
        return FinancialOversightTab(
          totalTxVolume: state.totalTxVolume,
          platformFeesPercentage: platformFee,
          completedJobs: state.completedJobs,
        );
      case 5:
        return const SystemLogsTab();
      case 6:
        return ConfigurationHubTab(
          initialConfig: state.platformConfig,
          onSaveConfig: (updatedConfig) {
            context.read<AdminBloc>().add(AdminPlatformConfigSaveRequested(updatedConfig));
          },
        );
      default:
        return const Center(child: Text('Under Construction'));
    }
  }
}
