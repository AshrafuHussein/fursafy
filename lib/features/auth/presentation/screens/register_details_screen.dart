import 'package:flutter/material.dart';

/// S05 — Registration details screen. Placeholder.
class RegisterDetailsScreen extends StatelessWidget {
  final String role;
  const RegisterDetailsScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(child: Text('Register Details — Role: $role\nPlaceholder')),
    );
  }
}
