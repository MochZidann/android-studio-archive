import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyD6f2KnRApfXPXv4ebVGrcpAGgCr6Cq7xo',
    appId: '1:931617611354:web:3232db3662e0e5feacc263',
    messagingSenderId: '931617611354',
    projectId: 'pml02-42bc2',
    authDomain: 'pml02-42bc2.firebaseapp.com',
    storageBucket: 'pml02-42bc2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD6f2KnRApfXPXv4ebVGrcpAGgCr6Cq7xo',
    appId: '1:931617611354:android:3232db3662e0e5feacc263',
    messagingSenderId: '931617611354',
    projectId: 'pml02-42bc2',
    storageBucket: 'pml02-42bc2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD6f2KnRApfXPXv4ebVGrcpAGgCr6Cq7xo',
    appId: '1:931617611354:ios:3232db3662e0e5feacc263',
    messagingSenderId: '931617611354',
    projectId: 'pml02-42bc2',
    storageBucket: 'pml02-42bc2.firebasestorage.app',
    iosBundleId: 'com.example.pml02',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD6f2KnRApfXPXv4ebVGrcpAGgCr6Cq7xo',
    appId: '1:931617611354:web:3232db3662e0e5feacc263',
    messagingSenderId: '931617611354',
    projectId: 'pml02-42bc2',
    authDomain: 'pml02-42bc2.firebaseapp.com',
    storageBucket: 'pml02-42bc2.firebasestorage.app',
  );
}
