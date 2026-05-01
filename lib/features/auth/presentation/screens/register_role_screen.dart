import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';

/// S04 — Role selection screen. Placeholder.
class RegisterRoleScreen extends StatelessWidget {
  const RegisterRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Choose Your Role', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.registerDetails, extra: 'youth'),
              child: const Text('Youth / Worker'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.registerDetails, extra: 'provider'),
              child: const Text('Job Provider'),
            ),
          ],
        ),
      ),
    );
  }
}
