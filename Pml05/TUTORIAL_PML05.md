# Panduan Praktikum PML05 - Firebase Cloud Messaging (FCM)

Panduan ini disusun sesuai dengan modul **Pemrograman Mobile Lanjut Pertemuan 5 - Firebase Cloud Messaging**. Proyek Flutter ini telah mengimplementasikan seluruh alur dan logika dari modul dengan tema visual modern Slate (`#1E293B`) & Indigo (`#4F46E5`).

---

## 1. Komponen & Alur Logika FCM di Flutter

| Komponen di Modul Android | Komponen di Proyek Flutter Ini | Keterangan |
| :--- | :--- | :--- |
| `activity_messaging.xml` | `lib/screens/messaging_screen.dart` | Layout form input dengan tema Slate & Indigo |
| `edToken` | `_tokenController` | Menampilkan Token FCM perangkat + tombol Salin Token |
| `edTitle` | `_titleController` | Menampilkan judul notifikasi (`notification.title` / `data['title']`) |
| `edBody` | `_bodyController` | Menampilkan isi pesan (`notification.body` / `data['body']`) |
| `edPromoId` | `_promoIdController` | Menampilkan parameter data `promoId` (misal: `P6712`) |
| `edPromo` | `_promoController` | Menampilkan parameter data `promo` |
| `edPromoUntil` | `_promoUntilController` | Menampilkan parameter data `promoUntil` |
| `subscribeToTopic("INFO_DISKON_DAN_PROMO")` | `messaging.subscribeToTopic('INFO_DISKON_DAN_PROMO')` | Berlangganan topik notifikasi siaran |
| `onNewToken` & `token.addOnCompleteListener` | `messaging.getToken()` & `onTokenRefresh` | Mengambil dan memperbarui device token |
| `onMessageReceived` (Foreground) | `FirebaseMessaging.onMessage.listen(...)` | Menerima pesan saat aplikasi sedang aktif |
| `MessagingService.kt` (Background) | `_firebaseMessagingBackgroundHandler` | Menangani pesan di background / terminated |

---

## 2. Struktur Proyek Flutter PML05

```
lib/
├── firebase_options.dart              # Konfigurasi platform Firebase untuk com.example.pml05
├── main.dart                          # Inisialisasi Firebase Core, FCM Background Handler, Tema Utama
├── screens/
│   └── messaging_screen.dart          # Form Messaging (Token, Notification, Data Payload, Tombol Salin)
└── widgets/
    ├── custom_text_field.dart         # Form input konsisten bergaya Slate & Indigo
    └── custom_toast.dart              # Floating SnackBar toast notifikasi
```

---

## 3. Langkah Pengujian Aplikasi Sesuai Modul Praktikum

### Langkah 1: Jalankan Aplikasi
Buka terminal di folder proyek dan jalankan:
```bash
flutter run
```
Saat pertama kali dibuka, izinkan notifikasi pada dialog *"Allow Pml05 to send you notifications?"*. Aplikasi akan otomatis:
1. Meminta izin notifikasi.
2. Mengambil Device FCM Token dan menampilkannya di field **Token / Application ID**.
3. Berlangganan ke topik `INFO_DISKON_DAN_PROMO`.

---

### Langkah 2: Uji Coba Mengirim Notifikasi ke Seluruh Subscriber Topik
1. Buka [Firebase Console](https://console.firebase.google.com/) > pilih proyek `mobile-dc1a9`.
2. Pada menu sebelah kiri, pilih **Engage** / **Grow** > **Messaging**.
3. Klik tombol **Create your first campaign** (atau **New campaign**).
4. Pilih opsi **Firebase Notification messages** lalu klik **Create**.
5. **Form Notification**:
   - **Notification title**: `Promo Diskon 50%`
   - **Notification text**: `Nikmati diskon 50% selama promo masih berlaku!`
6. **Form Target**:
   - Pilih tab **Topic**.
   - Masukkan topik: `INFO_DISKON_DAN_PROMO`.
7. **Form Scheduling**:
   - Pilih **Now**.
8. Klik **Review** lalu klik **Publish**.
9. **Hasil**: Aplikasi menerima notifikasi dan otomatis mengisi field **Title** dan **Body**.

---

### Langkah 3: Uji Coba Mengirim Payload Data Tambahan
1. Di Firebase Console, duplikasi campaign sebelumnya atau buat campaign baru dengan topik `INFO_DISKON_DAN_PROMO`.
2. Buka bagian **Additional options (optional)** > **Custom data**.
3. Tambahkan 3 pasangan key-value berikut (sesuai modul):
   - `promoid` atau `promoId` : `P6712`
   - `promo` : `Nikmati diskon 50% selama promo masih berlaku!`
   - `promoUntil` atau `promountil` : `Berlaku hingga 1 minggu kedepan`
4. Klik **Review** lalu **Publish**.
5. **Hasil**: Saat notifikasi diterima, data langsung terisi ke:
   - **Promo Id**: `P6712`
   - **Promo**: `Nikmati diskon 50% selama promo masih berlaku!`
   - **Promo valid until**: `Berlaku hingga 1 minggu kedepan`

---

### Langkah 4: Uji Coba Mengirim Langsung ke Perangkat (Token Test)
1. Di layar aplikasi HP Anda, klik teks **"Salin Token"** di samping label *Token / Application ID*.
2. Di Firebase Console, saat membuat pesan notifikasi, klik tombol **"Send test message"**.
3. Tempelkan (paste) FCM Token perangkat Anda ke kolom *Add a Firebase Installation ID or FCM registration token*.
4. Klik tanda tambah `(+)` lalu klik tombol **Test**.
5. Pesan notifikasi akan langsung terkirim secara instan hanya ke ponsel Anda!

---

### Fitur Tambahan (Simulasi Cepat)
Jika sedang tidak terhubung ke Firebase Console atau ingin menunjukkan demo cepat di hadapan dosen/asisten:
- Klik tombol **"Simulasi Data"** di bagian bawah aplikasi untuk langsung mengisi contoh data promo lengkap.
- Klik tombol **"Clear"** untuk mengosongkan kembali seluruh field.
