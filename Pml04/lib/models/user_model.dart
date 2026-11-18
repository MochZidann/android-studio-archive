import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representasi data Pengguna (User)
/// Mengacu pada struktur koleksi 'users' pada modul PML04
class UserModel {
  final String uid;
  final String email;
  final String username;
  final String address;
  final String phone;
  final String role; // 'admin' atau 'pelanggan'

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.address,
    required this.phone,
    required this.role,
  });

  /// Konversi data pengguna ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'address': address,
      'phone': phone,
      'role': role,
    };
  }

  /// Membuat instance UserModel dari Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      role: data['role']?.toString() ?? 'pelanggan',
    );
  }

  /// Membuat instance UserModel dari Map mentah
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: map['role']?.toString() ?? 'pelanggan',
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? address,
    String? phone,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }
}
