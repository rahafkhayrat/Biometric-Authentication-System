import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'utils/constants.dart';
import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    print('Starting app...');
  }

  // Initialize local SQLite (mobile only)
  if (!kIsWeb) {
    try {
      await DBHelper.init();
      if (kDebugMode) {
        print('✅ Local database initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Local database initialization error: $e');
      }
    }
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      print('✅ Firebase initialized successfully');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ Firebase initialization error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  if (kDebugMode) {
    print('Running app...');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biometric Auth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),

      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
