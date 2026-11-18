import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_toast.dart';
import 'sign_up_screen.dart';
import 'admin_dashboard_screen.dart';
import 'pelanggan_dashboard_screen.dart';

/// Halaman Login (Sign In)
/// Mengacu pada alur AuthenticationSigninActivity.kt pada modul PML04
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Menangani proses autentikasi login
  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi input kosong (sesuai modul Kotlin)
    if (email.isEmpty || password.isEmpty) {
      CustomToast.show(
        context,
        'Email dan Password harus diisi',
        isError: true,
      );
      if (email.isEmpty) {
        _emailFocus.requestFocus();
      } else {
        _passwordFocus.requestFocus();
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Sign In menggunakan Firebase Auth
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'Gagal mengambil data autentikasi pengguna.',
        );
      }

      // 3. Cek apakah email sudah diverifikasi
      final isVerified = await _authService.isEmailVerified();

      if (!mounted) return;

      if (!isVerified) {
        // Jika belum verifikasi email, tampilkan toast peringatan
        CustomToast.show(
          context,
          'Email belum diverifikasi',
          isError: true,
          action: SnackBarAction(
            label: 'Kirim Ulang',
            textColor: Colors.amberAccent,
            onPressed: () async {
              try {
                await _authService.sendEmailVerification();
                if (mounted) {
                  CustomToast.show(
                    context,
                    'Email verifikasi telah dikirim ulang!',
                    isSuccess: true,
                  );
                }
              } catch (e) {
                if (mounted) {
                  CustomToast.show(
                    context,
                    'Gagal mengirim email: $e',
                    isError: true,
                  );
                }
              }
            },
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // 4. Jika email sudah diverifikasi, ambil data role dari Firestore (users/{uid})
      final userProfile = await _authService.getUserProfile(user.uid);

      if (!mounted) return;

      if (userProfile != null) {
        final role = userProfile.role.toLowerCase().trim();

        // 5. Routing berdasarkan role (admin vs pelanggan)
        if (role == 'admin') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboardScreen(user: userProfile),
            ),
            (route) => false,
          );
        } else if (role == 'pelanggan') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => PelangganDashboardScreen(user: userProfile),
            ),
            (route) => false,
          );
        } else {
          CustomToast.show(context, 'Role tidak ditemukan', isError: true);
        }
      } else {
        CustomToast.show(context, 'Gagal mengambil data user', isError: true);
      }
    } on FirebaseAuthException {
      if (mounted) {
        // Pesan standar modul PML: "Email atau Password salah"
        CustomToast.show(context, 'Email atau Password salah', isError: true);
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, 'Terjadi kesalahan: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pml04',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Pemrograman Mobile Lajut 4',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Logo & Judul
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Masuk ke akun Anda untuk melanjutkan',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 28),

                // Card Form
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Input Email
                      CustomTextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        label: 'Email',
                        hint: 'contoh@domain.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      CustomTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        label: 'Password',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSignIn(),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Sign In (btnSignIn)
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Pembatas "or"
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: Color(0xFFE2E8F0)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: Color(0xFFE2E8F0)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Tombol Register (btnRegister)
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4F46E5),
                            side: const BorderSide(
                              color: Color(0xFF4F46E5),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
