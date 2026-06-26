import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/biometric_service.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';
import '../widgets/primary_button.dart';

class FingerprintScreen extends StatefulWidget {
  final bool preAuthAllowed;

  const FingerprintScreen({super.key, this.preAuthAllowed = false});

  @override
  State<FingerprintScreen> createState() => _FingerprintScreenState();
}

class _FingerprintScreenState extends State<FingerprintScreen> {
  static const MethodChannel _platform = MethodChannel(
    'com.example.bio_app/settings',
  );
  bool _isAuthenticating = false;
  bool _isBiometricsAvailable = false;
  String? _errorMessage;
  List<String> _availableBiometricsLabels = [];

  @override
  void initState() {
    super.initState();
    _checkBiometricsAvailability();
  }

  Future<void> _checkBiometricsAvailability() async {
    final available = await BiometricService.isBiometricsAvailable();
    setState(() {
      // Allow fingerprint authentication regardless of any face pre-auth flag.
      _isBiometricsAvailable = available;
      if (!available) {
        _errorMessage =
            'Fingerprint authentication not available on this device.';
      } else {
        _errorMessage = null;
      }
    });

    // also fetch available biometric types for display/debugging
    try {
      final types = await BiometricService.getAvailableBiometrics();
      setState(() {
        _availableBiometricsLabels = types
            .map((t) => t.toString().split('.').last)
            .toList();
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _authenticate() async {
    if (!_isBiometricsAvailable) {
      setState(() {
        _errorMessage =
            'Biometrics not available. Please enable fingerprint on your device.';
      });
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final result = await BiometricService.authenticateWithResult();

      if (!mounted) return;

      final success = result['success'] == true;
      final message = result['message'] as String?;

      if (success) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Success!'),
            content: Text(
              'Fingerprint verified successfully!\nYou are now fully authenticated.${message != null ? '\n$message' : ''}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Remove all previous routes and go to home (final)
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _isAuthenticating = false;
          _errorMessage =
              message ?? 'Fingerprint not recognized. Please try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _openSecuritySettings() async {
    try {
      final result = await _platform.invokeMethod<bool>('openSecuritySettings');
      if (result == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opened security settings')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open security settings')),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening settings: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Fingerprint Authentication',
          style: TextStyle(color: AppColors.neon),
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.neon),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint, size: 120, color: AppColors.neon),
              const SizedBox(height: 40),
              const Text(
                'Fingerprint Authentication',
                style: TextStyle(
                  color: AppColors.neon,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isBiometricsAvailable
                    ? 'Please authenticate using your fingerprint'
                    : 'Fingerprint not available',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_availableBiometricsLabels.isNotEmpty)
                Text(
                  'Sensors: ${_availableBiometricsLabels.join(', ')}',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 40),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              PrimaryButton(
                text: _isAuthenticating
                    ? 'AUTHENTICATING...'
                    : 'SCAN FINGERPRINT',
                onTap: (_isAuthenticating || !_isBiometricsAvailable)
                    ? null
                    : _authenticate,
              ),
              const SizedBox(height: 12),
              if (Platform.isAndroid)
                TextButton(
                  onPressed: _openSecuritySettings,
                  child: const Text('Open Security Settings'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
