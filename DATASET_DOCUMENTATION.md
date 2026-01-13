# Habit Tracker App - Dataset & Database Documentation

## Overview
Habit Tracker adalah aplikasi mobile untuk membantu pengguna melacak kebiasaan baik dan buruk mereka dengan visualisasi heatmap dan analytics.

---

## Database Architecture

### Technology Stack
- **Database**: SQLite (via sqflite package)
- **Storage**: Local device storage
- **Fallback**: In-memory storage untuk web platform

### Database Location
Database disimpan di lokasi yang berbeda tergantung platform:
- **Android**: `/data/data/<package>/databases/habits.db`
- **iOS**: `Library/Application Support/habits.db`
- **Windows**: `%APPDATA%/<package>/databases/habits.db`
- **macOS**: `~/Library/Application Support/<package>/databases/habits.db`
- **Linux**: `~/.local/share/<package>/databases/habits.db`

---

## Database Schema

### Table: `habits`
Menyimpan informasi tentang setiap habit yang dibuat user.

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT | Primary key, unique identifier untuk habit |
| `name` | TEXT | Nama habit (e.g., "Olahraga", "Merokok") |
| `color` | INTEGER | Warna identitas habit dalam format ARGB |
| `type` | INTEGER | Tipe habit: 0 = untimed, 1 = timed (dengan timer) |
| `targetSeconds` | INTEGER | Target durasi untuk timed habits (dalam detik) |
| `category` | INTEGER | Kategori: 0 = good habit, 1 = bad habit |

**Example Data:**
```sql
INSERT INTO habits VALUES (
  '1705200000000',
  'Morning Exercise',
  0xFF42A5F5,
  0,
  0,
  0
);

INSERT INTO habits VALUES (
  '1705200000001',
  'Read Books',
  0xFF26A69A,
  1,
  1800,
  0
);
```

### Table: `completions`
Menyimpan riwayat completion/pelaksanaan habit per hari.

| Column | Type | Description |
|--------|------|-------------|
| `habit_id` | TEXT | Foreign key ke habits.id |
| `date` | TEXT | Tanggal dalam format ISO8601 (YYYY-MM-DD) |
| `count` | INTEGER | Jumlah kali habit dilakukan pada tanggal tersebut |

**Primary Key**: (`habit_id`, `date`)
**Foreign Key**: `habit_id` REFERENCES `habits(id)` ON DELETE CASCADE

**Example Data:**
```sql
INSERT INTO completions VALUES ('1705200000000', '2026-01-13T00:00:00.000', 1);
INSERT INTO completions VALUES ('1705200000000', '2026-01-14T00:00:00.000', 2);
INSERT INTO completions VALUES ('1705200000001', '2026-01-13T00:00:00.000', 1);
```

---

## Data Flow

### 1. Create Habit
```
User Input → AddHabitPage → HabitsState → HabitsDb.insertHabit() → SQLite
```

### 2. Complete Habit
```
User Tap → HabitCard → HabitsState.toggleDoneToday() → Update completions map → HabitsDb.updateCompletion() → SQLite
```

### 3. View Analytics
```
AnalyticsPage → HabitsState.habits → Calculate statistics from completions → Display charts
```

### 4. View History
```
HistoryPage → Iterate all habits.completions → Group by date → Display chronologically
```

---

## Data Models

### Habit Class
```dart
class Habit {
  String id;              // Unique identifier
  String name;            // Habit name
  Color color;            // Identity color
  HabitType type;         // timed / untimed
  HabitCategory category; // good / bad
  Duration target;        // Target duration (for timed)
  Map<String, int> completions; // date -> count
}
```

### Enums
```dart
enum HabitType { timed, untimed }
enum HabitCategory { good, bad }
enum TimerStatus { stopped, running, paused }
```

---

## Features & Data Usage

### 1. **Heatmap Calendar**
- **Data Source**: `completions` table
- **Visualization**: Aggregates all habit completions per day
- **Color Intensity**: Based on total count (0-5+ scale)
- **Interactivity**: Tap on date to see which habits were completed

### 2. **Analytics - Monthly Progress**
- **Data Source**: `completions` table filtered by month
- **Calculation**: Daily totals → Candlestick chart
- **Statistics**: Max, Min, Average completions per day

### 3. **Analytics - Consistency**
- **Data Source**: `completions` table
- **Calculation**: (Days with completions / Total days) × 100%
- **Display**: Percentage + progress bar

