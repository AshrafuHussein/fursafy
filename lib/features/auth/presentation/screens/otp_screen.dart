import 'package:flutter/material.dart';

/// S05b — OTP verification screen. Placeholder.
class OtpScreen extends StatelessWidget {
  final String phoneNumber;
  final String verificationId;
  const OtpScreen({super.key, required this.phoneNumber, required this.verificationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: Center(child: Text('OTP Screen — Phone: $phoneNumber\nPlaceholder')),
    );
  }
}
