# Code Changes Summary

## Quick Reference untuk Developer

### 🔧 Modified Files

#### 1. `lib/models/habit.dart`
**Changes:**
```dart
// Added enum
enum HabitCategory { good, bad }

// Added field to Habit class
HabitCategory category;

// Updated constructor
Habit({
  ...
  this.category = HabitCategory.good,
  ...
})

// Updated toMap()
'category': category == HabitCategory.good ? 0 : 1,

// Updated fromMap()
category: ((map['category'] as int?) ?? 0) == 0 
  ? HabitCategory.good 
  : HabitCategory.bad,
```

#### 2. `lib/data/habits_db.dart`
**Changes:**
```dart
// Database version bump
version: 2,  // was 1

// onCreate - added column
category INTEGER NOT NULL DEFAULT 0

// Added onUpgrade
onUpgrade: (db, oldVersion, newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE habits ADD COLUMN category INTEGER NOT NULL DEFAULT 0');
  }
},
```

#### 3. `lib/pages/home_page.dart`
**Changes:**
```dart
// Added imports
import 'analytics_page.dart';
import 'history_page.dart';

// Added navigation buttons in AppBar
IconButton(
  onPressed: () => Navigator.push(...AnalyticsPage()),
  icon: const Icon(Icons.bar_chart_rounded),
),
IconButton(
  onPressed: () => Navigator.push(...HistoryPage()),
  icon: const Icon(Icons.history_rounded),
),

// Updated HeatmapCalendar
HeatmapCalendar(
  ...
  habits: hs.habits,  // NEW
)
```

#### 4. `lib/pages/add_habit_page.dart`
**Changes:**
```dart
// Added state variable
HabitCategory _category = HabitCategory.good;

// Updated _save()
final habit = Habit(
  ...
  category: _category,  // NEW
);

// Added UI (before SwitchListTile)
SegmentedButton<HabitCategory>(
  segments: const [
    ButtonSegment(value: HabitCategory.good, ...),
    ButtonSegment(value: HabitCategory.bad, ...),
  ],
  selected: {_category},
  onSelectionChanged: (newSelection) {
    setState(() => _category = newSelection.first);
  },
),
```

#### 5. `lib/widgets/habit_card.dart`
**Changes:**
```dart
// Added category badge in Row with habit name
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  decoration: BoxDecoration(
    color: habit.category == HabitCategory.good
        ? Colors.green.withOpacity(0.15)
        : Colors.red.withOpacity(0.15),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    children: [
      Icon(
        habit.category == HabitCategory.good
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded,
        size: 12,
        color: habit.category == HabitCategory.good
            ? Colors.green
            : Colors.red,
      ),
      const SizedBox(width: 4),
      Text(
        habit.category == HabitCategory.good ? 'Good' : 'Bad',
        style: TextStyle(
          color: habit.category == HabitCategory.good
              ? Colors.green
              : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),
```

#### 6. `lib/widgets/heatmap_calendar.dart`
**Changes:**
```dart
// Added parameters
final List<Habit>? habits;
final Function(DateTime)? onDateTap;

// Wrapped cell in GestureDetector
GestureDetector(
  onTap: () {
    if (onDateTap != null) {
      onDateTap!(date);
    } else if (habits != null && count > 0) {
      _showDateDetails(context, date, habits!);
    }
  },
  child: Container(...),
)

// Added method
void _showDateDetails(BuildContext context, DateTime date, List<Habit> habits) {
  // Show dialog with good/bad habits separation
}
```

---

### ➕ New Files

#### 1. `lib/pages/analytics_page.dart`
**Purpose:** Analytics dashboard dengan 4 cards:
- `_MonthlyProgressCard` - Candlestick chart
- `_ConsistencyCard` - Percentage + progress bar
- `_StreakCard` - Top 5 streaks
- `_HabitsPercentageCard` - Per-habit completion rate

**Key Classes:**
```dart
class AnalyticsPage extends StatefulWidget
class _MonthlyProgressCard extends StatelessWidget
class _ConsistencyCard extends StatelessWidget
class _StreakCard extends StatelessWidget
class _HabitsPercentageCard extends StatelessWidget
class _StatItem extends StatelessWidget
```

#### 2. `lib/pages/history_page.dart`
**Purpose:** Chronological history view

**Key Classes:**
```dart
class HistoryPage extends StatelessWidget
class _HistoryDateCard extends StatelessWidget
class _HabitEntry extends StatelessWidget
```

**Features:**
- Group by date
- Separate good/bad habits
- Format dates (Today, Yesterday, etc.)
- Show completion counts

---

### 📊 Key Algorithms

