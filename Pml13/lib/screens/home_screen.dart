import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../database/firebase_helper.dart';
import '../database/sqlite_helper.dart';
import '../widgets/custom_toast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Flag pembatalan proses (mirip `var cancelProcess = false` di modul)
  bool _cancelProcess = false;

  // Status proses berjalan
  bool _isAsyncRunning = false;
  bool _isNoThreadRunning = false;

  // Nilai progress bar mode Coroutine / Asynchronous (0 - 100)
  int _asyncFirebaseProgress = 0;
  int _asyncSqliteProgress = 0;

  // Nilai progress bar mode Tanpa Thread (0 - 100)
  int _noThreadFirebaseProgress = 0;
  int _noThreadSqliteProgress = 0;

  // Animation controller untuk indikator detak UI thread
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// MODE 1: ASYNCHRONOUS (PENGGANTI COROUTINE)
  Future<void> _startSendingAsync() async {
    if (_isAsyncRunning || _isNoThreadRunning) return;

    setState(() {
      _cancelProcess = false;
      _isAsyncRunning = true;
      _asyncFirebaseProgress = 0;
      _asyncSqliteProgress = 0;
    });

    final random = Random();
    int sqliteCount = 0;
    int firebaseCount = 0;

    for (int i = 1; i <= 100; i++) {
      // Hentikan perulangan jika tombol Cancel ditekan
      if (_cancelProcess) {
        if (mounted) {
          CustomToast.show(
            context,
            'Proses Coroutine dibatalkan pada data ke-$i',
            isError: true,
          );
        }
        break;
      }

      // Jeda 300ms non-blocking (pengganti delay(300L) di Coroutine)
      await Future.delayed(const Duration(milliseconds: 300));

      if (_cancelProcess) {
        if (mounted) {
          CustomToast.show(
            context,
            'Proses Coroutine dibatalkan pada data ke-$i',
            isError: true,
          );
        }
        break;
      }

      // Generate data acak sesuai modul Hal. 7
      final idTran = const Uuid().v4();
      final idBrg = random.nextInt(100) + 1; // 1..100
      final jmlBrg = random.nextInt(20) + 1; // 1..20
      final hrgBrg = 1000 + random.nextInt(99001); // 1000..100000
      final tglTran =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(DateTime.now());

      // Menjalankan insert SQLite dan Firebase secara paralel (Future.wait)
      // persis seperti async { dbHelper.insert(...) } & async { firebaseHelper.insert(...) }
      final results = await Future.wait([
        SqliteDbHelper.instance.insert(
          idTran: idTran,
          idBrg: idBrg,
          jmlBrg: jmlBrg,
          tglTran: tglTran,
          hrgBrg: hrgBrg,
        ),
        FirebaseRealtimeHelper.instance.insert(
          idTran: idTran,
          idBrg: idBrg,
          jmlBrg: jmlBrg,
          tglTran: tglTran,
          hrgBrg: hrgBrg,
        ),
      ]);

      if (results[0]) sqliteCount++;
      if (results[1]) firebaseCount++;

      // Memperbarui UI progress bar & teks secara real-time
      if (mounted) {
        setState(() {
          _asyncSqliteProgress = sqliteCount;
          _asyncFirebaseProgress = firebaseCount;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isAsyncRunning = false;
      });
      if (!_cancelProcess) {
        CustomToast.show(
          context,
          'Proses insert data selesai',
          isSuccess: true,
        );
      }
    }
  }

  /// MODE 2: TANPA THREAD (SYNCHRONOUS BLOCKING)
  void _startSendingNoThread() {
    if (_isAsyncRunning || _isNoThreadRunning) return;

    setState(() {
      _cancelProcess = false;
      _isNoThreadRunning = true;
      _noThreadFirebaseProgress = 0;
      _noThreadSqliteProgress = 0;
    });

    // Menunggu 1 frame agar status awal ter-render sebelum main thread diblokir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final random = Random();

      for (int i = 1; i <= 100; i++) {
        if (_cancelProcess) break;

        // sleep(300ms) secara sinkron menghentikan main isolate thread
        // Menghasilkan freeze/lag persis seperti SystemClock.sleep(300L) di modul
        sleep(const Duration(milliseconds: 300));

        final idTran = const Uuid().v4();
        final idBrg = random.nextInt(100) + 1;
        final jmlBrg = random.nextInt(20) + 1;
        final hrgBrg = 1000 + random.nextInt(99001);
        final tglTran =
            DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(DateTime.now());

        // Insert ke SQLite & Firebase
        SqliteDbHelper.instance.insert(
          idTran: idTran,
          idBrg: idBrg,
          jmlBrg: jmlBrg,
          tglTran: tglTran,
          hrgBrg: hrgBrg,
        );

        FirebaseRealtimeHelper.instance.insert(
          idTran: idTran,
          idBrg: idBrg,
          jmlBrg: jmlBrg,
          tglTran: tglTran,
          hrgBrg: hrgBrg,
        );

        _noThreadSqliteProgress = i;
        _noThreadFirebaseProgress = i;
      }

      // Setelah sleep selesai, thread kembali responsif
      if (mounted) {
        setState(() {
          _isNoThreadRunning = false;
        });
        CustomToast.show(
          context,
          'Proses insert data selesai',
          isSuccess: true,
        );
      }
    });
  }

  /// Tombol Cancel (Modul Hal. 6-7)
  void _handleCancel() {
    _cancelProcess = true;
    CustomToast.show(
      context,
      'Permintaan pembatalan dikirim (Cancel = true)',
      isError: true,
    );
  }

  /// Tombol Info (Modul Hal. 6-7)
  void _handleInfo() {
    // Toast persis seperti modul Hal. 7: "Demo penggunaan thread pada aplikasi"
    CustomToast.show(
      context,
      'Demo penggunaan thread pada aplikasi',
      isSuccess: false,
    );

    // Tampilkan BottomSheet penjelasan perbandingan Before & After
    _showBeforeAfterInfoSheet();
  }

  /// Reset semua progress bar
  void _handleReset() {
    if (_isAsyncRunning || _isNoThreadRunning) return;
    setState(() {
      _asyncFirebaseProgress = 0;
      _asyncSqliteProgress = 0;
      _noThreadFirebaseProgress = 0;
      _noThreadSqliteProgress = 0;
    });
    CustomToast.show(context, 'Progress berhasil direset ke 0/100');
  }

  void _showBeforeAfterInfoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline, color: Color(0xFF0284C7)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perbandingan Thread & Coroutine',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Modul Pertemuan 13 - Pemrograman Mobile Lanjut',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card Before (Tanpa Thread)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Before: Tanpa Thread (Synchronous)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Operasi sleep(300ms) berjalan di Main Thread (UI Thread). Akibatnya UI membeku total (Freeze/ANR), animasi berhenti, tombol Cancel/Info tidak merespons hingga 100 iterasi selesai.',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF7F1D1D)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Card After (Coroutine / Async)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF16A34A)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'After: Coroutine / Asynchronous',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF166534),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Operasi Future.delayed(300ms) dan Future.wait berjalan non-blocking di latar belakang. UI tetap responsif 60 FPS, progress bar bergerak bertahap, dan tombol Cancel bisa diklik kapan saja.',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF14532D)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Tutup Penjelasan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAnyRunning = _isAsyncRunning || _isNoThreadRunning;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pml13 - Threads & Coroutine',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Firebase Realtime & SQLite Parallel Task',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reset Progress',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: isAnyRunning ? null : _handleReset,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              _buildHeaderSection(),
              const SizedBox(height: 14),

              // UI Thread Heartbeat Monitor
              _buildThreadHeartbeatCard(),
              const SizedBox(height: 16),

              // Title sesuai modul: "Kirim data ke Firebase dan SQLite"
              const Center(
                child: Text(
                  'Kirim data ke Firebase dan SQLite',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // SEKSI 1: Menggunakan Thread (Coroutine)
              _buildSectionCard(
                title: 'Menggunakan Thread (Coroutine)',
                badgeText: 'ASYNCHRONOUS (NON-BLOCKING)',
                badgeColor: const Color(0xFF16A34A),
                firebaseProgress: _asyncFirebaseProgress,
                sqliteProgress: _asyncSqliteProgress,
                buttonColor: const Color(0xFF2E7D32),
                buttonLabel: 'Kirim Data',
                isRunning: _isAsyncRunning,
                isDisabled: isAnyRunning,
                onPressed: _startSendingAsync,
                isCoroutinesSection: true,
              ),
              const SizedBox(height: 18),

              // SEKSI 2: Tanpa Menggunakan Thread
              _buildSectionCard(
                title: 'Tanpa Menggunakan Thread',
                badgeText: 'MAIN THREAD (UI FREEZE / ANR)',
                badgeColor: const Color(0xFFDC2626),
                firebaseProgress: _noThreadFirebaseProgress,
                sqliteProgress: _noThreadSqliteProgress,
                buttonColor: const Color(0xFFC62828),
                buttonLabel: 'Kirim Data',
                isRunning: _isNoThreadRunning,
                isDisabled: isAnyRunning,
                onPressed: _startSendingNoThread,
                isCoroutinesSection: false,
              ),
              const SizedBox(height: 20),

              // Tombol Bawah: CANCEL & INFO (Sesuai Layout Modul)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _handleCancel,
                        icon: const Icon(Icons.close_rounded, size: 20),
                        label: const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C), // Orange
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _handleInfo,
                        icon: const Icon(Icons.info_rounded, size: 20),
                        label: const Text(
                          'INFO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7), // Blue
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Header ringkasan atas
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.swap_calls_rounded, color: Color(0xFF4F46E5), size: 26),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uji Coba Thread vs Coroutine',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Bandingkan responsivitas layar antara async dan sleep',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Live UI Thread Heartbeat Monitor
  /// Indikator ini berputar mulus 60 FPS pada mode Coroutine,
  /// dan akan MACET TOTAL (freeze) saat mode Tanpa Thread berjalan.
  Widget _buildThreadHeartbeatCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isNoThreadRunning
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isNoThreadRunning
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        children: [
          RotationTransition(
            turns: _pulseController,
            child: Icon(
              Icons.sync_rounded,
              size: 26,
              color: _isNoThreadRunning
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isNoThreadRunning
                      ? 'Status UI Thread: MEMBEKU (Freeze / ANR)'
                      : _isAsyncRunning
                          ? 'Status UI Thread: RESPONSIF (Non-blocking)'
                          : 'Status UI Thread: Standby / Responsif',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _isNoThreadRunning
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  _isNoThreadRunning
                      ? 'sleep(300ms) memblokir Main Thread! Animasi ikut macet.'
                      : 'Indikator ini berputar mulus membuktikan UI tidak lag.',
                  style: TextStyle(
                    fontSize: 11,
                    color: _isNoThreadRunning
                        ? const Color(0xFF991B1B)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget Card untuk Seksi (Menggunakan Thread vs Tanpa Thread)
  Widget _buildSectionCard({
    required String title,
    required String badgeText,
    required Color badgeColor,
    required int firebaseProgress,
    required int sqliteProgress,
    required Color buttonColor,
    required String buttonLabel,
    required bool isRunning,
    required bool isDisabled,
    required VoidCallback onPressed,
    required bool isCoroutinesSection,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRunning
              ? buttonColor.withValues(alpha: 0.6)
              : const Color(0xFFE2E8F0),
          width: isRunning ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Firebase Item (Label, Horizontal ProgressBar, Count Text)
          _buildProgressRow(
            label: 'Firebase',
            progress: firebaseProgress,
            activeColor: isCoroutinesSection
                ? const Color(0xFF0284C7)
                : const Color(0xFFEA580C),
          ),
          const SizedBox(height: 14),

          // SQLite Item (Label, Horizontal ProgressBar, Count Text)
          _buildProgressRow(
            label: 'SQLite',
            progress: sqliteProgress,
            activeColor: isCoroutinesSection
                ? const Color(0xFF16A34A)
                : const Color(0xFFDC2626),
          ),
          const SizedBox(height: 18),

          // Tombol "Kirim Data"
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: isDisabled ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey.shade600,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isRunning
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Memproses ($sqliteProgress/100)...',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Baris item Progress Bar horizontal persis seperti di layout XML Android
  Widget _buildProgressRow({
    required String label,
    required int progress,
    required Color activeColor,
  }) {
    final double ratio = (progress / 100.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                ),
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 52,
              child: Text(
                '$progress/100',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
