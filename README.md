# Habit Tracker App

A beautiful and minimalist Flutter application to track your good and bad habits with powerful analytics and visualizations.

## 📱 Features

### Core Features
- ✅ **Track Habits**: Create unlimited good and bad habits
- ⏱️ **Timed & Untimed**: Support for both regular habits and time-based habits
- 🎨 **Color Identity**: Assign unique colors to identify each habit
- 📊 **Heatmap Calendar**: Visual representation of your habit completion
- 📈 **Analytics Dashboard**: Comprehensive statistics and insights
- 📜 **History**: Complete chronological history of all completions
- 🌓 **Dark Mode**: Beautiful light and dark themes

### Analytics Features
1. **Monthly Progress (Candlestick Chart)**
   - Daily completion statistics
   - Maximum, minimum, and average metrics
   - Visual bar chart representation

2. **Consistency Percentage**
   - Overall consistency score
   - Days completed vs total days
   - Progress visualization

3. **Streak Counter**
   - Consecutive days tracking
   - Top 5 longest streaks
   - Real-time streak updates

4. **Habits Completion Rate**
   - Individual habit performance
   - Percentage-based progress bars
   - Completion vs target comparison

### Enhanced Heatmap
- **Interactive Calendar**: Tap any date to see details
- **Good vs Bad Habits**: Visual separation with icons
- **Color Coding**: Intensity-based coloring (0-5+ scale)
- **Monthly Navigation**: Easy month switching

### History Tracking
- **Chronological View**: Newest entries first
- **Categorized Display**: Good and bad habits separated
- **Daily Summary**: Total completions per day
- **Detailed Information**: Which habits were completed and how many times

## 🗄️ Database

The app uses **SQLite** for local data storage with the following structure:

### Tables

#### `habits`
| Column | Type | Description |
|--------|------|-------------|
| id | TEXT | Primary key |
| name | TEXT | Habit name |
| color | INTEGER | ARGB color value |
| type | INTEGER | 0=untimed, 1=timed |
| targetSeconds | INTEGER | Target duration (for timed habits) |
| category | INTEGER | 0=good habit, 1=bad habit |

#### `completions`
| Column | Type | Description |
|--------|------|-------------|
| habit_id | TEXT | Foreign key to habits |
| date | TEXT | ISO8601 date string |
| count | INTEGER | Times completed on this date |

For detailed database documentation, see [DATASET_DOCUMENTATION.md](DATASET_DOCUMENTATION.md)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.3.0 <4.0.0)
- Dart SDK
- Android Studio / VS Code
- Android/iOS emulator or physical device

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd HabitTrackerApp-main
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## 🎨 Screenshots

### Home Screen
- Heatmap calendar showing monthly activity
- List of all habits with completion status
- Quick access to timer controls

### Analytics
- Monthly progress chart
- Consistency metrics
- Streak information
- Per-habit statistics

### History
- Day-by-day completion log
- Categorized by good/bad habits
- Searchable and filterable

## 📖 Usage Guide

### Creating a Habit
1. Tap the **+ Tambah** button
2. Enter habit name
3. Choose a color for identification
4. Select category (Good Habit or Bad Habit)
5. Toggle timer if needed and set duration
6. Tap **SIMPAN**

### Completing a Habit
- **Untimed**: Tap the circle or checkmark icon
- **Timed**: Start the timer, let it run to completion

### Viewing Analytics
1. Tap the **bar chart** icon in the app bar
2. Navigate between months to see historical data
3. View different metrics (progress, consistency, streak, completion rate)

### Checking History
1. Tap the **history** icon in the app bar
2. Scroll through chronological entries
3. See which habits were completed each day

### Interactive Heatmap
1. Tap any date on the heatmap calendar
2. View popup showing all habits completed on that date
3. See categorization (good vs bad habits)

## 🛠️ Technical Details

### Architecture
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **UI Framework**: Material Design 3
- **Platform Support**: Android, iOS, Windows, macOS, Linux, Web*

*Note: Web uses in-memory fallback storage

### Key Packages
- `provider`: State management
- `sqflite`: Local database
- `path`: Path manipulation

### Project Structure
```
lib/
├── data/
│   └── habits_db.dart          # Database operations
├── models/
│   └── habit.dart              # Habit model & enums
├── pages/
│   ├── home_page.dart          # Main screen
│   ├── add_habit_page.dart     # Create habit
│   ├── analytics_page.dart     # Analytics dashboard
│   └── history_page.dart       # History view
├── state/
│   ├── habits_state.dart       # Habit state management
│   └── app_settings.dart       # App settings
├── widgets/
│   ├── habit_card.dart         # Habit item widget
│   ├── heatmap_calendar.dart   # Calendar heatmap
│   └── wheel_timer_picker.dart # Time picker
├── theme.dart                  # App theming
└── main.dart                   # Entry point
```

## 📊 Data Privacy

- ✅ All data stored locally on device
- ✅ No cloud synchronization
- ✅ No analytics or tracking
- ✅ Complete data ownership
- ✅ Works offline

## 🎯 Future Enhancements

- [ ] Cloud backup (Firebase/Supabase)
- [ ] Habit reminders/notifications
- [ ] Export data (JSON/CSV)
- [ ] Achievement badges
- [ ] Habit notes/reflections
- [ ] Weekly/monthly reports
- [ ] Goal setting
- [ ] Social features

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Development

### Running Tests
```bash
flutter test
```

### Building for Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release
```

## 📞 Support

For questions or issues, please open an issue on the repository.

---

**Made with ❤️ using Flutter**
