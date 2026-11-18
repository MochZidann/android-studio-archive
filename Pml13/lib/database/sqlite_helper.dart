import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class SqliteDbHelper {
  static final SqliteDbHelper instance = SqliteDbHelper._internal();
  SqliteDbHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'db_penjualan.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE t_transaksi (
              id_tran TEXT PRIMARY KEY,
              id_brg INTEGER NOT NULL,
              jml_brg INTEGER NOT NULL,
              tgl_tran TEXT NOT NULL,
              hrg_brg INTEGER NOT NULL,
              total_hrg INTEGER NOT NULL
            )
          ''');
        },
      );
    } catch (e) {
      debugPrint('Error init SQLite database: $e');
      rethrow;
    }
  }

  /// Insert transaksi ke tabel t_transaksi
  Future<bool> insert({
    required String idTran,
    required int idBrg,
    required int jmlBrg,
    required String tglTran,
    required int hrgBrg,
  }) async {
    try {
      final db = await database;
      final totalHrg = hrgBrg * jmlBrg;
      final row = {
        'id_tran': idTran,
        'id_brg': idBrg,
        'jml_brg': jmlBrg,
        'tgl_tran': tglTran,
        'hrg_brg': hrgBrg,
        'total_hrg': totalHrg,
      };

      final id = await db.insert(
        't_transaksi',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id != -1;
    } catch (e) {
      debugPrint('SQLite insert error: $e');
      return false;
    }
  }

  /// Mengambil jumlah total baris pada t_transaksi
  Future<int> getRowCount() async {
    try {
      final db = await database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM t_transaksi'),
      );
      return count ?? 0;
    } catch (e) {
      debugPrint('SQLite getRowCount error: $e');
      return 0;
    }
  }

  /// Menghapus semua data t_transaksi
  Future<void> clearAll() async {
    try {
      final db = await database;
      await db.delete('t_transaksi');
    } catch (e) {
      debugPrint('SQLite clearAll error: $e');
    }
  }
}
