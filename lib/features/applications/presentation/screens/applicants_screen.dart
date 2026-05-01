import 'package:flutter/material.dart';

/// S17 — Applicants for a job. Placeholder.
class ApplicantsScreen extends StatelessWidget {
  final String jobId;
  const ApplicantsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: Center(child: Text('Applicants for Job: $jobId\nPlaceholder')),
    );
  }
}
