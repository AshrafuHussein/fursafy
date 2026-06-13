import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fursafy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fursafy/app/router.dart';

/// Top-level background message handler — must be a top-level function.
/// Firebase requires this to be outside any class.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
  // No-op: Firestore already has the notification document.
  // The UI will pick it up on next app open via NotificationBloc.
}

/// Singleton service for FCM push notification lifecycle.
///
/// Handles:
/// - Permission request (iOS + Android 13+)
/// - FCM token retrieval and refresh
/// - Foreground message handling (in-app overlay banner)
/// - Background/terminated message tap → deep-link navigation
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Global key for showing overlay banners from anywhere.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// True when the app was launched by tapping a push notification
  /// (from a terminated state). The splash screen checks this to
  /// skip its delayed redirect so the notification navigation isn't overridden.
  bool launchedFromNotification = false;

  /// Callback invoked when a foreground message arrives.
  /// Set by NotificationBloc to inject new notifications reactively.
  void Function(RemoteMessage message)? onForegroundMessage;

  /// Initialize FCM — call once after Firebase.initializeApp().
  Future<void> initialize() async {
    // 0. Initialize local notifications for foreground system tray display
    await _initLocalNotifications();

    // 1. Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Request permission (iOS + Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

    // Request runtime notification permission on Android 13+
    try {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('[FCM] Android local notification permission requested: $granted');
      }
    } catch (e) {
      debugPrint('[FCM] Error requesting Android permission: $e');
    }

    // 3. Get initial FCM token and save to Firestore
    //    FIS may not be ready on cold start — retry once after a short delay.
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[FCM] Token acquired');
        await _saveToken(token);
      }
    } catch (e) {
      debugPrint('[FCM] Token error: $e');
      // Retry after 3 seconds — gives FIS time to initialize
      Future.delayed(const Duration(seconds: 3), () async {
        try {
          final token = await _messaging.getToken();
          if (token != null) {
            debugPrint('[FCM] Token acquired (retry)');
            await _saveToken(token);
          }
        } catch (e2) {
          debugPrint('[FCM] Token retry failed: $e2');
        }
      });
    }

    // 4. Listen for token refresh
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed');
      _saveToken(newToken);
    });

    // 5. Handle foreground messages — show in-app banner
    _foregroundSub =
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 6. Handle background message tap (app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // 7. Handle terminated-state launch from notification tap
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      launchedFromNotification = true;
      // Delay slightly to let the router initialize
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleMessageTap(initialMessage, fromTerminated: true);
      });
    }
  }

  /// Save FCM token to Firestore for the current user.
  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await AuthRepositoryImpl().updateFcmToken(uid, token);
      debugPrint('[FCM] Token saved for uid=$uid');
    } catch (e) {
      debugPrint('[FCM] Failed to save token: $e');
    }
  }

  /// Re-save FCM token after authentication (called from AuthBloc).
  Future<void> refreshTokenForUser(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await AuthRepositoryImpl().updateFcmToken(uid, token);
        debugPrint('[FCM] Token refreshed for uid=$uid');
      }
    } catch (e) {
      debugPrint('[FCM] Failed to refresh token for user: $e');
    }
  }

  /// Initialize flutter_local_notifications for foreground system tray display.
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/fursafy');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap from system tray
        final screen = response.payload;
        if (screen != null && screen.isNotEmpty) {
          try {
            appRouter.push(screen);
          } catch (e) {
            debugPrint('[LocalNotif] Navigation failed: $e');
            // Fall back to notifications screen
            appRouter.go('/notifications');
          }
        } else {
          // No specific screen — open the notifications page
          appRouter.go('/notifications');
        }
      },
    );

    // Create the notification channel for Android 8+
    const channel = AndroidNotificationChannel(
      'fursafy_jobs', // must match AndroidManifest meta-data value
      'Fursafy Jobs',
      description: 'Notifications for job matches, applications, and updates',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Show a system tray notification using flutter_local_notifications.
  Future<void> _showSystemNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'fursafy_jobs', // channel ID — matches the channel created above
      'Fursafy Jobs',
      channelDescription:
          'Notifications for job matches, applications, and updates',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/fursafy',
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode, // unique ID per notification
      notification.title ?? 'Fursafy',
      notification.body ?? '',
      details,
      payload: message.data['screen'] as String?, // for tap navigation
    );
  }

  /// Handle foreground message — show system notification + in-app overlay banner.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground message: ${message.notification?.title}');

    // Show system tray notification
    _showSystemNotification(message);

    // Notify the bloc so it can add the notification to state
    onForegroundMessage?.call(message);

    // Show in-app overlay banner
    final context = navigatorKey.currentContext;
    if (context != null) {
      _showInAppBanner(context, message);
    }
  }

  /// Handle notification tap → deep-link to the correct screen.
  ///
  /// [fromTerminated] — true when the app was launched from a terminated
  /// state by tapping a notification. Uses `go()` instead of `push()` to
  /// replace the splash route entirely (preventing the splash redirect
  /// from overriding the navigation later).
  void _handleMessageTap(RemoteMessage message, {bool fromTerminated = false}) {
    final screen = message.data['screen'] as String?;
    debugPrint('[FCM] Message tap → navigate to: $screen (fromTerminated=$fromTerminated)');

    if (screen != null && screen.isNotEmpty) {
      try {
        // From terminated state: use go() to replace splash route
        // From background: use push() to stack on current route
        if (fromTerminated) {
          appRouter.go(screen);
        } else {
          appRouter.push(screen);
        }
      } catch (e) {
        debugPrint('[FCM] Navigation failed for "$screen": $e');
        appRouter.go('/notifications');
      }
    } else {
      // No screen specified — navigate to the notifications page
      appRouter.go('/notifications');
    }
  }

  /// Show a branded in-app overlay banner for 4 seconds.
  void _showInAppBanner(BuildContext context, RemoteMessage message) {
    final overlay = Overlay.of(context);
    final title = message.notification?.title ?? 'Fursafy';
    final body = message.notification?.body ?? '';
    final type = message.data['type'] as String?;
    final screen = message.data['screen'] as String?;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _InAppNotificationBanner(
        title: title,
        body: body,
        type: type,
        onTap: () {
          entry.remove();
          if (screen != null && screen.isNotEmpty) {
            appRouter.push(screen);
          }
        },
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  /// Dispose listeners.
  void dispose() {
    _foregroundSub?.cancel();
    _tokenRefreshSub?.cancel();
  }
}

/// In-app notification banner widget — slides down from top.
class _InAppNotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final String? type;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationBanner({
    required this.title,
    required this.body,
    this.type,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<_InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'application_accepted':
        return Icons.verified;
      case 'application_rejected':
        return Icons.cancel_outlined;
      case 'application_received':
        return Icons.person_add;
      case 'job_match':
        return Icons.work;
      case 'rating_received':
        return Icons.rate_review;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'application_accepted':
        return const Color(0xFF00694C);
      case 'application_rejected':
        return const Color(0xFFBA1A1A);
      case 'application_received':
        return const Color(0xFF855400);
      case 'job_match':
        return const Color(0xFF00694C);
      case 'rating_received':
        return const Color(0xFF6B4200);
      default:
        return const Color(0xFF00694C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final color = _colorForType(widget.type);

    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onTap,
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < -100) {
                widget.onDismiss();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border(
                    left: BorderSide(color: color, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_iconForType(widget.type),
                          color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1C19),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.body.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.body,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                color: Color(0xFF3D4943),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: const Icon(Icons.close,
                          size: 18, color: Color(0xFF6D7A73)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
