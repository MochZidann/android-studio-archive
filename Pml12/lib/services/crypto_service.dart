import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;

class CryptoService {
  // Data tambahan sebelum plaintext sesuai modul
  static const String dummyStr = '0000000000000000:;';
  
  // Panjang key yang diizinkan (128, 192, 256-bit -> 16, 24, 32 byte)
  static const Set<int> panjangKey = {16, 24, 32};

  /// Validasi dan buat SecretKey AES dari string input
  static enc.Key? generateSecretKey(String secret) {
    final keyBytes = utf8.encode(secret);
    if (!panjangKey.contains(keyBytes.length)) {
      return null;
    }
    return enc.Key(Uint8List.fromList(keyBytes));
  }

  /// Buat Initialization Vector (IV) acak 16-byte (128-bit)
  static enc.IV generateInitVect() {
    return enc.IV.fromSecureRandom(16);
  }

  /// Enkripsi plainText menggunakan AES-CBC dengan PKCS7 padding dan prepend dummyStr
  static String encrypt({
    required String plainText,
    required enc.Key secretKey,
    required enc.IV iv,
  }) {
    final encrypter = enc.Encrypter(enc.AES(secretKey, mode: enc.AESMode.cbc));
    final dataToEncrypt = dummyStr + plainText;
    final encrypted = encrypter.encrypt(dataToEncrypt, iv: iv);
    return encrypted.base64;
  }

  /// Dekripsi ciphertext Base64 menggunakan AES-CBC dan hapus dummyStr
  /// Melempar Exception jika key salah atau proses dekripsi gagal
  static String decrypt({
    required String encryptedText,
    required enc.Key secretKey,
    required enc.IV iv,
  }) {
    final encrypter = enc.Encrypter(enc.AES(secretKey, mode: enc.AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);

    if (decrypted.startsWith(dummyStr)) {
      return decrypted.substring(dummyStr.length);
    }

    final delimiterIndex = decrypted.indexOf(':;');
    if (delimiterIndex != -1) {
      return decrypted.substring(delimiterIndex + 2);
    }

    // Jika tidak diawali dummyStr/delimiter, kemungkinan format rusak / key tidak cocok
    throw const FormatException('Data terdekripsi tidak memiliki header yang valid');
  }
}

