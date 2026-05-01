import 'package:flutter/material.dart';

/// S19/S19b — Rating screen. Placeholder.
class RatingScreen extends StatelessWidget {
  final String jobId;
  const RatingScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate')),
      body: Center(child: Text('Rating for Job: $jobId\nPlaceholder')),
    );
  }
}
