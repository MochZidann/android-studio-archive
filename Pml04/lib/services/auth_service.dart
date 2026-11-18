import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Service untuk mengelola interaksi otentikasi Firebase Auth & data pengguna Firestore
/// Mengimplementasikan alur logika dari modul PML04
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksi pengguna di Firestore
  static const String userCollection = 'users';

  /// Mendapatkan user Firebase Auth yang sedang login
  User? get currentUser => _auth.currentUser;

  /// Stream status autentikasi user
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Mendaftarkan pengguna baru (Sign Up)
  /// Alur:
  /// 1. Buat akun di Firebase Auth
  /// 2. Simpan profil lengkap ke Firestore collection 'users' dengan ID = UID
  /// 3. Kirim email verifikasi ke alamat email pengguna
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
    required String address,
    required String phone,
    required String role,
  }) async {
    // 1. Buat akun di Firebase Auth
    final UserCredential credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final User? user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Gagal membuat user autentikasi.',
      );
    }

    // 2. Siapkan data model user
    final userModel = UserModel(
      uid: user.uid,
      email: email.trim(),
      username: username.trim(),
      address: address.trim(),
      phone: phone.trim(),
      role: role.trim().toLowerCase(),
    );

    // 3. Simpan data tambahan ke Firestore
    await _firestore
        .collection(userCollection)
        .doc(user.uid)
        .set(userModel.toMap());

    // 4. Kirim email verifikasi
    await user.sendEmailVerification();

    return userModel;
  }

  /// Masuk dengan email dan password (Sign In)
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Mengecek apakah email pengguna yang sedang login sudah diverifikasi
  /// Memanggil reload() terlebih dahulu untuk mendapatkan status terbaru dari Firebase
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Mengirim ulang email verifikasi
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Mengambil data dokumen profil pengguna dari Firestore berdasarkan UID
  Future<UserModel?> getUserProfile(String uid) async {
    final docSnapshot =
        await _firestore.collection(userCollection).doc(uid).get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      return UserModel.fromFirestore(docSnapshot);
    }
    return null;
  }

  /// Keluar dari sesi autentikasi (Logout)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
