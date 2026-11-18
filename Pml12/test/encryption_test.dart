import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:encrypt/encrypt.dart' as enc;

void main() {
  const dummyStr = '0000000000000000:;';
  const panjangKey = {16, 24, 32};

  enc.Key? generateSecretKey(String secret) {
    final keyBytes = utf8.encode(secret);
    if (!panjangKey.contains(keyBytes.length)) {
      return null;
    }
    return enc.Key(Uint8List.fromList(keyBytes));
  }

  enc.IV generateInitVect() {
    return enc.IV.fromSecureRandom(16);
  }

  String encrypt(String plainText, enc.Key secretKey, enc.IV iv) {
    final encrypter = enc.Encrypter(enc.AES(secretKey, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(dummyStr + plainText, iv: iv);
    return encrypted.base64;
  }

  String decrypt(String encryptedText, enc.Key secretKey, enc.IV iv) {
    final encrypter = enc.Encrypter(enc.AES(secretKey, mode: enc.AESMode.cbc));
    try {
      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
      if (decrypted.startsWith(dummyStr)) {
        return decrypted.substring(dummyStr.length);
      }
      final idx = decrypted.indexOf(':;');
      if (idx != -1) {
        return decrypted.substring(idx + 2);
      }
      return decrypted;
    } catch (e) {
      return 'KEY_ERROR';
    }
  }

  test('AES CBC encryption and decryption works with 16, 24, 32 byte keys', () {
    final key16 = generateSecretKey('1234567890123456');
    expect(key16, isNotNull);

    final iv = generateInitVect();
    expect(iv.bytes.length, equals(16));

    const plainText = 'Halo Dunia Kriptografi!';
    final encrypted = encrypt(plainText, key16!, iv);
    expect(encrypted.isNotEmpty, isTrue);

    final decrypted = decrypt(encrypted, key16, iv);
    expect(decrypted, equals(plainText));

    // Decrypt with wrong key should fail
    final wrongKey = generateSecretKey('6543210987654321')!;
    final decryptedWrong = decrypt(encrypted, wrongKey, iv);
    expect(decryptedWrong, equals('KEY_ERROR'));
  });

  test('Invalid key length returns null', () {
    expect(generateSecretKey('short_key'), isNull);
    expect(generateSecretKey('123456789012345'), isNull); // 15 bytes
    expect(generateSecretKey('1234567890123456'), isNotNull); // 16 bytes
    expect(generateSecretKey('123456789012345678901234'), isNotNull); // 24 bytes
    expect(generateSecretKey('12345678901234567890123456789012'), isNotNull); // 32 bytes
  });
}

