// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured for this Firebase project.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS has not been configured yet.',
        );
      default:
        throw UnsupportedError(
          'This platform is not supported.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBz5uWM5TQ0gcLPvT2E-xJs_64UXoqa5VU",
    appId: "1:646876608066:android:183b02c2af0c9119b69fdb",
    messagingSenderId: "646876608066",
    projectId: "arogya-connect-sih-2025",
    storageBucket: "arogya-connect-sih-2025.firebasestorage.app",
  );
}
