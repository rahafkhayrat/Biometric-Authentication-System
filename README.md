# Biometric Authentication System

A cross-platform mobile application built with Flutter that combines **Firebase Authentication**, **on-device face recognition**, and **native fingerprint biometrics** for multi-factor identity verification.

The app captures facial embeddings using a FaceNet TensorFlow Lite model, stores them securely in Cloud Firestore, and verifies identity through cosine similarity matching before completing authentication with the device fingerprint sensor.

---

## Features

| Capability | Description |
|------------|-------------|
| **Email & password auth** | Register and sign in via Firebase Authentication |
| **Face enrollment** | Capture a face photo, detect it with ML Kit, and generate a 512-dimensional embedding |
| **Face identification** | Compare live captures against stored embeddings (cosine similarity threshold: 0.8) |
| **Fingerprint verification** | Complete the flow with device biometrics via `local_auth` |
| **Cloud storage** | Persist face embeddings in Firestore keyed by user UID |
| **Local cache** | Optional SQLite storage for offline embedding data on mobile |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter UI                           │
│  Splash → Login/Register → Home → Face Enroll/Identify      │
│                              ↓                              │
│                     Fingerprint Screen                      │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
  Firebase Auth        Camera + ML Kit       Local Auth
  Cloud Firestore      FaceNet (TFLite)      (Fingerprint)
  SQLite (mobile)
```

### Authentication flow

1. User registers or logs in with email and password.
2. **Enrollment:** User captures their face → ML Kit detects and crops the face → FaceNet generates a normalized embedding → stored in Firestore.
3. **Identification:** User scans their face → embedding is compared to the stored vector → on match (≥ 0.8), proceed to fingerprint.
4. **Biometric step:** Device fingerprint sensor confirms identity via the platform biometric API.

---

## Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart SDK ^3.10)
- **Backend:** Firebase (Auth, Firestore)
- **Face detection:** [Google ML Kit Face Detection](https://pub.dev/packages/google_mlkit_face_detection)
- **Face recognition:** FaceNet model via [tflite_flutter](https://pub.dev/packages/tflite_flutter)
- **Device biometrics:** [local_auth](https://pub.dev/packages/local_auth)
- **Local database:** [sqflite](https://pub.dev/packages/sqflite) (Android/iOS only)
- **Camera:** [camera](https://pub.dev/packages/camera)

---

## Project Structure

```
Biometrics_project/
└── bio_app/
    ├── lib/
    │   ├── main.dart                 # App entry point
    │   ├── routes/                   # Navigation routes
    │   ├── screens/                  # UI screens
    │   ├── services/                 # Business logic & integrations
    │   ├── database/                 # SQLite helpers
    │   ├── models/                   # Data models
    │   ├── utils/                    # Constants, validators, similarity
    │   └── widgets/                  # Reusable UI components
    ├── assets/
    │   └── models/
    │       └── facenet.tflite        # FaceNet TFLite model
    ├── android/                      # Android platform config
    ├── ios/                          # iOS platform config
    └── FIREBASE_SETUP.md             # Firebase configuration guide
```

---

## Prerequisites

Before running the project, ensure you have:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10 or later)
- [Android Studio](https://developer.android.com/studio) or Xcode (for iOS)
- A physical device or emulator with a **camera** (face features require a camera)
- A [Firebase project](https://console.firebase.google.com/) with Authentication and Firestore enabled

---

## Getting Started

### 1. Clone the repository

```bash
git clone <repository-url>
cd Biometrics_project/bio_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Firebase must be initialized before the app can authenticate users or store embeddings.

- **Android:** Already configured via `google-services.json` in the Android module.
- **Web:** Requires a web app ID in `lib/firebase_options.dart`. See [bio_app/FIREBASE_SETUP.md](bio_app/FIREBASE_SETUP.md) for step-by-step instructions.

Enable the following in the Firebase Console:

- **Authentication** → Email/Password sign-in method
- **Cloud Firestore** → Database with appropriate security rules

### 4. Run the application

```bash
# List available devices
flutter devices

# Run on a connected device or emulator
flutter run
```

On first launch, verify the debug console shows:

```
✅ Local database initialized
✅ Firebase initialized successfully
```

---

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | Supported | Full feature set including camera, TFLite, and biometrics |
| iOS | Supported | Requires camera and Face ID / Touch ID permissions in `Info.plist` |
| Web | Partial | Firebase works after web app ID setup; camera/TFLite/biometrics limited |
| Desktop | Limited | Camera and biometric features may not be available |

---

## Permissions

The app requests the following permissions at runtime:

- **Camera** — face capture and live preview
- **Biometrics** — fingerprint authentication via the device secure enclave

Ensure these are declared in `AndroidManifest.xml` and `Info.plist` for production builds.

---

## Configuration

| Setting | Location | Default |
|---------|----------|---------|
| Face similarity threshold | `lib/screens/face_login.dart` | `0.8` |
| FaceNet input size | `lib/services/facenet_service.dart` | `160×160` |
| Embedding dimension | FaceNet model output | `512` |
| Firestore collection | `lib/services/firebase_embedding_service.dart` | `users` |

---

## Development

```bash
# Run static analysis
flutter analyze

# Run tests
flutter test

# Build release APK (Android)
flutter build apk --release
```

---

## Security Considerations

- Face embeddings are stored in Firestore; configure [Firestore security rules](https://firebase.google.com/docs/firestore/security/get-started) so users can only read/write their own documents.
- Biometric templates (fingerprints) are handled entirely by the OS — the app never stores raw biometric data.
- Use HTTPS-only Firebase configuration and restrict API keys in the Firebase Console for production deployments.

---

## License

This project is provided for educational and development purposes. Review and adapt licensing before commercial use.

---

## Related Documentation

- [Firebase Setup Guide](bio_app/FIREBASE_SETUP.md)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
