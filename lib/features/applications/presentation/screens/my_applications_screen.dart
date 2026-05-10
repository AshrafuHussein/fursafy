import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/applications/domain/entities/application_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

/// S10 — My Applications screen (Youth).
class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<ApplicationEntity> _applications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection(FirestorePaths.applications)
          .where('youthId', isEqualTo: uid)
          .orderBy('appliedAt', descending: true)
          .get();

      setState(() {
        _applications = snap.docs
            .map((d) => ApplicationEntity.fromMap(d.id, d.data()))
            .toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<ApplicationEntity> _filtered(ApplicationStatus? status) {
    if (status == null) return _applications;
    return _applications.where((a) => a.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FursafyTheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Applications',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: FursafyTheme.onSurface,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: FursafyTheme.primary,
          unselectedLabelColor: FursafyTheme.onSurfaceVariant,
          indicatorColor: FursafyTheme.primary,
          labelStyle:
              FursafyTheme.labelStyle.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: FursafyTheme.labelStyle,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FursafyTheme.primary))
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildList(null),
                _buildList(ApplicationStatus.pending),
                _buildList(ApplicationStatus.accepted),
              ],
            ),
    );
  }

  Widget _buildList(ApplicationStatus? status) {
    final apps = _filtered(status);
    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 56, color: FursafyTheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'No applications yet',
              style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 18,
                color: FursafyTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApplications,
      color: FursafyTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: apps.length,
        itemBuilder: (context, i) => _appTile(apps[i]),
      ),
    );
  }

  Widget _appTile(ApplicationEntity app) {
    Color statusColor;
    IconData statusIcon;
    switch (app.status) {
      case ApplicationStatus.accepted:
        statusColor = FursafyTheme.primary;
        statusIcon = Icons.check_circle;
        break;
      case ApplicationStatus.rejected:
        statusColor = FursafyTheme.error;
        statusIcon = Icons.cancel;
        break;
      case ApplicationStatus.withdrawn:
        statusColor = FursafyTheme.outline;
        statusIcon = Icons.undo;
        break;
      default:
        statusColor = FursafyTheme.secondary;
        statusIcon = Icons.access_time;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: FursafyTheme.ambientShadow,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () => context.push('/jobs/${app.jobId}'),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(statusIcon, color: statusColor, size: 22),
        ),
        title: Text(
          app.jobTitle,
          style: FursafyTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: FursafyTheme.onSurface,
          ),
        ),
        subtitle: Text(
          'Applied ${timeago.format(app.appliedAt)}',
          style: FursafyTheme.labelStyle.copyWith(
            color: FursafyTheme.onSurfaceVariant,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            app.status.name[0].toUpperCase() + app.status.name.substring(1),
            style: FursafyTheme.labelStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }
}
