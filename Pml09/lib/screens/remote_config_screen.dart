import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../widgets/custom_toast.dart';

/// Screen Implementasi Pertemuan 9 - Remote Config
/// Berdasarkan Modul Pemrograman Mobile Lanjut (PML 09)
class RemoteConfigScreen extends StatefulWidget {
  const RemoteConfigScreen({super.key});

  @override
  State<RemoteConfigScreen> createState() => _RemoteConfigScreenState();
}

class _RemoteConfigScreenState extends State<RemoteConfigScreen> {
  // Deklarasi variabel Remote Config & state UI
  FirebaseRemoteConfig? _remoteConfig;
  bool _isLoading = false;
  bool _isFirebaseReady = false;

  // Nilai default awal sebelum fetch (sesuai modul tampilan awal)
  double _fontSize = 18.0;
  Color _fontColor = const Color(0xFF0F172A); // Default hitam / dark slate
  String _rawColorString = '#0F172A';
  DateTime? _lastFetchTime;
  String _statusText = 'Belum di-fetch (Nilai Awal)';

  @override
  void initState() {
    super.initState();
    _initializeRemoteConfig();
  }

  /// Inisialisasi Firebase Remote Config
  Future<void> _initializeRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      // Inisialisasi config settings (minimum fetch interval 0 detik)
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      // Menetapkan nilai default in-app
      await remoteConfig.setDefaults(const {
        'font_size': 18.0,
        'font_color': '#0F172A',
      });

      setState(() {
        _remoteConfig = remoteConfig;
        _isFirebaseReady = true;
      });

