import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../routes/app_routes.dart';
import '../widgets/primary_button.dart';
import '../services/firebase_service.dart';
import 'dart:developer' as developer;
import '../services/biometric_service.dart';
import '../services/firebase_fingerprint_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailCtrl.text.trim();
      final password = _passCtrl.text;

      await FirebaseService.register(email, password);

      // After successful registration, optionally prompt fingerprint enrollment
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Prompt biometric auth to enroll fingerprint locally
        developer.log(
          'Attempting local biometric enrollment',
          name: 'register',
        );
        final res = await BiometricService.authenticateWithResult();
        if (res['success'] == true) {
          // mark enrolled in Firestore
          await FirebaseFingerprintService.setFingerprintEnrolled(
            user.uid,
            true,
          );
          developer.log('Biometric enrollment succeeded', name: 'register');
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Fingerprint Enrolled'),
                content: const Text(
                  'Fingerprint enrollment successful for this device.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          developer.log(
            'Biometric enrollment not completed: ${res['message']}',
            name: 'register',
          );
          // Offer the user a way to open fingerprint settings or try enrolling later
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Fingerprint Not Enrolled'),
                content: const Text(
                  'You did not complete fingerprint enrollment. You can enroll fingerprints in your device settings or try enrolling later.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      // Open the in-app fingerprint screen so user can follow steps
                      Navigator.pushNamed(context, AppRoutes.fingerprint);
                    },
                    child: const Text('Enroll Now'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            );
          }
        }
      }

      if (!mounted) return;

      // Success - navigate to face register with email (existing flow preserved)
      Navigator.pushNamed(context, AppRoutes.faceRegister, arguments: email);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('email-already-in-use')) {
      return 'An account with this email already exists';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Check your connection';
    }
    return 'Registration failed: ${error.split(':').last.trim()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "REGISTER",
                style: TextStyle(
                  color: AppColors.neon,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _inputField(
                controller: _emailCtrl,
                hint: "Email",
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _inputField(
                controller: _passCtrl,
                hint: "Password",
                icon: Icons.lock,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (!isValidPassword(value)) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.neon)
                  : PrimaryButton(text: "NEXT", onTap: _onNext),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _inputField({
  TextEditingController? controller,
  String hint = "",
  required IconData icon,
  bool isPassword = false,
  String? Function(String?)? validator,
}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.buttonDark,
      borderRadius: BorderRadius.circular(14),
    ),
    child: TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: const TextStyle(color: AppColors.textLight),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.neon),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        border: InputBorder.none,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    ),
  );
}
