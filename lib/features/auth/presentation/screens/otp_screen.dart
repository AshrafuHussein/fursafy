import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/features/auth/presentation/bloc/register_bloc.dart';

/// S05b — OTP Verification screen.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FursafyTheme.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Fursafy',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: FursafyTheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: FursafyTheme.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          } else if (state.status == RegisterStatus.otpVerified) {
            if (state.role == 'provider') {
              context.go(AppRoutes.providerDashboard);
            } else {
              context.push(AppRoutes.skillPicker);
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
          // Background floating elements
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: -96,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: FursafyTheme.primaryFixed.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: -48,
            child: Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                color: FursafyTheme.secondaryFixed.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Security Chip
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: FursafyTheme.secondaryFixed,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: FursafyTheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SECURITY FIRST',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: FursafyTheme.onSecondaryFixed,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header
                  Text(
                    'Verify your\naccount',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: FursafyTheme.primary,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      text: 'We\'ve sent a 6-digit verification code to your registered mobile number ending in ',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: FursafyTheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                      children: [
                        TextSpan(
                          text: state.phone ?? '••••',
                          style: const TextStyle(
                            color: FursafyTheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // OTP Inputs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        height: 64,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: FursafyTheme.onSurface,
                              ),
                          maxLength: 1,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (val) => _onChanged(val, index),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: FursafyTheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: FursafyTheme.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 48),

                  ElevatedButton(
                    onPressed: state.status == RegisterStatus.loading ? null : () {
                      final otp = _controllers.map((c) => c.text).join();
                      if (otp.length == 6) {
                        context.read<RegisterBloc>().add(RegisterOtpVerified(otp));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 4,
                      shadowColor: FursafyTheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.status == RegisterStatus.loading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        else ...[
                          const Text('Verify Code'),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resend Action
                  Column(
                    children: [
                      Text(
                        'Didn\'t receive the code?',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: FursafyTheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: FursafyTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.history_rounded, size: 18, color: FursafyTheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              'Resend code in 00:59',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: FursafyTheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),

                  // Security Footer
                  const Divider(color: FursafyTheme.outlineVariant),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSecurityItem(Icons.verified_user_outlined, 'Secure Session'),
                      const SizedBox(width: 32),
                      _buildSecurityItem(Icons.lock_outline, 'End-to-End'),
                    ],
                  ),
                ],
              ),
              ),
            ),
          ],
          );
        },
      ),
    );
  }

  Widget _buildSecurityItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: FursafyTheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: FursafyTheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