### 4. **Analytics - Streak**
- **Data Source**: `completions` table
- **Calculation**: Count consecutive days with completions from today backwards
- **Display**: Top 5 habits with longest streaks

### 5. **Analytics - Habits Percentage**
- **Data Source**: `completions` table per habit
- **Calculation**: Individual habit completion rate
- **Display**: List with progress bars and percentages

### 6. **History**
- **Data Source**: All `completions` entries
- **Organization**: Grouped by date, sorted descending
- **Categories**: Separated into Good Habits and Bad Habits

---

## Data Persistence

### Save Operations
1. **Auto-save**: Every completion/timer action automatically saves to database
2. **Transaction**: Database operations wrapped in transactions for data integrity
3. **Foreign Keys**: Enabled untuk maintain referential integrity

### Load Operations
1. **App Start**: Load all habits and their completions
2. **In-Memory**: Cache in `HabitsState` for fast access
3. **Sync**: Changes immediately persisted to database

---

## Dataset Statistics (Example)

Untuk presentasi, berikut contoh data yang bisa digunakan:

### Sample Dataset
- **Total Habits**: 10 habits
  - 7 Good Habits (Exercise, Reading, Meditation, etc.)
  - 3 Bad Habits (Smoking, Procrastination, Junk Food)
- **Time Period**: 30 days (1 month)
- **Total Completions**: 180 entries
- **Average Consistency**: 75%
- **Longest Streak**: 21 days

### Data Insights
1. **Most Consistent Habit**: Morning Exercise (95% consistency)
2. **Least Consistent Habit**: Meditation (45% consistency)
3. **Best Week**: Week 2 (28 total completions)
4. **Category Performance**: 
   - Good Habits: 80% average completion
   - Bad Habits: 30% average occurrence (lower is better)

---

## Privacy & Security

### Local Storage
- ✅ Data tersimpan **lokal** di device user
- ✅ Tidak ada cloud sync / server eksternal
- ✅ Data tetap private dan tidak dibagikan
- ✅ Hanya aplikasi yang dapat mengakses database

### Data Migration
- Database version tracking (currently v2)
- Automatic migration untuk backward compatibility
- Column additions handled via `onUpgrade`

---

## Technical Implementation

### Database Operations
```dart
// Create habit
await db.insert('habits', habit.toMap());

// Add completion
await db.insert('completions', {
  'habit_id': habitId,
  'date': dateKey,
  'count': count,
});

// Query completions
final rows = await db.query('completions', 
  where: 'habit_id = ?',
  whereArgs: [habitId]
);

// Delete habit (cascade deletes completions)
await db.delete('habits', 
  where: 'id = ?',
  whereArgs: [habitId]
);
```

### Data Aggregation
```dart
// Aggregate all completions by date
Map<DateTime, int> aggregatedCompletions() {
  final result = <DateTime, int>{};
  for (final habit in habits) {
    for (final entry in habit.completions.entries) {
      final date = DateTime.parse(entry.key);
      result[date] = (result[date] ?? 0) + entry.value;
    }
  }
  return result;
}
```

---

## Future Enhancements

### Potential Database Extensions
1. **Notes Table**: Store notes/reflections per completion
2. **Goals Table**: Track monthly/yearly goals
3. **Reminders Table**: Scheduled notifications
4. **Backup/Export**: Export data to JSON/CSV
5. **Cloud Sync**: Optional Firebase/Supabase integration

### Analytics Enhancements
1. **Year-in-Review**: Annual statistics
2. **Comparative Analysis**: Compare habits against each other
3. **Predictive Analytics**: Forecast future consistency
4. **Achievement System**: Badges for milestones

---

## Conclusion

Habit Tracker menggunakan SQLite sebagai database lokal yang efisien untuk menyimpan:
- ✅ Habit definitions (name, color, type, category)
- ✅ Daily completion records
- ✅ Historical data untuk analytics

Database dirancang dengan:
- ✅ Normalized schema (2 tables dengan foreign key)
- ✅ Efficient querying (indexed primary keys)
- ✅ Data integrity (foreign key constraints)
- ✅ Migration support (version tracking)

Semua fitur analytics, heatmap, dan history bekerja dengan mengolah data dari kedua tabel ini untuk memberikan insights yang berguna kepada user.
