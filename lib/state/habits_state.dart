import 'dart:async';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/habits_db.dart';

class HabitsState extends ChangeNotifier {
  final List<Habit> _habits = [];
  Timer? _ticker;
  final HabitsDb _db = HabitsDb.I;

  List<Habit> get habits => List.unmodifiable(_habits);

  HabitsState() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      bool changed = false;
      for (final h in _habits) {
        final before = h.elapsed;
        h.tick();

        // Jika mencapai target: kunci di 100%, auto-pause, dan catat completion.
        if (h.isTimed &&
            !h.lockAtFull &&
            h.target > Duration.zero &&
            h.elapsed >= h.target) {
          h.elapsed = h.target;
          h.status = TimerStatus.paused;
          h.lockAtFull = true;
          changed = true;

          // Catat completion otomatis ketika mencapai target
          final key = dateKey(DateTime.now());
          h.completions[key] = (h.completions[key] ?? 0) + 1;
          await _db.incrementCompletion(h.id, key, 1);

          continue;
        }

        if (h.elapsed != before) changed = true;
      }
      if (changed) notifyListeners();
    });

    // Don't load habits here - wait for onUserChanged to be called
    // This ensures we load the correct user's habits after auth is ready
  }

  /// Call this when user changes (login/logout) to reload data
  Future<void> onUserChanged(String userId) async {
    debugPrint('HabitsState.onUserChanged: Setting userId to "$userId"');
    _db.setUserId(userId);
    await _loadFromDb();
    debugPrint(
        'HabitsState.onUserChanged: Loaded ${_habits.length} habits for user "$userId"');
  }

  Future<void> _loadFromDb() async {
    final loaded = await _db.loadHabits();
    _habits
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    debugPrint(
        'HabitsState.addHabit: Adding habit "${habit.name}" for user "${_db.userId}"');
    _habits.add(habit);
    notifyListeners();
    await _db.insertHabit(habit);
  }

  Future<void> removeHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
    await _db.deleteHabit(id);
  }

  void togglePlayPause(String id) {
    final h = _habits.firstWhere((e) => e.id == id);

    // Hanya satu timer berjalan: pause semua timer lain sebelum start
    if (h.isTimed && h.status != TimerStatus.running) {
      for (final other in _habits) {
        if (other.id != h.id &&
            other.isTimed &&
            other.status == TimerStatus.running) {
          other.pause();
        }
      }
    }

    h.togglePlayPause();
    notifyListeners();
  }

  Future<void> stopHabit(String id) async {
    final h = _habits.firstWhere((e) => e.id == id);

    // Ambil status sebelum stop
    final hadProgress = h.elapsed > Duration.zero;

    // Stop (tanpa mencatat completion di model; kita tangani di sini)
    h.stopAndCommit();
    notifyListeners();

    // Checklist hanya saat Stop jika ada progress (baik penuh atau tidak)
    if (h.isTimed && hadProgress) {
      final key = dateKey(DateTime.now());
      h.completions[key] = (h.completions[key] ?? 0) + 1;
      await _db.incrementCompletion(id, key, 1);
    }
  }

  Future<void> restartHabit(String id) async {
    final h = _habits.firstWhere((e) => e.id == id);

    // Reset timer state
    h.elapsed = Duration.zero;
    h.status = TimerStatus.stopped;
    h.lockAtFull = false;

    // Remove today's completion
    final key = dateKey(DateTime.now());
    h.completions.remove(key);
    await _db.setCompletion(id, key, 0);

    notifyListeners();
  }

  Future<void> toggleDoneToday(String id) async {
    final h = _habits.firstWhere((e) => e.id == id);
    h.toggleDoneToday();
    notifyListeners();
    final key = dateKey(DateTime.now());
    final newCount = h.completions[key] ?? 0;
    await _db.setCompletion(id, key, newCount);
  }

  // Agregasi untuk heatmap: total completion per hari dari semua habit
  Map<DateTime, int> aggregatedCompletions() {
    final Map<DateTime, int> acc = {};
    for (final h in _habits) {
      h.completions.forEach((k, v) {
        final d = DateTime.parse(k);
        final day = DateTime(d.year, d.month, d.day);
        acc[day] = (acc[day] ?? 0) + v;
      });
    }
    return acc;
  }

  // Agregasi untuk heatmap: total GOOD habit completions per hari
  Map<DateTime, int> aggregatedGoodCompletions() {
    final Map<DateTime, int> acc = {};
    for (final h in _habits.where((h) => h.category == HabitCategory.good)) {
      h.completions.forEach((k, v) {
        final d = DateTime.parse(k);
        final day = DateTime(d.year, d.month, d.day);
        acc[day] = (acc[day] ?? 0) + v;
      });
    }
    return acc;
  }

  // Agregasi untuk heatmap: total BAD habit completions per hari
  Map<DateTime, int> aggregatedBadCompletions() {
    final Map<DateTime, int> acc = {};
    for (final h in _habits.where((h) => h.category == HabitCategory.bad)) {
      h.completions.forEach((k, v) {
        final d = DateTime.parse(k);
        final day = DateTime(d.year, d.month, d.day);
        acc[day] = (acc[day] ?? 0) + v;
      });
    }
    return acc;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
