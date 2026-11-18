class Transaksi {
  final String idTran;
  final int idBrg;
  final int jmlBrg;
  final String tglTran;
  final int hrgBrg;
  final int totalHrg;

  Transaksi({
    required this.idTran,
    required this.idBrg,
    required this.jmlBrg,
    required this.tglTran,
    required this.hrgBrg,
    required this.totalHrg,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_tran': idTran,
      'id_brg': idBrg,
      'jml_brg': jmlBrg,
      'tgl_tran': tglTran,
      'hrg_brg': hrgBrg,
      'total_hrg': totalHrg,
    };
  }

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      idTran: map['id_tran'] as String,
      idBrg: map['id_brg'] as int,
      jmlBrg: map['jml_brg'] as int,
      tglTran: map['tgl_tran'] as String,
      hrgBrg: map['hrg_brg'] as int,
      totalHrg: map['total_hrg'] as int,
    );
  }
}
