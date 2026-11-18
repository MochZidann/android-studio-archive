import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart' as enc;
import '../services/crypto_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_toast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller untuk Card Enkripsi
  final TextEditingController _plainTextController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();
  final TextEditingController _encryptedTextController = TextEditingController();

  // Controller untuk Card Dekripsi
  final TextEditingController _secretKey2Controller = TextEditingController();
  final TextEditingController _decryptedTextController = TextEditingController();

  // State penyimpanan IV (Initialization Vector) dari proses enkripsi terakhir
  enc.IV? _currentIv;
  bool _wrongKey = false;

  @override
  void dispose() {
    _plainTextController.dispose();
    _secretKeyController.dispose();
    _encryptedTextController.dispose();
    _secretKey2Controller.dispose();
    _decryptedTextController.dispose();
    super.dispose();
  }

  /// Helper untuk mendapatkan feedback panjang key dalam byte
  String _getKeyLengthHelper(String text) {
    final byteLen = utf8.encode(text).length;
    if (byteLen == 0) return 'Panjang harus 16, 24, atau 32 byte';
    if (CryptoService.panjangKey.contains(byteLen)) {
      return '$byteLen byte (Valid ✓)';
    }
    return '$byteLen byte (Kurang/lebih, butuh 16/24/32 byte)';
  }

  /// Buat secret key AES dari input text
  enc.Key? _generateSecretKey(String secret) {
    final keyBytes = utf8.encode(secret);
    if (!CryptoService.panjangKey.contains(keyBytes.length)) {
      _wrongKey = true;
      CustomToast.show(
        context,
        'Panjang key harus 16/24/32 byte',
        isError: true,
      );
      return null;
    }
    _wrongKey = false;
    return CryptoService.generateSecretKey(secret);
  }

  /// Proses Enkripsi sesuai modul Pertemuan 12
  void _handleEncrypt() {
    final plainText = _plainTextController.text;
    final secretStr = _secretKeyController.text;

    if (plainText.isEmpty) {
      CustomToast.show(context, 'Teks yang akan dienkripsi tidak boleh kosong!', isError: true);
      return;
    }

    final secretKey = _generateSecretKey(secretStr);
    if (secretKey != null && !_wrongKey) {
      // Buat IV baru dan simpan (generateInitVect)
      final iv = CryptoService.generateInitVect();
      _currentIv = iv;

      // Enkripsi plaintext
      final encryptedBase64 = CryptoService.encrypt(
        plainText: plainText,
        secretKey: secretKey,
        iv: iv,
      );

      setState(() {
        _encryptedTextController.text = encryptedBase64;
      });

      CustomToast.show(
        context,
        'Enkripsi berhasil dengan AES-CBC!',
        isSuccess: true,
      );
    }
  }

  /// Proses Dekripsi sesuai modul Pertemuan 12
  void _handleDecrypt() {
    final encryptedText = _encryptedTextController.text.trim();
    final secretStr = _secretKey2Controller.text;

    if (_currentIv == null) {
      CustomToast.show(
        context,
        'Silakan lakukan enkripsi terlebih dahulu!',
        isError: true,
      );
      return;
    }

    if (encryptedText.isEmpty) {
      CustomToast.show(
        context,
        'Belum ada teks terenkripsi untuk didekripsi!',
        isError: true,
      );
      return;
    }

    final secretKey = _generateSecretKey(secretStr);
    if (secretKey != null && _currentIv != null) {
      try {
        final decrypted = CryptoService.decrypt(
          encryptedText: encryptedText,
          secretKey: secretKey,
          iv: _currentIv!,
        );

        setState(() {
          _decryptedTextController.text = decrypted;
        });

        CustomToast.show(
          context,
          'Dekripsi berhasil!',
          isSuccess: true,
        );
      } catch (e) {
        CustomToast.show(
          context,
          'Key salah!',
          isError: true,
        );
        setState(() {
          _decryptedTextController.text = '';
        });
      }
    }
  }

  /// Shortcut untuk mengisi key contoh (16 byte)
  void _fillSampleKey(TextEditingController controller) {
    setState(() {
      controller.text = '1234567890123456';
    });
  }

  /// Salin teks ke clipboard
  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    CustomToast.show(context, '$label disalin ke clipboard', isSuccess: true);
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
              'Pml12 — Encryption',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'AES (CBC Mode + IV) Kriptografi',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card Info
              _buildHeaderInfoCard(),
              const SizedBox(height: 16),

              // CARD 1: ENKRIPSI
              _buildEncryptCard(),
              const SizedBox(height: 20),

              // CARD 2: DEKRIPSI
              _buildDecryptCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF4F46E5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AES-CBC & IV Security',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kunci: 16, 24, 32 byte | IV: 16 byte acak | PKCS7',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_currentIv != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.vpn_key_outlined, size: 16, color: Color(0xFF475569)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Active IV (Base64): ${_currentIv!.base64}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEncryptCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE047), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEAB308).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner judul Enkripsi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF9C3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCA8A04),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.enhanced_encryption, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Text(
                  'ENKRIPSI (AES)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF854D0E),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PlainText Input (edPlainText)
                CustomTextField(
                  controller: _plainTextController,
                  label: 'Teks Asli (Plaintext)',
                  hint: 'Masukkan teks yang akan di enkripsi',
                  icon: Icons.text_snippet_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),

                // SecretKey Input (edSecretKey)
                CustomTextField(
                  controller: _secretKeyController,
                  label: 'Secret Key (16 / 24 / 32 byte)',
                  hint: 'Masukkan secret key',
                  icon: Icons.key_outlined,
                  isPassword: true,
                  onChanged: (val) => setState(() {}),
                  helperText: _getKeyLengthHelper(_secretKeyController.text),
                  suffixWidget: TextButton(
                    onPressed: () => _fillSampleKey(_secretKeyController),
                    child: const Text(
                      'Sample 16B',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Tombol Encrypt (btnEncrypt)
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _handleEncrypt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCA8A04),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.lock, size: 18),
                    label: const Text(
                      'Encrypt',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // EncryptedText Output (edEncryptedText)
                CustomTextField(
                  controller: _encryptedTextController,
                  label: 'Text Terenkripsi (Ciphertext Base64)',
                  hint: 'Text terenkripsi akan muncul di sini',
                  icon: Icons.code_outlined,
                  readOnly: true,
                  maxLines: 3,
                  suffixWidget: _encryptedTextController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Color(0xFF64748B)),
                          tooltip: 'Salin Ciphertext',
                          onPressed: () => _copyToClipboard(
                            _encryptedTextController.text,
                            'Ciphertext',
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecryptCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner judul Dekripsi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.no_encryption_gmailerrorred, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Text(
                  'DEKRIPSI (AES)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0369A1),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SecretKey2 Input (edSecretKey2)
                CustomTextField(
                  controller: _secretKey2Controller,
                  label: 'Secret Key untuk Dekripsi',
                  hint: 'Masukkan secret key',
                  icon: Icons.key_outlined,
                  isPassword: true,
                  onChanged: (val) => setState(() {}),
                  helperText: _getKeyLengthHelper(_secretKey2Controller.text),
                  suffixWidget: TextButton(
                    onPressed: () {
                      setState(() {
                        _secretKey2Controller.text = _secretKeyController.text;
                      });
                    },
                    child: const Text(
                      'Gunakan Key Enkripsi',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Tombol Decrypt (btnDecrypt)
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _handleDecrypt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.lock_open, size: 18),
                    label: const Text(
                      'Decrypt',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // DecryptedText Output (edDecryptedText)
                CustomTextField(
                  controller: _decryptedTextController,
                  label: 'Teks Terdekripsi',
                  hint: 'Teks terdekripsi akan tampil di sini',
                  icon: Icons.verified_user_outlined,
                  readOnly: true,
                  maxLines: 3,
                  suffixWidget: _decryptedTextController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Color(0xFF64748B)),
                          tooltip: 'Salin Teks Asli',
                          onPressed: () => _copyToClipboard(
                            _decryptedTextController.text,
                            'Teks Terdekripsi',
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
