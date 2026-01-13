# 🎯 Habit Tracker - Demo Cheat Sheet

## Quick Navigation Guide

### 🏠 Home Page
**Lokasi Fitur:**
- **Heatmap Calendar** → Tap tanggal untuk detail habits
- **Habit List** → Swipe kiri untuk delete
- **➕ Button** → Tambah habit baru
- **📊 Icon (top right)** → Analytics Page
- **🕐 Icon (top right)** → History Page  
- **⚙️ Icon (top right)** → Settings

---

## 📊 Analytics Page - Demo Flow

### 1. Monthly Progress (Candlestick)
**Apa yang ditunjukkan:**
- Bar chart untuk setiap hari dalam bulan
- Warna terang = aktivitas tinggi (di atas rata-rata)
- Warna gelap = aktivitas rendah (di bawah rata-rata)
- **Statistik**: Max, Avg, Min completions per hari

**Demo Script:**
> "Di sini kita bisa lihat monthly progress dalam bentuk candlestick chart. Setiap bar merepresentasikan total habit completions per hari. Misalnya hari ke-15 memiliki 8 completions yang merupakan nilai tertinggi bulan ini."

### 2. Consistency
**Apa yang ditunjukkan:**
- Persentase rata-rata konsistensi
- Progress bar visual
- Dihitung dari: (Hari dengan completion / Total hari) × 100%

**Demo Script:**
> "Consistency score menunjukkan seberapa konsisten kita dalam menjalankan habits. 75% berarti dari 30 hari, kita berhasil complete habits di 22-23 hari. Semakin tinggi persentasenya, semakin baik konsistensi kita."

### 3. Streak
**Apa yang ditunjukkan:**
- Top 5 habits dengan streak terpanjang
- Jumlah hari consecutive
- Warna identitas masing-masing habit

**Demo Script:**
> "Streak menghitung berapa hari berturut-turut kita menjalankan habit. Misalnya 'Morning Exercise' sudah 21 hari berturut-turut tanpa terputus. Ini motivasi untuk terus maintain habit tersebut!"

### 4. Habits Completion Rate
**Apa yang ditunjukkan:**
- List semua habits dengan persentase
- Progress bar berwarna sesuai identitas habit
- Jumlah hari completed vs total hari

**Demo Script:**
> "Di sini kita lihat performance individual setiap habit. 'Reading Books' 90% artinya dari 30 hari, sudah dilakukan 27 hari. Progress bar memudahkan kita membandingkan antar habits."

---

## 🕐 History Page - Demo Flow

**Apa yang ditunjukkan:**
- Chronological log dari hari ke hari
- Separated: Good Habits (✓ hijau) vs Bad Habits (✗ merah)
- Total completions per hari
- Detail habit mana saja yang dilakukan

**Demo Script:**
> "History memberikan log lengkap aktivitas kita. Misal tanggal 13 Januari, terlihat kita complete 5 good habits seperti Exercise dan Reading, dan sayangnya 1 bad habit yaitu Junk Food. Kita bisa scroll ke belakang untuk melihat pattern dan progress kita."

---

## 🗓️ Enhanced Heatmap - Demo Flow

**Cara Demo:**
1. Tap tanggal di heatmap calendar
2. Dialog popup muncul
3. Tampilkan pemisahan Good vs Bad habits
4. Tunjukkan counting (×2, ×3 jika ada)

**Demo Script:**
> "Heatmap ini interactive. Coba tap tanggal 10 Januari... muncul detail lengkap! Kita lihat ada 3 good habits: Exercise, Reading, Meditation. Dan 1 bad habit: Procrastination. Warna yang lebih pekat menunjukkan lebih banyak aktivitas di hari tersebut."

---

## ➕ Add Habit - Demo Flow

**Step-by-step:**
1. Tap tombol ➕
2. Masukkan nama habit (contoh: "Drink Water")
3. Pilih warna identitas (pilih biru)
4. **Pilih kategori**: Good Habit / Bad Habit
5. Toggle timer jika perlu
6. Tap SIMPAN

**Demo Script - Good Habit:**
> "Untuk menambah habit, kita masukkan nama seperti 'Drink Water'. Pilih warna identitas biar mudah dikenali di heatmap. Yang baru, kita bisa pilih apakah ini Good Habit atau Bad Habit. Karena minum air itu baik, pilih Good Habit."

**Demo Script - Bad Habit:**
> "Untuk bad habit, misal 'Smoking', kita tetap track untuk tahu seberapa sering kejadiannya. Pilih Bad Habit category. Nantinya di analytics kita bisa lihat trend-nya menurun atau tidak. Goal-nya adalah mengurangi bad habits."

---

## 🎨 Color Identity System

**Penjelasan:**
- Setiap habit punya warna unik
- Warna konsisten di semua tampilan:
  - Habit card
  - Heatmap (blending dengan intensitas)
  - Analytics charts
  - History logs
  - Detail popups

