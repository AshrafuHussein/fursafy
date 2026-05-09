import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/features/auth/presentation/bloc/register_bloc.dart';

/// S05 — Register Details (Name, Phone, Password).
class RegisterDetailsScreen extends StatefulWidget {
  const RegisterDetailsScreen({super.key});

  @override
  State<RegisterDetailsScreen> createState() => _RegisterDetailsScreenState();
}

class _RegisterDetailsScreenState extends State<RegisterDetailsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FursafyTheme.onSurface),
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
      ),
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          } else if (state.status == RegisterStatus.otpSent) {
            context.push(AppRoutes.otp);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
          // Background floating elements
          Positioned(
            bottom: -64,
            right: -64,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: FursafyTheme.secondary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -64,
            left: -64,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: FursafyTheme.primary.withValues(alpha: 0.05),
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
                  // Header
                  Text(
                    'Create your account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: FursafyTheme.onSurface,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Begin your journey toward excellence.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: FursafyTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Profile Photo Upload
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: FursafyTheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: FursafyTheme.surface,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add_a_photo_outlined,
                              size: 32,
                              color: FursafyTheme.onSurfaceVariant.withValues(alpha: 0.4),
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: FursafyTheme.secondary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: FursafyTheme.onSecondary,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Photo',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: FursafyTheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Help employers recognize you instantly.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: FursafyTheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Full Name Field
                  _buildInputField(
                    label: 'FULL NAME',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    hint: 'e.g. Salim Mohammed',
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 24),

                  // Phone Number Field
                  _buildInputField(
                    label: 'PHONE NUMBER',
                    controller: _phoneController,
                    icon: Icons.call_outlined,
                    hint: '+255 000 000 000',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // Password Field
                  _buildInputField(
                    label: 'SECURITY KEY',
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    hint: 'Create a strong password',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: FursafyTheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Terms of Service
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          onChanged: (val) {
                            setState(() {
                              _agreedToTerms = val ?? false;
                            });
                          },
                          activeColor: FursafyTheme.primary,
                          side: BorderSide(
                            color: FursafyTheme.surfaceContainerHighest,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: FursafyTheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                  color: FursafyTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: ' and acknowledge the '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  color: FursafyTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: (_agreedToTerms && state.status != RegisterStatus.loading) ? () {
                      context.read<RegisterBloc>().add(RegisterDetailsSubmitted(
                        email: '${_phoneController.text.trim()}@fursafy.temp', // Using phone as email placeholder since UI doesn't have email
                        phone: _phoneController.text.trim(),
                        password: _passwordController.text,
                        displayName: _nameController.text.trim(),
                      ));
                    } : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha: 0.04),
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
                          const Text('Complete Registration'),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: FursafyTheme.onSurfaceVariant,
                            ),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        style: TextButton.styleFrom(
                          foregroundColor: FursafyTheme.primary,
                          textStyle: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Log in here'),
                      ),
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: FursafyTheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(
            fontFamily: FursafyTheme.bodyFont,
            color: FursafyTheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: FursafyTheme.onSurfaceVariant.withValues(alpha: 0.4),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              color: FursafyTheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: FursafyTheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide(
                color: FursafyTheme.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          ),
        ),
      ],
    );
  }
}
