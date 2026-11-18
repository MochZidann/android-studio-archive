import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/messaging_screen.dart';

/// Handler background messaging untuk FCM ketika aplikasi berada di background / terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("Handling background FCM message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase Core
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    try {
      await Firebase.initializeApp();
    } catch (err) {
      debugPrint('Firebase init notice: $err');
    }
  }

  // Daftarkan background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const Pml05App());
}

class Pml05App extends StatelessWidget {
  const Pml05App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pml05 - Firebase Cloud Messaging',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF0284C7),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const MessagingScreen(),
    );
  }
}
