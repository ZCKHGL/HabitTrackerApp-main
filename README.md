# 📱 Habit Tracker App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)

**Aplikasi pelacak kebiasaan yang minimalis dan cantik untuk membantu Anda membangun kebiasaan baik dan menghentikan kebiasaan buruk**

[Fitur](#-fitur) • [Instalasi](#-instalasi) • [Panduan Penggunaan](#-panduan-penggunaan) • [Teknologi](#-teknologi)

</div>

---

## 📖 Tentang Proyek

**Habit Tracker App** adalah aplikasi Flutter yang dirancang untuk membantu pengguna melacak dan mengelola kebiasaan sehari-hari mereka. Aplikasi ini mendukung pelacakan kebiasaan baik (good habits) dan kebiasaan buruk (bad habits) dengan visualisasi heatmap kalender, analitik lengkap, dan timer untuk kebiasaan berbasis waktu.

### ✨ Mengapa Menggunakan Habit Tracker?

- 🎯 **Fokus pada Tujuan**: Lacak kemajuan harian Anda menuju kebiasaan yang lebih baik
- 📊 **Visualisasi Data**: Lihat pola kebiasaan Anda melalui heatmap dan grafik
- 🔒 **Privasi Terjamin**: Semua data tersimpan lokal di perangkat Anda
- 🌐 **Multi-bahasa**: Mendukung Bahasa Indonesia, Inggris, dan Arab
- 🌓 **Mode Gelap**: Nyaman digunakan kapan saja

---

## 🚀 Fitur

### Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| ✅ **Pelacakan Kebiasaan** | Buat kebiasaan baik dan buruk tanpa batas |
| ⏱️ **Timer Kebiasaan** | Dukungan untuk kebiasaan berbasis waktu dengan timer countdown |
| 🎨 **Identitas Warna** | Warna otomatis berdasarkan kategori (biru untuk baik, merah untuk buruk) |
| 📅 **Heatmap Kalender** | Visualisasi penyelesaian kebiasaan dalam format kalender |
| 📊 **Dashboard Analitik** | Statistik dan insight komprehensif |
| 📜 **Riwayat Lengkap** | Kronologi lengkap semua penyelesaian kebiasaan |
| 🌓 **Mode Gelap/Terang** | Tema yang indah untuk mode gelap dan terang |
| 🔐 **Sistem Login** | Autentikasi pengguna dengan penyimpanan lokal |

### Fitur Analitik

1. **📈 Progress Bulanan (Candlestick Chart)**
   - Statistik penyelesaian harian
   - Metrik maksimum, minimum, dan rata-rata
   - Representasi visual dalam bentuk bar chart

2. **📊 Persentase Konsistensi**
   - Skor konsistensi keseluruhan
   - Perbandingan hari selesai vs total hari
   - Visualisasi progress

3. **🔥 Penghitung Streak**
   - Pelacakan hari berturut-turut
   - Top 5 streak terpanjang
   - Pembaruan streak real-time

4. **📋 Tingkat Penyelesaian Kebiasaan**
   - Performa per kebiasaan
   - Progress bar berbasis persentase
   - Perbandingan penyelesaian vs target

### Fitur Heatmap Interaktif

- **🗓️ Kalender Interaktif**: Ketuk tanggal mana saja untuk melihat detail
- **✅❌ Good vs Bad Habits**: Pemisahan visual dengan ikon
- **🎨 Kode Warna**: Pewarnaan berbasis intensitas (skala 0-5+)
- **⬅️➡️ Navigasi Bulanan**: Perpindahan bulan dengan mudah

### Fitur Riwayat

- **📆 Tampilan Kronologis**: Entri terbaru ditampilkan pertama
- **📂 Display Terkategori**: Kebiasaan baik dan buruk dipisahkan
- **📊 Ringkasan Harian**: Total penyelesaian per hari
- **📝 Informasi Detail**: Kebiasaan mana yang diselesaikan dan berapa kali

---

## 🗄️ Struktur Database

Aplikasi menggunakan **SQLite** untuk penyimpanan data lokal dengan struktur berikut:

### Tabel `habits`

| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `id` | TEXT | Primary key |
| `name` | TEXT | Nama kebiasaan |
| `color` | INTEGER | Nilai warna ARGB |
| `type` | INTEGER | 0=tanpa timer, 1=dengan timer |
| `targetSeconds` | INTEGER | Durasi target (untuk kebiasaan dengan timer) |
| `category` | INTEGER | 0=kebiasaan baik, 1=kebiasaan buruk |

### Tabel `completions`

| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `habit_id` | TEXT | Foreign key ke habits |
| `date` | TEXT | String tanggal ISO8601 |
| `count` | INTEGER | Berapa kali diselesaikan pada tanggal ini |

### Tabel `users`

| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `id` | TEXT | Primary key |
| `username` | TEXT | Nama pengguna |
| `password_hash` | TEXT | Hash password terenkripsi |

---

## 💻 Instalasi

### Prasyarat

- Flutter SDK (>=3.3.0 <4.0.0)
- Dart SDK
- Android Studio / VS Code
- Emulator Android/iOS atau perangkat fisik

### Langkah Instalasi

1. **Clone repository**
   ```bash
   git clone https://github.com/username/HabitTrackerApp.git
   cd HabitTrackerApp
   ```

2. **Install dependensi**
   ```bash
   flutter pub get
   ```

3. **Generate lokalisasi**
   ```bash
   flutter gen-l10n
   ```

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

### Build untuk Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

---

## 📖 Panduan Penggunaan

### 🔐 Login/Registrasi

1. Buka aplikasi
2. Masukkan username dan password
3. Klik **MASUK** untuk login atau **DAFTAR** untuk membuat akun baru

### ➕ Membuat Kebiasaan Baru

1. Ketuk tombol **+ Tambah** di layar utama
2. Masukkan nama kebiasaan
3. Pilih kategori (**Kebiasaan Baik** atau **Kebiasaan Buruk**)
4. Aktifkan timer jika diperlukan dan atur durasi
5. Ketuk **SIMPAN**

### ✅ Menyelesaikan Kebiasaan

- **Tanpa Timer**: Ketuk ikon lingkaran atau centang
- **Dengan Timer**: Mulai timer, biarkan berjalan sampai selesai

### 📊 Melihat Analitik

1. Ketuk ikon **grafik batang** di app bar
2. Navigasi antar bulan untuk melihat data historis
3. Lihat berbagai metrik (progress, konsistensi, streak, tingkat penyelesaian)

### 📜 Memeriksa Riwayat

1. Ketuk ikon **riwayat** di app bar
2. Scroll melalui entri kronologis
3. Lihat kebiasaan mana yang diselesaikan setiap hari

### 🗓️ Menggunakan Heatmap Interaktif

1. Ketuk tanggal mana saja pada kalender heatmap
2. Lihat popup yang menampilkan semua kebiasaan yang diselesaikan pada tanggal tersebut
3. Lihat kategorisasi (kebiasaan baik vs buruk)

### ⚙️ Pengaturan Aplikasi

- **🌓 Mode Tema**: Pilih antara tema terang, gelap, atau ikuti sistem
- **🌐 Bahasa**: Pilih Bahasa Indonesia, Inggris, atau Arab
- **🚪 Logout**: Keluar dari akun

---

## 🛠️ Teknologi

### Arsitektur

- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **UI Framework**: Material Design 3
- **Lokalisasi**: Flutter Intl (ARB files)
- **Keamanan**: Crypto untuk hash password

### Dukungan Platform

| Platform | Status |
|----------|--------|
| Android | ✅ Didukung penuh |
| iOS | ✅ Didukung penuh |
| Windows | ✅ Didukung penuh |
| macOS | ✅ Didukung penuh |
| Linux | ✅ Didukung penuh |
| Web | ⚠️ Dengan fallback in-memory storage |

### Dependensi Utama

| Package | Versi | Kegunaan |
|---------|-------|----------|
| `provider` | ^6.1.2 | State management |
| `sqflite` | ^2.3.3 | Database lokal SQLite |
| `shared_preferences` | ^2.2.2 | Penyimpanan preferensi |
| `crypto` | ^3.0.3 | Enkripsi password |
| `flutter_localizations` | SDK | Dukungan multi-bahasa |

### Struktur Proyek

```
lib/
├── data/
│   └── habits_db.dart          # Operasi database
├── l10n/
│   ├── app_id.arb              # Bahasa Indonesia
│   ├── app_en.arb              # Bahasa Inggris
│   └── app_ar.arb              # Bahasa Arab
├── models/
│   └── habit.dart              # Model & enum kebiasaan
├── pages/
│   ├── home_page.dart          # Layar utama
│   ├── add_habit_page.dart     # Tambah kebiasaan
│   ├── analytics_page.dart     # Dashboard analitik
│   ├── history_page.dart       # Tampilan riwayat
│   └── login_page.dart         # Halaman login
├── state/
│   ├── habits_state.dart       # State kebiasaan
│   ├── auth_state.dart         # State autentikasi
│   └── app_settings.dart       # Pengaturan aplikasi
├── widgets/
│   ├── habit_card.dart         # Widget item kebiasaan
│   ├── heatmap_calendar.dart   # Heatmap kalender
│   └── wheel_timer_picker.dart # Picker waktu
├── theme.dart                  # Tema aplikasi
└── main.dart                   # Entry point
```

---

## 🔒 Privasi Data

- ✅ Semua data tersimpan lokal di perangkat
- ✅ Tidak ada sinkronisasi cloud
- ✅ Tidak ada analytics atau tracking eksternal
- ✅ Kepemilikan data sepenuhnya oleh pengguna
- ✅ Bekerja offline

---

## 🎯 Pengembangan Masa Depan

- [ ] Backup cloud (Firebase/Supabase)
- [ ] Reminder/notifikasi kebiasaan
- [ ] Export data (JSON/CSV)
- [ ] Badge pencapaian
- [ ] Catatan/refleksi kebiasaan
- [ ] Laporan mingguan/bulanan
- [ ] Penetapan goal
- [ ] Fitur sosial

---

## 🧪 Menjalankan Test

```bash
# Unit tests
flutter test

# Dengan coverage
flutter test --coverage
```

---

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan:

1. Fork repository ini
2. Buat branch fitur (`git checkout -b fitur/FiturBaru`)
3. Commit perubahan (`git commit -m 'Menambahkan fitur baru'`)
4. Push ke branch (`git push origin fitur/FiturBaru`)
5. Buka Pull Request

---

## 📄 Lisensi

Proyek ini bersifat open source dan tersedia di bawah [Lisensi MIT](LICENSE).

---

## 📞 Dukungan

Untuk pertanyaan atau masalah, silakan buka issue di repository ini.

---

<div align="center">

**Dibuat dengan ❤️ menggunakan Flutter**

⭐ Jangan lupa beri bintang jika proyek ini membantu Anda! ⭐

</div>
