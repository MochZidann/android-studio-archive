# PML 09 - Firebase Remote Config (Flutter)

Aplikasi Flutter untuk implementasi materi praktikum **Pemrograman Mobile Lanjut: Pertemuan 9 - Remote Config**.

## 📋 Ringkasan Konfigurasi Firebase Remote Config (Modul Hal. 1 & 2)

Di Firebase Console (DevOps & Engagement > Remote Config), buat parameter berikut:

| Parameter Key | Data Type | Default Value | Keterangan |
| :--- | :--- | :--- | :--- |
| `font_color` | `String` | `#ff0000` | Kode hex warna teks target |
| `font_size` | `Number` | `30` | Ukuran font teks target |

> **Catatan**: Setelah menambah parameter, klik tombol **Publish Changes** di Firebase Console.

---

## 🛠️ Arsitektur & File Utama

- [lib/main.dart](file:///c:/Users/Zidan/AndroidStudioProjects/Pml09/lib/main.dart): Inisialisasi Firebase Core & tema aplikasi.
- [lib/screens/remote_config_screen.dart](file:///c:/Users/Zidan/AndroidStudioProjects/Pml09/lib/screens/remote_config_screen.dart):
  - Inisialisasi `FirebaseRemoteConfig` dengan `minimumFetchInterval: Duration.zero` (interval pengambilan 0 detik agar perubahan langsung aktif).
  - Tombol **"Refresh Remote Config"** yang memanggil `remoteConfig.fetchAndActivate()`.
  - Notifikasi Toast berhasil ("Konfigurasi Berhasil Diaktifkan") dan gagal ("Konfigurasi Gagal Diaktifkan").
  - Fungsi `_updateUI()` untuk memperbarui ukuran (`font_size`) dan warna (`font_color`) pada teks **"Testing!"**.
  - Dilengkapi tombol **Simulasi Nilai Modul** untuk pengujian langsung tanpa menunggu koneksi Firebase.
- [lib/widgets/custom_toast.dart](file:///c:/Users/Zidan/AndroidStudioProjects/Pml09/lib/widgets/custom_toast.dart): Komponen toast/floating snackbar notifikasi.
- [test/remote_config_test.dart](file:///c:/Users/Zidan/AndroidStudioProjects/Pml09/test/remote_config_test.dart): Unit & widget test.

---

## 🚀 Cara Menjalankan

1. Pastikan dependencies sudah terpasang:
   ```bash
   flutter pub get
   ```
2. Jalankan aplikasi pada emulator atau perangkat fisik:
   ```bash
   flutter run
   ```
3. Klik tombol **Refresh Remote Config** untuk mengambil nilai terbaru dari Firebase Console, atau klik **Simulasi Nilai Modul** untuk demo instan.
