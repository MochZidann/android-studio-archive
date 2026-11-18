import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Konfigurasi default Firebase untuk PML03 berdasarkan file google-services.json
class DefaultFirebaseOptions {
  static const String databaseUrl =
      'https://pml03-9da0e-default-rtdb.firebaseio.com';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDhSweJwMyJFov3LIxwSw8Ztm6NRFpcKW8',
    appId: '1:1001101277289:web:6fa5c8b23a891729e4caf8',
    messagingSenderId: '1001101277289',
    projectId: 'pml03-9da0e',
    authDomain: 'pml03-9da0e.firebaseapp.com',
    databaseURL: databaseUrl,
    storageBucket: 'pml03-9da0e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDhSweJwMyJFov3LIxwSw8Ztm6NRFpcKW8',
    appId: '1:1001101277289:android:6fa5c8b23a891729e4caf8',
    messagingSenderId: '1001101277289',
    projectId: 'pml03-9da0e',
    databaseURL: databaseUrl,
    storageBucket: 'pml03-9da0e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhSweJwMyJFov3LIxwSw8Ztm6NRFpcKW8',
    appId: '1:1001101277289:ios:6fa5c8b23a891729e4caf8',
    messagingSenderId: '1001101277289',
    projectId: 'pml03-9da0e',
    databaseURL: databaseUrl,
    storageBucket: 'pml03-9da0e.firebasestorage.app',
    iosBundleId: 'com.example.pml03',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDhSweJwMyJFov3LIxwSw8Ztm6NRFpcKW8',
    appId: '1:1001101277289:web:6fa5c8b23a891729e4caf8',
    messagingSenderId: '1001101277289',
    projectId: 'pml03-9da0e',
    authDomain: 'pml03-9da0e.firebaseapp.com',
    databaseURL: databaseUrl,
    storageBucket: 'pml03-9da0e.firebasestorage.app',
  );
}
