# Firebase Setup Instructions

## Current Status
- ✅ Android: Configured and should work
- ⚠️ Web: Needs web app ID from Firebase Console

## To Get Web App ID (REQUIRED for web):

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **biometricsapp-8a808**
3. Click the **gear icon** ⚙️ → **Project settings**
4. Scroll down to **"Your apps"** section
5. Click the **`</>` (Web)** icon to add a web app
6. Register app name (e.g., "bio_app_web")
7. Copy the **appId** (it looks like: `1:925326890338:web:xxxxxxxxxx`)
8. Update `lib/firebase_options.dart` line 45 with the actual web appId

## Quick Fix:
Replace this line in `lib/firebase_options.dart`:
```dart
appId: '1:925326890338:web:default', // Temporary - needs actual web app ID
```

With your actual web app ID from Firebase Console.

## Test Firebase:
Run the app and check console for:
- ✅ "Firebase initialized successfully" = Working!
- ❌ Any error messages = Check configuration

