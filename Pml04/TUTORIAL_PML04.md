# Panduan Lengkap & Dokumentasi: PML04 - Firebase Authentication & Role-Based Access

Aplikasi **Pml04** dibangun menggunakan framework **Flutter** dengan mengacu pada silabus praktikum **Pemrograman Mobile Lanjut (Pertemuan 4)**. Aplikasi ini mengintegrasikan **Firebase Authentication** untuk manajemen akun & verifikasi email serta **Cloud Firestore** untuk penyimpanan profil pengguna dan hak akses peran (*Role-Based Access: Admin vs Pelanggan*). Desain antarmuka dirancang serasi dan elegan dengan palet warna modern **Slate & Indigo** identik dengan PML02 dan PML03.

---

## 1. Arsitektur & Alur Kerja Sistem (Flowchart)

```
[Mulai]
   │
   ├──> [Halaman Sign In] ──(Belum punya akun?)──> [Halaman Sign Up]
   │           │                                         │
   │           │ (Input Email & Password)                │ (Input Lengkap + Pilih Role)
   │           ▼                                         ▼
   │     Firebase Auth:                            Firebase Auth:
   │    signInWithEmailPassword                   createUserWithEmailAndPassword
   │           │                                         │
   │           ├─[Gagal]─> Toast: "Email atau Password   │
   │           │                  salah"                 ▼
   │           ▼                                  Simpan ke Firestore:
   │    Cek isEmailVerified                        users/{uid} (role, biodata)
   │           │                                         │
   │           ├─[False]─> Toast: "Email belum           ▼
   │           │                  diverifikasi"   Kirim Email Verifikasi
   │           │                                         │
   │           ▼ [True]                                  ▼
   │    Ambil Data Firestore:                     Toast Sukses & Kembali
   │         users/{uid}                           ke Halaman Sign In
   │           │
   │           ├──> (role == "admin")     ──> [DASHBOARD ADMIN]
   │           │                                     │
   │           └──> (role == "pelanggan") ──> [DASHBOARD PELANGGAN]
   │                                                 │
   │                                           [Tombol Logout]
   │                                                 │
   │                                                 ▼
   └────────────────────────────────────────── Kembali ke Sign In
```

---

## 2. Struktur Proyek Flutter PML04

```
lib/
├── firebase_options.dart              # Konfigurasi platform Firebase untuk com.example.pml04
├── main.dart                          # Inisialisasi Firebase Core & tema utama
├── models/
│   └── user_model.dart                # Model data pengguna (UID, Email, Nama, Alamat, HP, Role)
├── services/
│   └── auth_service.dart              # Layanan otentikasi Firebase Auth & integrasi Firestore
├── widgets/
│   ├── custom_text_field.dart         # Form input konsisten bergaya PML
│   └── custom_toast.dart              # SnackBar toast melayang (Sukses/Error/Info)
└── screens/
    ├── sign_in_screen.dart            # Halaman Login (AuthenticationSigninActivity)
    ├── sign_up_screen.dart            # Halaman Registrasi (AuthenticationSignupActivity)
    ├── admin_dashboard_screen.dart    # Dashboard khusus Admin (AdminActivity)
    └── pelanggan_dashboard_screen.dart# Dashboard khusus Pelanggan (PelangganActivity)
```

---

## 3. Desain UI & Skema Warna Tombol (Design System)

Desain diselaraskan dengan standar PML sebelumnya:
* **Tombol Sign In & Sign Up Utama**: Indigo `#4F46E5` (Font tebal, radius 10px, elevasi lembut).
* **Tombol Register (Navigasi)**: Outlined Indigo `#4F46E5` dengan background bersih.
* **Tombol Logout**: Crimson Red `#DC2626` dengan ikon logout dan dialog konfirmasi.
* **Radio Selector Role**: Kartu interaktif responsif dengan indikator dot indigo saat dipilih.
* **Badge Role**:
  * **Admin**: Badge soft indigo `#EEF2FF` dengan teks `#4338CA`.
  * **Pelanggan**: Badge soft emerald `#ECFDF5` dengan teks `#047857`.
* **Input Fields**: Background `#F8FAFC`, border lembut `#E2E8F0`, dan highlight focus `#4F46E5` (tebal 1.8px) lengkap dengan ikon di sisi kiri.
* **Notifikasi Floating Toast**:
  * **Sukses**: Hijau `#16A34A`
  * **Gagal / Validasi**: Merah `#DC2626`
  * **Info**: Indigo `#4F46E5`

---

## 4. Persiapan di Firebase Console

