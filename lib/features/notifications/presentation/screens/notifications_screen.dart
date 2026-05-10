import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fursafy/app/theme.dart';
import 'package:timeago/timeago.dart' as timeago;

/// S11 — Notifications screen.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('notifications')
          .doc(uid)
          .collection('items')
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get();

      setState(() {
        _notifications = snap.docs.map((d) {
          final data = d.data();
          data['id'] = d.id;
          return data;
        }).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'application_accepted':
        return Icons.check_circle_outline;
      case 'application_rejected':
        return Icons.cancel_outlined;
      case 'new_application':
        return Icons.person_add_outlined;
      case 'job_match':
        return Icons.work_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'application_accepted':
        return FursafyTheme.primary;
      case 'application_rejected':
        return FursafyTheme.error;
      case 'new_application':
        return FursafyTheme.secondary;
      case 'job_match':
        return FursafyTheme.primaryContainer;
      default:
        return FursafyTheme.onSurfaceVariant;
    }
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
          'Notifications',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: FursafyTheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FursafyTheme.primary))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_off_outlined,
                          size: 56, color: FursafyTheme.outlineVariant),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: FursafyTheme.headlineStyle.copyWith(
                          fontSize: 18,
                          color: FursafyTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: FursafyTheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _notifications.length,
                    itemBuilder: (ctx, i) {
                      final n = _notifications[i];
                      final type = n['type'] as String?;
                      final isRead = n['isRead'] == true;
                      final createdAt =
                          (n['createdAt'] as Timestamp?)?.toDate();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isRead
                              ? FursafyTheme.surfaceContainerLowest
                              : FursafyTheme.primaryFixed
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color:
                                  _colorForType(type).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_iconForType(type),
                                color: _colorForType(type), size: 22),
                          ),
                          title: Text(
                            n['message'] as String? ?? 'Notification',
                            style: FursafyTheme.bodyStyle.copyWith(
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.w700,
                              color: FursafyTheme.onSurface,
                            ),
                          ),
                          subtitle: createdAt != null
                              ? Text(
                                  timeago.format(createdAt),
                                  style: FursafyTheme.labelStyle.copyWith(
                                    color: FursafyTheme.onSurfaceVariant,
                                  ),
                                )
                              : null,
                          trailing: !isRead
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: FursafyTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
