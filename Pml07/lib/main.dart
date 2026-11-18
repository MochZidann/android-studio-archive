import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/storage_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase URL dan Key milik lo dari dashboard Supabase
  const supabaseUrl = 'https://jqvquhzuttpqqnxwyuyj.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxdnF1aHp1dHRwcXFueHd5dXlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEzMjM3MjMsImV4cCI6MjEwNjg5OTcyM30.wO4_e7_3tLHY9aoFdxh_kBzLx0cOKaFbQut6KA79oLw';

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseKey,
    );
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  runApp(const Pml07App());
}

class Pml07App extends StatelessWidget {
  const Pml07App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pml07 - Supabase Storage',
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
      home: const StorageScreen(),
    );
  }
}
