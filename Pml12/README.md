# PML Pertemuan 12 — AES Encryption & Decryption (Flutter)

Aplikasi praktikum **Pemrograman Mobile Lanjut (Pertemuan 12: Encryption)** yang mengimplementasikan kriptografi simetris menggunakan algoritma **AES (*Advanced Encryption Standard*)** dalam mode operasi **CBC (*Cipher Block Chaining*)** dengan **IV (*Initialization Vector*)** dinamis 16-byte acak.

---

## 🔒 Konsep & Fitur Utama

1. **AES CBC (Cipher Block Chaining):**
   - Mode blok simetris dengan keterkaitan antar blok.
   - Menggunakan padding standar **PKCS7**.
   - Menambahkan header dummy `0000000000000000:;` sebelum plaintext untuk validasi integritas dekripsi sesuai modul.
2. **Initialization Vector (IV):**
   - 16-byte acak unik (`SecureRandom`) yang dibuat otomatis setiap kali enkripsi dijalankan.
   - Menjamin teks sama yang dienkripsi berulang kali akan menghasilkan ciphertext yang berbeda.
3. **Validasi Panjang Secret Key:**
   - Mendukung standar AES: **128-bit (16 byte)**, **192-bit (24 byte)**, atau **256-bit (32 byte)**.
   - Validasi otomatis dengan notifikasi *"Panjang key harus 16/24/32 byte"*.
4. **Validasi Dekripsi:**
   - Validasi keberadaan IV: *"Silakan lakukan enkripsi terlebih dahulu!"*.
   - Validasi kecocokan kunci: *"Key salah!"* jika kunci tidak cocok.
5. **UI & UX Modern:**
   - Mengikuti tema bawaan proyek (*Slate & Indigo*).
   - Dilengkapi shortcut:
     - `Sample 16B` untuk mengisi key contoh yang valid.
     - `Gunakan Key Enkripsi` untuk menyalin key enkripsi ke form dekripsi.
     - Tombol salin clipboard pada hasil enkripsi dan dekripsi.

---

## 📂 Struktur Kode

- `lib/services/crypto_service.dart`: Logika enkripsi AES-CBC, dekripsi, pemotongan header dummy, pembuatan IV acak, dan pembentukan SecretKey.
- `lib/screens/home_screen.dart`: Tampilan UI kartu Enkripsi dan Dekripsi, penanganan tombol, dan manajemen state IV.
- `lib/widgets/custom_text_field.dart`: Widget input field kustom dengan dukungan password obscure, helper counter byte, dan suffix button.
- `lib/widgets/custom_toast.dart`: Komponen notifikasi snackbar mengambang untuk pesan sukses/gagal.
- `test/encryption_test.dart`: Unit test mandiri logika AES CBC.
- `test/widget_test.dart`: Widget test alur pengguna dari enkripsi hingga dekripsi.

---

## 🚀 Cara Menjalankan

1. **Unduh dependency:**
   ```bash
   flutter pub get
   ```

2. **Jalankan pengujian otomatis:**
   ```bash
   flutter test
   ```

3. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```
