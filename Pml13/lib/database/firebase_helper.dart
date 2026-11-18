import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class FirebaseRealtimeHelper {
  static final FirebaseRealtimeHelper instance =
      FirebaseRealtimeHelper._internal();
  FirebaseRealtimeHelper._internal();

  DatabaseReference get _ref {
    return FirebaseDatabase.instance.ref('transaksi');
  }

  /// Insert data transaksi ke node Firebase Realtime Database: "transaksi/$id_tran"
  Future<bool> insert({
    required String idTran,
    required int idBrg,
    required int jmlBrg,
    required String tglTran,
    required int hrgBrg,
  }) async {
    try {
      final totalHrg = hrgBrg * jmlBrg;
      final payload = {
        'id_tran': idTran,
        'id_brg': idBrg,
        'jml_brg': jmlBrg,
        'tgl_tran': tglTran,
        'hrg_brg': hrgBrg,
        'total_hrg': totalHrg,
      };

      // Set value ke child node
      await _ref.child(idTran).set(payload).timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint('Firebase set timeout for id: $idTran (writing in background)');
        },
      );
      return true;
    } catch (e) {
      debugPrint('Firebase insert error: $e');
      // Bila offline atau terdapat kendala jaringan, tetap return true jika write dicache
      return false;
    }
  }

  /// Hapus semua node transaksi di Firebase
  Future<void> clearAll() async {
    try {
      await _ref.remove();
    } catch (e) {
      debugPrint('Firebase clearAll error: $e');
    }
  }
}
