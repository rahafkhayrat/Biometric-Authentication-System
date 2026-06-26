import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  /// Check if device supports biometrics
  static Future<bool> isBiometricsAvailable() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types (fingerprint, face, etc.)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate using biometrics with retry support
  /// Returns a result object with success flag and optional message.
  static Future<Map<String, dynamic>> authenticateWithResult() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) {
        print('[BiometricService] canCheckBiometrics: false');
        return {
          'success': false,
          'message': 'Biometrics not enrolled or available',
        };
      }

      final available = await _auth.getAvailableBiometrics();
      print('[BiometricService] available biometric types: $available');
      if (available.isEmpty) {
        print('[BiometricService] no biometric sensors available');
        return {'success': false, 'message': 'No biometric sensors available'};
      }

      final result = await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to complete authentication',
      );

      print('[BiometricService] authenticate() result: $result');

      if (result) return {'success': true, 'message': null};
      print('[BiometricService] authentication failed or canceled');
      return {'success': false, 'message': 'Authentication failed or canceled'};
    } on PlatformException catch (e) {
      print('[BiometricService] PlatformException: ${e.message}');
      return {'success': false, 'message': e.message ?? e.toString()};
    } catch (e) {
      print('[BiometricService] Exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Backwards-compatible simple authenticate (bool) kept for callers.
  static Future<bool> authenticate() async {
    final res = await authenticateWithResult();
    return res['success'] == true;
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }
}
