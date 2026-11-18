import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Konfigurasi default Firebase untuk PML05
/// Dihubungkan langsung ke proyek Firebase: mobile-dc1a9
/// Berdasarkan google-services.json untuk package: com.example.pml05
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
      case TargetPlatform.windows:
        return windows;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDlJMbJ_fQMSjCHcNfgO78ww3yN6LzSX5Q',
    appId: '1:841483761739:web:299ed1d3f652dd4b8335ce',
    messagingSenderId: '841483761739',
    projectId: 'mobile-dc1a9',
    authDomain: 'mobile-dc1a9.firebaseapp.com',
    storageBucket: 'mobile-dc1a9.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlJMbJ_fQMSjCHcNfgO78ww3yN6LzSX5Q',
    appId: '1:841483761739:android:299ed1d3f652dd4b8335ce',
    messagingSenderId: '841483761739',
    projectId: 'mobile-dc1a9',
    storageBucket: 'mobile-dc1a9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlJMbJ_fQMSjCHcNfgO78ww3yN6LzSX5Q',
    appId: '1:841483761739:ios:299ed1d3f652dd4b8335ce',
    messagingSenderId: '841483761739',
    projectId: 'mobile-dc1a9',
    storageBucket: 'mobile-dc1a9.firebasestorage.app',
    iosBundleId: 'com.example.pml05',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDlJMbJ_fQMSjCHcNfgO78ww3yN6LzSX5Q',
    appId: '1:841483761739:web:299ed1d3f652dd4b8335ce',
    messagingSenderId: '841483761739',
    projectId: 'mobile-dc1a9',
    authDomain: 'mobile-dc1a9.firebaseapp.com',
    storageBucket: 'mobile-dc1a9.firebasestorage.app',
  );
}