**Demo Script:**
> "Sistem warna identitas ini bikin mudah recognize habit. Misal Exercise = biru, Reading = hijau, Meditation = ungu. Di heatmap, tanggal yang pekat warnanya berarti banyak habits di-complete. Di analytics dan history, kita langsung tau habit mana based on warna."

---

## 🗄️ Database - Penjelasan untuk Presentasi

### Schema
**2 Tables:**
1. **habits** - Menyimpan definisi habit
2. **completions** - Menyimpan riwayat completion per hari

### Data Flow
```
User Complete Habit 
    ↓
Update completions table
    ↓
Reflected di Heatmap, Analytics, History
```

**Demo Script:**
> "Aplikasi ini menggunakan SQLite database lokal. Ada 2 tabel utama: habits untuk menyimpan data habit seperti nama, warna, kategori. Dan completions untuk track kapan dan berapa kali habit dilakukan. Semua data tersimpan di device, jadi private dan tetap ada offline."

### Example Query
```sql
-- Get all completions for a habit
SELECT * FROM completions 
WHERE habit_id = '123' 
ORDER BY date DESC;

-- Count streak
SELECT COUNT(*) FROM completions 
WHERE habit_id = '123' 
  AND date >= '2026-01-01'
  AND count > 0;
```

---

## 📊 Sample Data untuk Demo

### Create Sample Habits:

**Good Habits:**
1. 🏃 Morning Exercise (Blue) - Untimed
2. 📚 Read Books (Green) - Timed 30 min
3. 🧘 Meditation (Purple) - Timed 15 min
4. 💧 Drink 8 Glasses Water (Teal) - Untimed
5. 🥗 Healthy Eating (Orange) - Untimed

**Bad Habits:**
1. 🚬 Smoking (Red) - Untimed
2. ⏱️ Procrastination (Dark Red) - Untimed
3. 🍔 Junk Food (Orange-Red) - Untimed

### Complete untuk 2-3 minggu dengan pattern:
- Good habits: 70-90% consistency
- Bad habits: 20-40% occurrence (gradually decreasing)
- Beberapa hari complete multiple times (untuk show counting)

---

## 🎤 Key Talking Points

### 1. Problem Statement
> "Orang sering gagal maintain habits karena tidak ada tracking yang proper dan visual feedback yang memotivasi."

### 2. Solution
> "Habit Tracker ini provide visual heatmap untuk instant feedback, detailed analytics untuk insights, dan separation good vs bad habits untuk clarity."

### 3. Key Features
- ✅ Interactive heatmap dengan detail per hari
- ✅ Comprehensive analytics (progress, consistency, streak, percentage)
- ✅ Good vs bad habit categorization
- ✅ Complete history tracking
- ✅ Local database dengan SQLite

### 4. Technical Highlights
- ✅ Flutter (cross-platform)
- ✅ SQLite local database
- ✅ State management dengan Provider
- ✅ Material Design 3
- ✅ Dark mode support

### 5. Future Enhancements
- 🔜 Cloud backup
- 🔜 Reminders/notifications
- 🔜 Export data
- 🔜 Achievement badges
- 🔜 Social features

---

## 💡 Demo Tips

### Do's:
✅ Show interactive features (tap heatmap, swipe to delete)
✅ Navigate smoothly between pages
✅ Point out color consistency
✅ Highlight good vs bad separation
✅ Show real data (not empty state)

### Don'ts:
❌ Don't rush through analytics - explain each metric
❌ Don't ignore the database explanation
❌ Don't forget to mention privacy (local storage)
❌ Don't skip the color identity system

---

## ⏱️ 5-Minute Demo Flow

**0:00-1:00** - Introduction & Home Page
- Show heatmap
- Tap a date to show detail popup
- Explain color intensity

**1:00-2:30** - Analytics Page
- Monthly progress chart
- Consistency percentage
- Streak counter
- Habits completion rate

**2:30-3:30** - History Page
- Scroll through history
- Show good vs bad separation
- Point out counting feature

**3:30-4:30** - Add Habit & Features
- Create a new habit
- Show good/bad category selection
- Complete habit to update heatmap

**4:30-5:00** - Database & Conclusion
- Explain SQLite schema
- Data privacy
- Future enhancements

---

## 🎓 Q&A Preparation

**Q: Kenapa pakai SQLite, bukan cloud?**
> A: Untuk privacy dan offline-first approach. User punya full ownership atas data. Future enhancement bisa tambah optional cloud sync.

**Q: Bagaimana handle bad habits?**
> A: Bad habits di-track untuk awareness. Goal-nya adalah trend menurun di analytics. Separation dari good habits bikin jelas mana yang harus ditingkatkan vs dikurangi.

**Q: Bisa export data?**
> A: Untuk sekarang belum, tapi planned untuk future enhancement. Database schema sudah support export ke JSON/CSV.

**Q: Bagaimana motivasi user untuk consistent?**
> A: Kombinasi visual feedback (heatmap), gamification (streak), dan detailed insights (analytics). Seeing progress = motivation.

---

**Good Luck! 🚀**
