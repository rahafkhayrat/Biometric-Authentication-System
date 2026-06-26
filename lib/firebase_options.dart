// File generated using Firebase project configuration
// Project: biometricsapp-8a808
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web configuration
  // IMPORTANT: You MUST add a web app in Firebase Console to get the correct appId
  // Steps: Firebase Console > Project Settings > Your apps > Add web app (</> icon)
  // Then copy the appId and replace 'web:default' below
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCdb4jesilubfRFflA-6Jo8Wzd1m4hXZ_4',
    appId: '1:925326890338:web:default', // ⚠️ REPLACE THIS with actual web app ID from Firebase Console
    messagingSenderId: '925326890338',
    projectId: 'biometricsapp-8a808',
    authDomain: 'biometricsapp-8a808.firebaseapp.com',
    storageBucket: 'biometricsapp-8a808.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdb4jesilubfRFflA-6Jo8Wzd1m4hXZ_4',
    appId: '1:925326890338:android:bbfadfbfc631d4afa1c83b',
    messagingSenderId: '925326890338',
    projectId: 'biometricsapp-8a808',
    storageBucket: 'biometricsapp-8a808.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdb4jesilubfRFflA-6Jo8Wzd1m4hXZ_4',
    appId: '1:925326890338:ios:bbfadfbfc631d4afa1c83b',
    messagingSenderId: '925326890338',
    projectId: 'biometricsapp-8a808',
    storageBucket: 'biometricsapp-8a808.firebasestorage.app',
    iosBundleId: 'com.example.bioApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCdb4jesilubfRFflA-6Jo8Wzd1m4hXZ_4',
    appId: '1:925326890338:macos:bbfadfbfc631d4afa1c83b',
    messagingSenderId: '925326890338',
    projectId: 'biometricsapp-8a808',
    storageBucket: 'biometricsapp-8a808.firebasestorage.app',
    iosBundleId: 'com.example.bioApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCdb4jesilubfRFflA-6Jo8Wzd1m4hXZ_4',
    appId: '1:925326890338:windows:bbfadfbfc631d4afa1c83b',
    messagingSenderId: '925326890338',
    projectId: 'biometricsapp-8a808',
    storageBucket: 'biometricsapp-8a808.firebasestorage.app',
  );
}

