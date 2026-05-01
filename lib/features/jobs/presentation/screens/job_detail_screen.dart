import 'package:flutter/material.dart';

/// S08 — Job detail screen. Placeholder.
class JobDetailScreen extends StatelessWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: Center(child: Text('Job Detail — ID: $jobId\nPlaceholder')),
    );
  }
}