#### Streak Calculation
```dart
int _calculateStreak(Habit habit) {
  final today = DateTime.now();
  int streak = 0;
  
  for (int i = 0; i < 365; i++) {
    final date = today.subtract(Duration(days: i));
    final key = dateKey(date);
    if ((habit.completions[key] ?? 0) > 0) {
      streak++;
    } else {
      break;  // Stop at first gap
    }
  }
  
  return streak;
}
```

#### Consistency Calculation
```dart
double calculateConsistency(Habit habit, DateTime month) {
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  int completedDays = 0;
  
  for (int i = 1; i <= daysInMonth; i++) {
    final date = DateTime(month.year, month.month, i);
    final key = dateKey(date);
    if ((habit.completions[key] ?? 0) > 0) {
      completedDays++;
    }
  }
  
  return (completedDays / daysInMonth) * 100;
}
```

#### Completion Percentage
```dart
double calculateCompletionRate(Habit habit, DateTime month) {
  final now = DateTime.now();
  final isCurrentMonth = month.year == now.year && month.month == now.month;
  final daysToCheck = isCurrentMonth ? now.day : daysInMonth;
  
  int completedDays = 0;
  for (int i = 1; i <= daysToCheck; i++) {
    final date = DateTime(month.year, month.month, i);
    final key = dateKey(date);
    if ((habit.completions[key] ?? 0) > 0) {
      completedDays++;
    }
  }
  
  return (completedDays / daysToCheck) * 100;
}
```

---

### 🎨 UI Components

#### Color Identity System
```dart
// Habit color used consistently:
Container(
  color: habit.color,  // Direct color
)

LinearProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(habit.color),
)

// Heatmap blending
Color cellColor(int count) {
  if (count <= 0) return surfaceColor;
  final t = (count / maxScale).clamp(0.0, 1.0);
  return Color.lerp(surfaceColor, primaryColor, t);
}
```

#### Category Badges
```dart
// Good habit
Container(
  color: Colors.green.withOpacity(0.15),
  child: Row(
    children: [
      Icon(Icons.check_circle_rounded, color: Colors.green),
      Text('Good', style: TextStyle(color: Colors.green)),
    ],
  ),
)

// Bad habit
Container(
  color: Colors.red.withOpacity(0.15),
  child: Row(
    children: [
      Icon(Icons.cancel_rounded, color: Colors.red),
      Text('Bad', style: TextStyle(color: Colors.red)),
    ],
  ),
)
```

---

### 🔄 State Management

#### HabitsState (Provider)
No changes needed! Existing methods work:
- `addHabit(Habit habit)` - Already supports category
- `toggleDoneToday(String id)` - Works as before
- `aggregatedCompletions()` - Used by heatmap

#### Data Flow
```
UI Action
  ↓
Provider (HabitsState)
  ↓
HabitsDb (SQLite operations)
  ↓
Database (habits.db)
  ↓
notifyListeners()
  ↓
UI Updates
```

---

### 🧪 Testing Checklist

- [ ] Create good habit
- [ ] Create bad habit
- [ ] Complete habits multiple times in a day
- [ ] View analytics with data
- [ ] Check consistency calculation
- [ ] Verify streak counting
- [ ] Tap heatmap dates
- [ ] View history
- [ ] Delete habit (cascade delete completions)
- [ ] Dark mode compatibility
- [ ] Database migration (v1 → v2)

---

### 🐛 Potential Issues & Solutions

#### Issue: Database migration error
**Solution:** Uninstall app and reinstall (dev only), or ensure onUpgrade properly handles migration

#### Issue: Heatmap not showing tap details
**Solution:** Ensure `habits` parameter is passed to HeatmapCalendar

#### Issue: Category not saving
**Solution:** Check database version is 2 and column exists

#### Issue: Analytics shows 0%
**Solution:** Ensure habits have completion data for the selected month

---

### 📝 Code Style Guidelines

1. **Naming:**
   - Private classes: `_ClassName`
   - Private methods: `_methodName`
   - Public: camelCase

2. **Widget Organization:**
   - Main widget at top
   - Helper widgets below
   - Private methods at bottom

3. **Constants:**
   - Colors, durations, etc. as const
   - Month names as const arrays

4. **Comments:**
   - Explain WHY, not WHAT
   - Keep concise
   - Use Indonesian for user-facing text

---

### 🚀 Build Commands

```bash
# Get dependencies
flutter pub get

# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle

# Analyze code
flutter analyze

# Format code
flutter format .
```

---

### 📚 Dependencies

No new dependencies added! All features use existing packages:
- `provider` - State management
- `sqflite` - Database
- `path` - Path utilities
- Flutter SDK built-in widgets

---

**Last Updated:** January 13, 2026
**Database Version:** 2
**App Version:** 1.0.0+1
