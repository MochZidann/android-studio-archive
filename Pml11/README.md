# PML 11 - Implementasi WebView (Flutter)

Aplikasi praktikum **Pemrograman Mobile Lanjut (PML) - Pertemuan 11: WebView**, dikonversi dari modul native Android (Kotlin & XML) ke dalam Flutter dengan arsitektur tema **Slate & Indigo** dan komponen starter template PML.

---

## 📱 Fitur Utama & Kesesuaian Modul

Proyek ini mereplikasi seluruh alur logika dan fungsionalitas dari modul **Pertemuan 11 – Webview**:

1. **Dashboard Halaman Utama (`HomeScreen`)**:
   - Menampilkan 3 tombol utama berbentuk *pill* (corner radius 100dp) sesuai layout XML modul:
     - **TIKTOK**: Membuka `https://www.tiktok.com`
     - **YOUTUBE**: Membuka `https://youtube.com`
     - **AI CHATBOT**: Membuka LLM Chatbot (`https://aistudiollms.pythonanywhere.com/`)
   - Dilengkapi *Custom URL Tester* menggunakan `CustomTextField` dan `CustomToast` untuk menguji URL kustom atau server lokal.

2. **Komponen WebView (`FragmentWebView`)**:
   - Memanfaatkan `webview_flutter` dan `webview_flutter_android`.
   - Mengaktifkan JavaScript (`JavaScriptMode.unrestricted`) dan DOM Storage.
   - Menangani navigasi URL `http://` dan `https://` tanpa berpindah ke browser eksternal.
   - Progress bar loading (`LinearProgressIndicator`).
   - Penanganan error koneksi dengan fitur muat ulang (*reload*) dan simulasi form pesan lokal interaktif jika domain offline.

3. **Bottom Navigation Bar**:
   - Mengikuti struktur `menu_dashboard.xml` dan styling warna pada modul (`#5FD4C3` & `#105B50`):
     - **Home**: Menyembunyikan WebView dan kembali ke Dashboard utama (`View.GONE`).
     - **Location**: Membuka Google Maps lokasi kampus PSDKU Politeknik Negeri Malang di Kota Kediri.
     - **Shop**: Membuka marketplace Shopee (`https://www.shopee.co.id`).
     - **Profile**: Membuka profil Instagram D3 Manajemen Informatika Polinema (`https://www.instagram.com/d3mipolinema/`).

4. **Penanganan Navigasi Tombol Back**:
   - Diimplementasikan menggunakan `PopScope`.
   - Jika WebView sedang terbuka dan memiliki riwayat browsing, tombol back akan mengeksekusi `goBack()`.
   - Jika riwayat sudah habis, tombol back akan menutup WebView dan kembali ke tampilan dashboard.

5. **Global State (`GlobalVariables`)**:
   - Menyimpan variabel URL aktif (`GlobalVariables.url`) sesuai class `GlobalVariable.kt` pada modul.

---

## 🛠️ Struktur Proyek

```text
lib/
├── firebase_options.dart
├── main.dart                      # Entrypoint aplikasi & konfigurasi tema
├── models/
│   └── global_variables.dart      # Penampung variabel URL global (GlobalVariables)
├── screens/
│   ├── fragment_webview.dart      # Implementasi WebView terpadu (FragmentWebView)
│   └── home_screen.dart           # Dashboard utama & BottomNavigationBar
└── widgets/
    ├── custom_text_field.dart     # Input field reusable tema PML
    └── custom_toast.dart          # SnackBar floating notifikasi
```

---

## 🚀 Cara Menjalankan

1. Pastikan Flutter SDK sudah terpasang dan dependencies siap:
   ```bash
   flutter pub get
   ```

2. Jalankan pengujian unit/widget:
   ```bash
   flutter test
   ```

3. Jalankan aplikasi pada emulator atau perangkat Android:
   ```bash
   flutter run
   ```