Sebelum menjalankan aplikasi, pastikan pengaturan berikut aktif di Firebase Console ([console.firebase.google.com](https://console.firebase.google.com)):

1. **Authentication Provider**:
   - Masuk ke menu **Build** > **Authentication** > tab **Sign-in method**.
   - Aktifkan provider **Email/Password** (Status: *Enabled*).
2. **Firestore Database**:
   - Masuk ke menu **Build** > **Firestore Database**.
   - Pada tab **Rules**, pastikan mode pengujian aktif agar aplikasi dapat menulis dan membaca koleksi `users`:
     ```javascript
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /users/{userId} {
           allow read, write: if request.auth != null;
         }
       }
     }
     ```
   - Klik **Publish**.

---

## 5. Urutan Langkah Pengujian Aplikasi (Sesuai Arahan Dosen)

### Langkah 1: Jalankan Aplikasi
Buka terminal pada direktori proyek atau jalankan lewat VS Code / Android Studio:
```bash
flutter run
```

### Langkah 2: Uji Coba Login Tanpa Registrasi (Harus Ditolak)
1. Pada halaman **LOGIN**, masukkan sembarang email dan password (misal: `test@pml.com` / `123456`).
2. Klik tombol **Sign In**.
3. **Hasil**: Muncul notifikasi merah: *"Email atau Password salah"*.

### Langkah 3: Registrasi Akun Administrator
1. Klik tombol **Register**.
2. Masukkan data:
   - **Email**: `email_kamu_aktif@gmail.com` *(gunakan email asli untuk menerima link verifikasi)*.
   - **Nama Lengkap**: `Zidan Admin`
   - **Alamat**: `Jl. Soekarno Hatta No. 9`
   - **Nomor HP**: `081234567890`
   - **Password**: `password123` (minimal 6 karakter)
   - **Pilih Role**: Pilih radio **Admin**.
3. Klik tombol **Sign Up**.
4. **Hasil**:
   - Muncul notifikasi hijau: *"Akun berhasil dibuat! Email verifikasi telah dikirim."*
   - Layar otomatis kembali ke halaman **LOGIN**.
   - Data langsung tercatat di Firebase Authentication dan Cloud Firestore pada dokumen `users/{uid}` dengan field `role: "admin"`.

### Langkah 4: Uji Coba Login Sebelum Verifikasi Email
1. Kembali ke halaman **LOGIN**, masukkan email dan password yang baru saja didaftarkan.
2. Klik tombol **Sign In**.
3. **Hasil**:
   - Muncul notifikasi merah: *"Email belum diverifikasi"* dan muncul tombol *"Kirim Ulang"*.
   - User **tidak diizinkan** masuk ke dalam dashboard.

### Langkah 5: Buka Email & Lakukan Verifikasi
1. Buka aplikasi Gmail / Webmail Anda.
2. Cari email dari Firebase dengan subjek verifikasi email (pengirim biasanya `noreply@pml03-9da0e.firebaseapp.com`).
3. Klik link tautan verifikasi di email tersebut hingga muncul halaman *"Your email has been verified"*.

### Langkah 6: Login Ulang Sebagai Admin (Berhasil Masuk)
1. Kembali ke aplikasi Flutter dan tekan tombol **Sign In**.
2. **Hasil**:
   - Berhasil masuk ke halaman **DASHBOARD ADMIN**.
   - Banner ungu bertuliskan *"DASHBOARD ADMIN"*.
   - Terdapat kartu informasi profil lengkap: Nama, Email (Verified), Nomor HP, Alamat, dan UID Firebase.

### Langkah 7: Uji Coba Logout
1. Klik tombol **Logout** berwarna merah di bagian bawah dashboard atau ikon di AppBar.
2. Muncul dialog konfirmasi: *"Apakah Anda yakin ingin keluar...?"*.
3. Klik **Logout**.
4. **Hasil**: Sesi Firebase berakhir, navigasi dibersihkan (clear task), dan kembali ke halaman **LOGIN**.

### Langkah 8: Registrasi & Uji Coba Akun Pelanggan
1. Lakukan registrasi akun baru dengan email lain atau email uji coba.
2. Pilih role **Pelanggan**.
3. Verifikasi email melalui tautan yang dikirim.
4. Login menggunakan akun tersebut.
5. **Hasil**:
   - Berhasil masuk ke halaman **DASHBOARD PELANGGAN** (bertema hijau zamrud).
   - Terdapat badge role *"ROLE: PELANGGAN"* dan data profil pelanggan.
   - Logout berfungsi normal kembali ke Sign In.