      developer.log('Firebase Remote Config siap digunakan', name: 'Remote Config');
    } catch (e) {
      developer.log('Firebase Remote Config init error: $e', name: 'Remote Config');
      setState(() {
        _isFirebaseReady = false;
      });
    }
  }

  /// Fungsi fetchRemoteConfig()
  Future<void> _fetchRemoteConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_remoteConfig == null) {
        throw Exception('Firebase Remote Config belum terinisialisasi');
      }

      // Fetch dan aktifkan konfigurasi terbaru dari Firebase Console
      final bool updated = await _remoteConfig!.fetchAndActivate();

      developer.log('Remote Config: Berhasil (updated: $updated)', name: 'Remote Config');

      // Update tampilan UI dari Remote Config
      _updateUI();

      if (mounted) {
        CustomToast.show(
          context,
          'Konfigurasi Berhasil Diaktifkan',
          isSuccess: true,
        );

        setState(() {
          _lastFetchTime = DateTime.now();
          _statusText = 'Berhasil Diaktifkan dari Cloud';
        });
      }
    } catch (e) {
      developer.log('Remote Config: Gagal ($e)', name: 'Remote Config');

      if (mounted) {
        // Tampilkan Toast gagal (Modul Hal 3: "Konfigurasi Gagal Diaktifkan")
        CustomToast.show(
          context,
          'Konfigurasi Gagal Diaktifkan: ${e.toString().split('\n').first}',
          isError: true,
        );

        setState(() {
          _statusText = 'Fetch Gagal: Cek koneksi / google-services.json';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Fungsi updateUI()
  /// val fontSize = remoteConfig.getDouble("font_size").toFloat()
  /// val fontColor = remoteConfig.getString("font_color")
  /// binding.tvMessage.textSize = fontSize
  /// binding.tvMessage.setTextColor(Color.parseColor(fontColor))
  void _updateUI() {
    if (_remoteConfig == null) return;

    // Ambil parameter font_size dan font_color
    final double newFontSize = _remoteConfig!.getDouble('font_size');
    final String newFontColorStr = _remoteConfig!.getString('font_color');

    setState(() {
      if (newFontSize > 0) {
        _fontSize = newFontSize;
      }
      _rawColorString = newFontColorStr.isNotEmpty ? newFontColorStr : _rawColorString;
      _fontColor = _parseColor(_rawColorString);
    });
  }

  /// Parse kode warna Hex String ke Flutter Color
  /// Analog dengan Color.parseColor(fontColor) di Android Kotlin
  Color _parseColor(String hexColorString, {Color defaultColor = Colors.black}) {
    try {
      String hex = hexColorString.replaceAll('#', '').trim();
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
      return defaultColor;
    } catch (e) {
      return defaultColor;
    }
  }

  /// Simulasi lokal nilai konfigurasi (Sesuai Modul: font_size = 30, font_color = #ff0000)
  /// Membantu mahasiswa menguji visual modul meskipun belum terhubung internet/firebase console
  void _simulateRemoteConfig() {
    setState(() {
      _fontSize = 30.0;
      _rawColorString = '#ff0000';
      _fontColor = _parseColor(_rawColorString);
      _statusText = 'Simulasi Sesuai Modul (size: 30, color: #ff0000)';
    });

    CustomToast.show(
      context,
      'Konfigurasi Berhasil Diaktifkan (Simulasi Modul)',
      isSuccess: true,
    );
  }

  /// Reset nilai ke awal (default)
  void _resetToDefault() {
    setState(() {
      _fontSize = 18.0;
      _rawColorString = '#0F172A';
      _fontColor = const Color(0xFF0F172A);
      _statusText = 'Reset ke Nilai Awal';
    });
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
              'Pml09',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Pertemuan 9 - Remote Config',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Reset Tampilan',
            onPressed: _resetToDefault,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Informasi Modul
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.cloud_sync_outlined,
                        color: Color(0xFF4F46E5),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Firebase Remote Config',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isFirebaseReady
                                ? 'Status: Terhubung ke Firebase'
                                : 'Status: Menunggu inisialisasi / offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isFirebaseReady
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFEA580C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // AREA UTAMA: Tampilan Teks "Testing!" (tvMessage dari Modul)
              Container(
                constraints: const BoxConstraints(minHeight: 180),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Target Tampilan (tvMessage):',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Widget Teks Target yang dinamis
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        fontSize: _fontSize,
                        color: _fontColor,
                        fontWeight: FontWeight.bold,
                      ),
                      child: const Text('Testing!'),
                    ),
                    const SizedBox(height: 20),
                    // Label Nilai Aktif
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        Chip(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(0xFFF1F5F9),
                          label: Text(
                            'font_size: ${_fontSize.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        Chip(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(0xFFF1F5F9),
                          avatar: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _fontColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          ),
                          label: Text(
                            'font_color: $_rawColorString',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tombol Utama: btnRefresh ("Refresh Remote Config" sesuai modul)
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _fetchRemoteConfig,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    _isLoading
                        ? 'Mengambil Konfigurasi...'
                        : 'Refresh Remote Config',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tombol Tambahan: Simulasi Nilai Modul (font_size=30, font_color=#ff0000)
              OutlinedButton.icon(
                onPressed: _simulateRemoteConfig,
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('Simulasi Nilai Modul (#ff0000, size 30)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4F46E5),
                  side: const BorderSide(color: Color(0xFFC7D2FE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),

              const SizedBox(height: 24),

              // Detail Parameter & Panduan Modul Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Parameter Firebase Console (Modul Hal 1 & 2):',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildParamRow(
                      keyName: 'font_color',
                      type: 'String',
                      value: '#ff0000 (Warna Merah)',
                    ),
                    const Divider(height: 18),
                    _buildParamRow(
                      keyName: 'font_size',
                      type: 'Number',
                      value: '30 (Ukuran Font)',
                    ),
                    const Divider(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Status saat ini: $_statusText'
                            '${_lastFetchTime != null ? '\nTerakhir fetch: ${_lastFetchTime!.hour.toString().padLeft(2, '0')}:${_lastFetchTime!.minute.toString().padLeft(2, '0')}:${_lastFetchTime!.second.toString().padLeft(2, '0')}' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildParamRow({
    required String keyName,
    required String type,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            keyName,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '($type)',
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
