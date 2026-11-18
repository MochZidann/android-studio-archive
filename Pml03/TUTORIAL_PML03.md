# Tutorial & Dokumentasi Lengkap: PML03 - Firebase Realtime Database (Single Screen)

Aplikasi **Pml03** ini didesain dalam **1 layar tunggal (Single Screen)** dengan gaya dan tema modern Slate & Indigo yang identik dengan PML02, tanpa perlu membuka halaman baru atau popup saat menambah/mengedit data, dan tanpa tombol tambah di bawah.

---

## 1. Persiapan Firebase Console

1. Buka [Firebase Console](https://console.firebase.google.com/) > project **`pml03-9da0e`**.
2. Masuk ke **Build** > **Realtime Database**.
3. Di tab **Rules**, set aturan pembacaan dan penulisan menjadi publik (test mode):
   ```json
   {
     "rules": {
       ".read": true,
       ".write": true
     }
   }
   ```
4. Klik **Publish**.

---

## 2. Struktur Data di Firebase Realtime Database

Data disimpan pada node **`Notes`**:
```json
{
  "Notes": {
    "-P0f06FaWxHCZzVXpfpA": {
      "title": "PML Pertemuan 03",
      "description": "Praktik realtime database"
    }
  }
}
```

---

## 3. Fitur dan Desain Aplikasi (Single Screen)

### A. Panel Atas (AppBar)
- **Judul**: `Pml03`
- **Subjudul**: `Pemrograman Mobile Lanjut 3`
- **Tombol Reset Form**: Muncul secara otomatis di pojok kanan atas saat item sedang dipilih (Mode Edit) untuk membatalkan pilihan.

### B. Panel Form Input (`NOTES DATA`)
- **Field `title`**: Input untuk nama/judul catatan (disertai icon judul dan validasi).
- **Field `description`**: Input untuk deskripsi catatan.
- **Tombol Aksi**:
  1. **`+ INSERT`** (Indigo `#4F46E5`): Menambahkan catatan baru ke Firebase Realtime Database (`push()`).
  2. **`UPDATE`** (Sky Blue `#0284C7`): Memperbarui catatan yang sedang dipilih (`update()`). Aktif otomatis saat item dipilih.
  3. **`DELETE`** (Red `#DC2626`): Menghapus catatan yang dipilih dari Firebase dengan konfirmasi dialog (`remove()`).

### C. Daftar Catatan Realtime (`DAFTAR CATATAN`)
- Menggunakan `StreamBuilder` ke node `Notes` di Firebase Realtime Database.
- Setiap kartu menampilkan:
  - **Avatar Gradien**: Menampilkan inisial huruf judul catatan dengan gradien warna lembut.
  - **Badge Nomor**: Menampilkan nomor urut item.
  - **Judul & Deskripsi**: Teks dengan tipografi rapi dan kontras.
  - **Indikator Seleksi**: Saat kartu diketuk, kartu berubah warna menjadi soft indigo (`#EEF2FF`) dengan border aktif (`#6366F1`), dan form di atas otomatis terisi data catatan tersebut ("Mode Edit").

---

## 4. Cara Pengujian & Demo Tugas

1. Jalankan aplikasi:
   ```bash
   flutter run
   ```
2. **Tambah Data (INSERT)**:
   - Masukkan `title`: `PML Pertemuan 03`
   - Masukkan `description`: `Praktik realtime database`
   - Klik tombol **`+ INSERT`**. Catatan baru langsung muncul di daftar secara seketika!
3. **Ubah Data (UPDATE)**:
   - Ketuk salah satu kartu catatan di daftar.
   - Perhatikan form di atas otomatis terisi data catatan tersebut dan tombol **`UPDATE`** serta **`DELETE`** menjadi aktif.
   - Ubah judul atau deskripsi, lalu klik tombol **`UPDATE`**.
4. **Hapus Data (DELETE)**:
   - Ketuk kartu yang ingin dihapus.
   - Klik tombol **`DELETE`** di panel tombol.
   - Dialog konfirmasi *"Delete? Yakin ingin menghapus catatan...?"* akan muncul.
   - Pilih **Yes**. Data akan terhapus dari Firebase dan hilang dari daftar.
5. **Reset Form**:
   - Jika ingin membatalkan pilihan mode edit, ketuk tombol **Reset Form** di AppBar atau ketuk kartu yang sama sekali lagi.
