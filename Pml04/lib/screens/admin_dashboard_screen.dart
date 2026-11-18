import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/custom_toast.dart';
import 'sign_in_screen.dart';

/// Halaman Dashboard Admin
class AdminDashboardScreen extends StatelessWidget {
  final UserModel user;

  const AdminDashboardScreen({
    super.key,
    required this.user,
  });

  /// Menangani aksi Logout
  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 8),
            Text(
              'Konfirmasi Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari sesi Admin?',
          style: TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final AuthService authService = AuthService();
    await authService.signOut();

    if (!context.mounted) return;

    CustomToast.show(
      context,
      'Berhasil logout',
      isSuccess: true,
    );

    // Kembali ke SignInScreen dengan menghapus seluruh stack sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Panel Administrator',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login sebagai admin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}