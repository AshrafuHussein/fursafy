import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/theme.dart';

/// S05c — Forgot Password screen (Stitch editorial design).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneCtrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  Future<void> _sendReset() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) return;
    setState(() => _sending = true);
    try {
      // Use Firebase phone auth to verify ownership
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone.startsWith('+') ? phone : '+255$phone',
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          setState(() => _sending = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Verification failed')),
          );
        },
        codeSent: (verificationId, _) {
          setState(() {
            _sending = false;
            _sent = true;
          });
        },
        codeAutoRetrievalTimeout: (_) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => _sending = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Background blurred accents
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FursafyTheme.primary.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FursafyTheme.secondaryContainer.withValues(alpha: 0.1),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _sent ? _successView() : _formView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 48),
        // Brand
        Text(
          'Fursafy',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: FursafyTheme.primary,
          ),
        ),
        const SizedBox(height: 48),

        // Hero Title
        RichText(
          text: TextSpan(
            style: FursafyTheme.headlineStyle.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: FursafyTheme.onSurface,
              height: 1.2,
            ),
            children: const [
              TextSpan(text: 'Reset your\n'),
              TextSpan(
                text: 'professional journey.',
                style: TextStyle(color: FursafyTheme.primaryContainer),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Enter the phone number associated with your account and we\'ll send a secure code to reset your password.',
          style: FursafyTheme.bodyStyle.copyWith(
            fontSize: 16,
            color: FursafyTheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),

        // Phone Field
        Text(
          'PHONE NUMBER',
          style: FursafyTheme.labelStyle.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: FursafyTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: FursafyTheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: FursafyTheme.bodyStyle.copyWith(
              color: FursafyTheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: const Icon(
                Icons.smartphone,
                color: FursafyTheme.outline,
                size: 20,
              ),
              hintText: '+255 --- --- ---',
              hintStyle: FursafyTheme.bodyStyle.copyWith(
                color: FursafyTheme.outline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Submit
        SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sending ? null : _sendReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: FursafyTheme.primary,
              foregroundColor: FursafyTheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              shadowColor: FursafyTheme.primary.withValues(alpha: 0.2),
            ),
            child: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Send Code',
                        style: FursafyTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
          ),
        ),
        const Spacer(),

        // Back to sign in
        Center(
          child: GestureDetector(
            onTap: () => context.go('/login'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: FursafyTheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Back to sign in',
                  style: FursafyTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: FursafyTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _successView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: FursafyTheme.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: FursafyTheme.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Code Sent!',
            style: FursafyTheme.headlineStyle.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Check your SMS for the verification code.',
            textAlign: TextAlign.center,
            style: FursafyTheme.bodyStyle.copyWith(
              color: FursafyTheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FursafyTheme.primary,
                foregroundColor: FursafyTheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'Return to Login',
                style: FursafyTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
