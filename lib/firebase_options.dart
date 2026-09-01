import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Mchat Firebase web configuration is not configured yet.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Mchat Firebase is currently configured for Android only.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD7dJ8ytbNMpxs5FAlQ-mcCW1jio384QvU',
    appId: '1:547357565461:android:495ba4cd654c8ee55b241c',
    messagingSenderId: '547357565461',
    projectId: 'mchat-968a2',
    storageBucket: 'mchat-968a2.firebasestorage.app',
  );
}
