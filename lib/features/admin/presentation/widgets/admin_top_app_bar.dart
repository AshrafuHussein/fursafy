import 'package:flutter/material.dart';
import 'package:fursafy/app/theme.dart';

class AdminTopAppBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;

  const AdminTopAppBar({
    super.key,
    required this.onSearchChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: FursafyTheme.outlineVariant.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Search input field
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: FursafyTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.search, color: FursafyTheme.outline, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search dashboard...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: FursafyTheme.bodyStyle.copyWith(fontSize: 13),
                    onChanged: onSearchChanged,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // System actions
          IconButton(
            icon: const Icon(Icons.notifications_none, color: FursafyTheme.outline),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: FursafyTheme.primary),
            onPressed: onRefresh,
            tooltip: 'Refresh details',
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 28,
            color: FursafyTheme.outlineVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 16),

          // User Profile bubble
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Admin Ibrahim',
                style: FursafyTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: FursafyTheme.onSurface,
                ),
              ),
              Text(
                'SUPER ADMINISTRATOR',
                style: FursafyTheme.labelStyle.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: FursafyTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: FursafyTheme.primary.withValues(alpha: 0.1),
              border: Border.all(color: FursafyTheme.primary.withValues(alpha: 0.2), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              'A',
              style: FursafyTheme.headlineStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: FursafyTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
