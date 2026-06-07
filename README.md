# Clockin — Mobile App (Flutter)

Aplikasi absensi karyawan berbasis Flutter dengan fitur clock-in/clock-out, pengajuan izin, lembur, reimburse, dan manajemen profil.

---

## Teknologi

| Komponen | Teknologi |
|---|---|
| Framework | Flutter (Dart) |
| State Management | GetX / Controller pattern |
| Navigasi | Named routes (`route_app.dart`) |
| Tema | Custom theme (`app_theme.dart`) |
| Backend | PHP Native REST API |
| Database | MySQL (via API) |

---

## Diagram Sistem

### Activity Diagram
![Activity Diagram](docs/clockin_activity_diagram.pdf)

### Use Case Diagram
![Use Case Diagram](docs/clockin_usecase_diagram.pdf)

### Class Diagram
![Class Diagram](docs/clockin_class_diagram.pdf)


## Struktur Proyek

```
lib/
├── core/
│   ├── routes/route_app.dart       # Konfigurasi semua named routes
│   └── themes/app_theme.dart       # Theme, warna, dan typography global
│
├── utils/
│   └── logger.dart                 # Helper logging debug
│
├── services/
│   └── offline_service.dart        # helper offline
│
├── model/                          # Data model (parsing JSON dari API)
│   ├── model_clockin.dart
│   ├── model_clockout.dart
│   ├── model_dashboard.dart
│   ├── model_jabatan.dart
│   ├── model_kuota_cuti.dart
│   ├── model_login.dart
│   ├── model_profile.dart
│   └── model_visit.dart
│
└── View/                               # daftar halaman
│   ├── pages/
│   │   ├── splash/                     # Splash screen & cek session
│   │   │   └── splash_screen.dart
│   │   ├── login/                      # Halaman login + controller
│   │   │   ├── controller_login.dart   
│   │   │   └── login_page.dart         
│   │   ├── shift/                      # Halaman shift + controller
│   │   │   ├── controller_shift.dart   
│   │   │   └── shift_page.dart         
│   │   ├── dashboard/                  # Dashboard utama + menu izin & lembur
│   │   │   ├── menu_item/   
│   │   │   │   ├── form_menu_item/   
│   │   │   │   │   └── form_menu_item/   
│   │   │   │   │      ├── controller_form_izin.dart   
│   │   │   │   │      ├── controller_form_lembur.dart   
│   │   │   │   │      ├── izin_form_page.dart   
│   │   │   │   │      └── lembur_form_page.dart   
│   │   │   │   ├── izin_page.dart   
│   │   │   │   ├── lembur_page.dart   
│   │   │   │   ├── controller_izin.dart   
│   │   │   │   └── controller_lembur.dart   
│   │   │   ├── controller_dashboard.dart   
│   │   │   └── dashboard_page.dart         
│   │   ├── absensi/                    # Halaman absensi + clock-in
│   │   │   ├── clockin/
│   │   │   │   ├── clockin_page.dart
│   │   │   │   └── controller_clockin.dart
│   │   │   ├── absensi_page.dart
│   │   │   └── controller_absensi.dart
│   │   └── profile/                    # Profil karyawan
│   │       ├── profile_page.dart
│   │       └── controller_profile.dart                    
│   └── components/
│      └── custom_bottom_nav.dart      # Bottom navigation bar custom
│
└── main.dart
---

## Persyaratan

- Flutter SDK `>= 3.0.0`
- Dart `>= 3.0.0`
- Android SDK `>= 21` (Android 5.0+)
- Koneksi ke server API (lokal / hosting)

---

## Instalasi & Menjalankan

```bash
# 1. Clone repository
git clone https://github.com/10-Abel-01/Clockin.git
cd clockin

# 2. Install dependencies
flutter pub get

# 3. Konfigurasi base URL API/.env
# Edit file konfigurasi API (sesuaikan dengan IP server)
# Contoh: http://192.168.1.x/clockin/clockin-api/public/

# 4. Jalankan di emulator / device
flutter run

