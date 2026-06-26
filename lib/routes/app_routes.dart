import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/face_register.dart';
import '../screens/face_login.dart';
import '../screens/fingerprint_screen.dart';
import '../screens/splash_screen.dart';
import '../test_sqlite_screen.dart';

class AppRoutes {
  static const root = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const faceRegister = '/face_register';
  static const faceLogin = '/face_login';
  static const fingerprint = '/fingerprint';
  static const splash = '/splash';

  static Map<String, WidgetBuilder> get routes => {
    // Splash must be first screen
    root: (context) => const SplashScreen(),

    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    splash: (context) => const SplashScreen(),

    faceRegister: (context) {
      final email = ModalRoute.of(context)?.settings.arguments as String?;
      return FaceRegisterScreen(email: email);
    },

    faceLogin: (context) {
      final email = ModalRoute.of(context)?.settings.arguments as String?;
      return FaceLoginScreen(email: email);
    },

    fingerprint: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final allowed = args != null && args['allowed'] == true;
      return FingerprintScreen(preAuthAllowed: allowed);
    },
    '/sqlite_test': (context) => const TestSqliteScreen(),
  };
}
