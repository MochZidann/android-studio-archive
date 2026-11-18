import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pml12/main.dart';

void main() {
  testWidgets('Enkripsi dan Dekripsi AES pada Pml12 bekerja sesuai modul', (WidgetTester tester) async {
    // Ukuran layar testing diset agar cukup untuk form scroll
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const Pml12App());
    await tester.pumpAndSettle();

    // Pastikan judul dan elemen utama tampil
    expect(find.text('Pml12 — Encryption'), findsOneWidget);
    expect(find.text('ENKRIPSI (AES)'), findsOneWidget);
    expect(find.text('DEKRIPSI (AES)'), findsOneWidget);

    // Cari field plaintext (pertama) dan isi
    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    // Field 0: edPlainText
    await tester.enterText(textFields.at(0), 'Rahasia PML Pertemuan 12');

    // Gunakan shortcut tombol 'Sample 16B' untuk mengisi secret key
    final sampleKeyButton = find.text('Sample 16B');
    await tester.ensureVisible(sampleKeyButton);
    await tester.tap(sampleKeyButton);
    await tester.pumpAndSettle();

    // Tekan tombol Encrypt
    final encryptButton = find.text('Encrypt');
    await tester.ensureVisible(encryptButton);
    await tester.tap(encryptButton);
    await tester.pumpAndSettle();

    // Verifikasi enkripsi menghasilkan toast sukses
    expect(find.text('Enkripsi berhasil dengan AES-CBC!'), findsOneWidget);

    // Gunakan shortcut tombol 'Gunakan Key Enkripsi' pada Card Dekripsi
    final copyKeyButton = find.text('Gunakan Key Enkripsi');
    await tester.ensureVisible(copyKeyButton);
    await tester.tap(copyKeyButton);
    await tester.pumpAndSettle();

    // Tekan tombol Decrypt
    final decryptButton = find.text('Decrypt');
    await tester.ensureVisible(decryptButton);
    await tester.tap(decryptButton);
    await tester.pumpAndSettle();

    // Verifikasi teks berhasil didekripsi kembali ke teks asli
    expect(find.text('Dekripsi berhasil!'), findsOneWidget);
    expect(find.text('Rahasia PML Pertemuan 12'), findsWidgets);
  });
}