# 5. Build APK release
flutter build apk --release
```

---

## Alur Aplikasi

```
Splash Screen
    │
    ├── Session ada → Dashboard
    └── Session tidak ada → Login
            │
            └── Login berhasil → Dashboard
                    │
                    ├── Absensi (Clock In / Clock Out)
                    ├── Izin (List + Form pengajuan)
                    ├── Lembur (List + Form pengajuan)
                    └── Profil
```

---

## Fitur

| Fitur | Deskripsi |
|---|---|
| Login | Autentikasi karyawan dengan ID & password |
| Dashboard | Ringkasan data absensi, izin, dan kuota cuti |
| Clock In | Absensi masuk dengan foto & GPS koordinat |
| Clock Out | Absensi keluar, update jam pulang |
| Visit | Absensi luar kantor dengan koordinat kunjungan |
| Izin | Pengajuan cuti tahunan / sakit + upload dokumen |
| Lembur | Pengajuan lembur + upload lampiran |
| Profil | Lihat data profil karyawan |

---

## Koneksi API

Base URL dikonfigurasi di file konfigurasi. Semua endpoint menggunakan metode `POST` dengan body `multipart/form-data` untuk request yang menyertakan file.

| Endpoint | Fungsi |
|---|---|
| `api-login.php` | Login karyawan |
| `api-absensi.php` | Clock in |
| `api-absensi-keluar.php` | Clock out |
| `api-visit.php` | Absensi visit |
| `api-izin.php` | Pengajuan izin |
| `api-lembur.php` | Pengajuan lembur |
| `api-profile.php` | Data profil |
| `api-kuota-cuti.php` | Sisa kuota cuti |
| `api-history-absen.php` | Riwayat absensi |
| `api-logout.php` | Logout & hapus session |

---

## Black Box Testing

### Cara Kerja
Black box testing menguji fungsionalitas aplikasi dari sisi pengguna tanpa melihat kode internal. Fokus pada **input → proses → output**.

### Format Tabel Test Case

| ID | Modul | Skenario | Input | Expected Output | Actual Output | Status |
|---|---|---|---|---|---|---|
| TC-001 | Login | Login valid | ID & password benar | Masuk ke dashboard | - | - |
| TC-002 | Login | Login invalid | Password salah | Pesan error muncul | - | - |
| TC-003 | Login | Field kosong | ID kosong | Validasi field | - | - |
| TC-004 | Clock In | Absensi normal | Foto + koordinat valid | Absensi tercatat | - | - |
| TC-005 | Clock In | Tanpa izin kamera | Permission ditolak | Pesan permintaan izin | - | - |
| TC-006 | Clock In | GPS mati | Koordinat null | Pesan aktifkan GPS | - | - |
| TC-007 | Clock In | Absen ganda | Sudah absen hari ini | Pesan sudah absen | - | - |
| TC-008 | Clock Out | Belum clock in | Tap clock out | Pesan belum clock in | - | - |
| TC-009 | Izin | Pengajuan valid | Semua field terisi | Izin pending | - | - |
| TC-010 | Izin | Field kosong | Deskripsi kosong | Validasi field | - | - |
| TC-011 | Izin | Kuota habis | Kuota cuti = 0 | Pesan kuota habis | - | - |
| TC-012 | Lembur | Pengajuan valid | Semua field terisi | Lembur tercatat | - | - |
| TC-013 | Profil | Lihat profil | Buka halaman profil | Data profil tampil | - | - |
| TC-014 | Logout | Logout normal | Tap logout | Kembali ke login | - | - |
| TC-015 | Session | Token expired | Buka app setelah lama | Redirect ke login | - | - |

---

## Catatan Pengembangan

- Pastikan permission `CAMERA` dan `ACCESS_FINE_LOCATION` sudah dideklarasikan di `AndroidManifest.xml`
- File foto disimpan di server pada folder `storage/absensi/` dan `storage/visit/`
- Autentikasi menggunakan token yang disimpan di local storage

---

## Kontributor

| Nama | Role |
|---|---|
| Abel Saferyan | Kuli pemrograman (Mobile + Admin + API) |
| Hamad Syahid | Technical Writer |
| Hidayat Chandra | Software Tester / QA |
| Muhammad Riski Kurniawan | UI/UX Design |
| Raihan Lundy Arista| Database Administrator (Database Management + Database Visual Modeling) |