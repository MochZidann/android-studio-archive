import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_toast.dart';

/// Halaman Registrasi (Sign Up)
/// Mengacu pada alur AuthenticationSignupActivity.kt pada modul PML04
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();

  // Controllers untuk field form registrasi
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Focus nodes untuk perpindahan kursor
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // Pilihan Role: 'admin' atau 'pelanggan'
  String? _selectedRole;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _nameFocus.dispose();
    _addressFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Menangani proses registrasi akun baru
  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi field kosong (sesuai modul Kotlin)
    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        address.isEmpty ||
        phone.isEmpty) {
      CustomToast.show(
        context,
        'Semua field harus diisi',
        isError: true,
      );
      return;
    }

    // 2. Validasi pemilihan role (sesuai modul Kotlin)
    if (_selectedRole == null ||
        (_selectedRole != 'admin' && _selectedRole != 'pelanggan')) {
      CustomToast.show(
        context,
        'Pilih role terlebih dahulu',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Eksekusi registrasi: Auth -> Firestore -> Email Verification
      await _authService.signUp(
        email: email,
        password: password,
        username: name,
        address: address,
        phone: phone,
        role: _selectedRole!,
      );

      if (!mounted) return;

      // Toast "Akun berhasil dibuat" & "Email verifikasi telah dikirim"
      CustomToast.show(
        context,
        'Akun berhasil dibuat! Email verifikasi telah dikirim.',
        isSuccess: true,
      );

      // Kembali ke halaman Sign In
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'email-already-in-use') {
        CustomToast.show(
          context,
          'Email sudah terdaftar, silakan login',
          isError: true,
        );
      } else if (e.code == 'weak-password') {
        CustomToast.show(
          context,
          'Password terlalu lemah (minimal 6 karakter)',
          isError: true,
        );
      } else {
        CustomToast.show(
          context,
          'Gagal membuat akun: ${e.message}',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(
        context,
        'Gagal menyimpan data user: $e',
        isError: true,
      );
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
        title: const Text(
          'Register Akun Baru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_add_outlined,
                        color: Color(0xFF4F46E5),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REGISTER',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Lengkapi formulir untuk membuat akun',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Form Container
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
                    // Input Email (edtEmailReg)
                    CustomTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      label: 'Email',
                      hint: 'user@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _nameFocus.requestFocus(),
                    ),
                    const SizedBox(height: 14),

                    // Input Nama (edtNameReg)
                    CustomTextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      label: 'Nama Lengkap / Username',
                      hint: 'cth: Zidan Kurnia',
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _addressFocus.requestFocus(),
                    ),
                    const SizedBox(height: 14),

                    // Input Alamat (edtAddressReg)
                    CustomTextField(
                      controller: _addressController,
                      focusNode: _addressFocus,
                      label: 'Alamat',
                      hint: 'cth: Jl. Soekarno Hatta No. 9',
                      icon: Icons.location_on_outlined,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _phoneFocus.requestFocus(),
                    ),
                    const SizedBox(height: 14),

                    // Input No HP (edtMobileReg)
                    CustomTextField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      label: 'Nomor HP',
                      hint: '081234567890',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: 14),

                    // Input Password (edtPasswordReg)
                    CustomTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      label: 'Password',
                      hint: 'Minimal 6 karakter',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 18),

                    // Radio Role Selector (rbAdmin & rbPelanggan)
                    const Text(
                      'Pilih Role',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Radio Button Admin
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'admin';
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'admin'
                                    ? const Color(0xFFEEF2FF)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedRole == 'admin'
                                      ? const Color(0xFF4F46E5)
                                      : const Color(0xFFE2E8F0),
                                  width: _selectedRole == 'admin' ? 1.6 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _selectedRole == 'admin'
                                            ? const Color(0xFF4F46E5)
                                            : const Color(0xFF94A3B8),
                                        width: 2,
                                      ),
                                    ),
                                    child: _selectedRole == 'admin'
                                        ? Center(
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF4F46E5),
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Admin',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Radio Button Pelanggan
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'pelanggan';
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'pelanggan'
                                    ? const Color(0xFFEEF2FF)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedRole == 'pelanggan'
                                      ? const Color(0xFF4F46E5)
                                      : const Color(0xFFE2E8F0),
                                  width:
                                      _selectedRole == 'pelanggan' ? 1.6 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _selectedRole == 'pelanggan'
                                            ? const Color(0xFF4F46E5)
                                            : const Color(0xFF94A3B8),
                                        width: 2,
                                      ),
                                    ),
                                    child: _selectedRole == 'pelanggan'
                                        ? Center(
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF4F46E5),
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Pelanggan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tombol Sign Up (btnSignup)
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
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
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol Already have account, Login (btnLogin)
                    SizedBox(
                      height: 46,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4F46E5),
                        ),
                        child: const Text(
                          'Already have account, Login',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
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
    );
  }
}
