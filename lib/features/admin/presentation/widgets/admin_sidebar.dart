import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/app/router.dart';

class AdminSidebar extends StatelessWidget {
  final int activeTabIndex;
  final ValueChanged<int> onTabChanged;

  const AdminSidebar({
    super.key,
    required this.activeTabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
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
          // Brand Header
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 40, 24, 40),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: FursafyTheme.primary,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fursafy',
                      style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: FursafyTheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'GROWTH ENGINE',
                      style: FursafyTheme.labelStyle.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: FursafyTheme.secondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu items
          _sidebarItem(0, 'Dashboard', Icons.dashboard_outlined),
          _sidebarItem(1, 'Opportunities', Icons.work_outline),
          _sidebarItem(2, 'Analytics', Icons.insights),
          _sidebarItem(3, 'Users', Icons.group_outlined),
          _sidebarItem(4, 'Financials', Icons.payments_outlined),
          _sidebarItem(5, 'System Logs', Icons.terminal),
          _sidebarItem(6, 'Settings', Icons.settings_outlined),

          const Spacer(),

          // Logout Item at bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                context.go(AppRoutes.login);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: FursafyTheme.error, size: 20),
                    const SizedBox(width: 16),
                    Text(
                      'Log Out',
                      style: FursafyTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: FursafyTheme.error,
                        fontSize: 14,
                      ),
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

  Widget _sidebarItem(int index, String title, IconData icon) {
    final isActive = activeTabIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => onTabChanged(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? FursafyTheme.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
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
                  color: isActive ? FursafyTheme.primary : FursafyTheme.outline,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
