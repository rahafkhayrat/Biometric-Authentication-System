import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../routes/app_routes.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/firebase_fingerprint_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailCtrl.text.trim();
      final password = _passCtrl.text;

      await FirebaseService.login(email, password);

      if (!mounted) return;

      developer.log('User logged in: $email', name: 'login');

      // Check if fingerprint is enrolled for this user on this device
      final user = FirebaseAuth.instance.currentUser;
      bool enrolled = false;
      if (user != null) {
        enrolled = await FirebaseFingerprintService.isFingerprintEnrolled(
          user.uid,
        );
      }

      if (enrolled) {
        // Offer to authenticate via fingerprint now
        if (!mounted) return;
        final useFingerprint = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Use Fingerprint'),
            content: const Text(
              'A fingerprint is enrolled for this account on this device. Would you like to authenticate using fingerprint now?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );

        if (useFingerprint == true) {
          developer.log('User chose fingerprint after login', name: 'login');
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.fingerprint,
            arguments: {'allowed': true},
          );
          return;
        }
      } else {
        // Not enrolled — show helpful prompt to enroll
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Fingerprint Not Enrolled'),
            content: const Text(
              'No fingerprint enrollment was detected for your account on this device. You can enroll fingerprints in your device settings or from the app fingerprint screen.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.fingerprint,
                  );
                },
                child: const Text('Enroll Now'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Continue to face login as before
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.faceLogin,
                    arguments: email,
                  );
                },
                child: const Text('Skip'),
              ),
            ],
          ),
        );
        return;
      }

      // If not using fingerprint, continue to face login (existing flow)
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.faceLogin,
        arguments: email,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email';
    }
    if (error.contains('wrong-password')) return 'Incorrect password';
    if (error.contains('invalid-email')) return 'Invalid email address';
    if (error.contains('user-disabled')) {
      return 'This account has been disabled';
    }
    if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try later';
    }
    if (error.contains('network-request-failed')) {
      return 'Network error. Check connection';
    }
    return 'Login failed: ${error.split(':').last.trim()}';
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
                "LOGIN",
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
                  if (!isValidEmail(value)) return 'Please enter a valid email';
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
                    return 'Please enter your password';
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
                    color: Colors.red.withOpacity(0.2),
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
                  : _primaryBtn("LOGIN", _onLogin),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                child: const Text(
                  "Don't have account? Register",
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _inputField({
  required TextEditingController controller,
  required String hint,
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

Widget _primaryBtn(String text, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.neon,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neon.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          color: AppColors.background,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
