import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';

/// S03 — Login screen matching Stitch "Login" UI.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      body: Stack(
        children: [
          // Background floating elements
          Positioned(
            top: 80,
            right: -80,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: FursafyTheme.secondaryFixed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: 100,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                color: FursafyTheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Branding
                    Text(
                      'Fursafy',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: FursafyTheme.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Header
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: FursafyTheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Log in to your curated dashboard',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: FursafyTheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 40),

                    // Phone Input
                    Text(
                      'PHONE NUMBER',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: FursafyTheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontFamily: FursafyTheme.bodyFont,
                        fontWeight: FontWeight.w600,
                        color: FursafyTheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.call_outlined,
                          color: FursafyTheme.onSurfaceVariant,
                        ),
                        hintText: '+255 --- --- ---',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: FursafyTheme.outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Password Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PASSWORD',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: FursafyTheme.onSurfaceVariant,
                              ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push(AppRoutes.forgotPassword);
                          },
                          child: Text(
                            'Forgot Password?',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: FursafyTheme.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                        fontFamily: FursafyTheme.bodyFont,
                        fontWeight: FontWeight.w600,
                        color: FursafyTheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: FursafyTheme.onSurfaceVariant,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: FursafyTheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        hintText: '••••••••',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: FursafyTheme.outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Sign In Button
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement login logic
                        context.go(AppRoutes.home);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shadowColor: FursafyTheme.primary.withValues(alpha: 0.1),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Sign In'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: FursafyTheme.surfaceContainerHigh),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'NEW TO FURSAFY?',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: FursafyTheme.outline,
                                  letterSpacing: 1.0,
                                ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: FursafyTheme.surfaceContainerHigh),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Register Button
                    OutlinedButton(
                      onPressed: () => context.push(AppRoutes.registerRole),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: const BorderSide(color: FursafyTheme.primary, width: 2),
                      ),
                      child: const Text('Register Account'),
                    ),
                    const SizedBox(height: 48),

                    // Footer
                    Text(
                      '© 2024 Fursafy. Curating opportunities with intent.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: FursafyTheme.onSurfaceVariant.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
