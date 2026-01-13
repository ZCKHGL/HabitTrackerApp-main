import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/habit.dart';

class HabitsDb {
  HabitsDb._();
  static final HabitsDb I = HabitsDb._();

  Database? _db;

  // Fallback in-memory untuk web atau saat DB gagal dibuka
  bool _fallbackMemory = kIsWeb;
  final Map<String, Map<String, Object?>> _memHabits = {};
  final Map<String, Map<String, int>> _memCompletions = {};

  Future<Database> _open() async {
    if (_db != null) return _db!;
    if (_fallbackMemory) {
      // mode memori: hindari membuka DB
      throw StateError('Using in-memory fallback');
    }
    try {
      final dir = await getDatabasesPath();
      final path = p.join(dir, 'habits.db');
      _db = await openDatabase(
        path,
        version: 3, // increment version untuk remove color column
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, v) async {
          await db.execute('''
          CREATE TABLE habits(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type INTEGER NOT NULL,       -- 0 untimed, 1 timed
            targetSeconds INTEGER NOT NULL DEFAULT 0,
            category INTEGER NOT NULL DEFAULT 0  -- 0 good, 1 bad
          )
          ''');
          await db.execute('''
          CREATE TABLE completions(
            habit_id TEXT NOT NULL,
            date TEXT NOT NULL,          -- simpan key dari dateKey()
            count INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY(habit_id, date),
            FOREIGN KEY(habit_id) REFERENCES habits(id) ON DELETE CASCADE
          )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // Tambah kolom category untuk database lama
            await db.execute(
                'ALTER TABLE habits ADD COLUMN category INTEGER NOT NULL DEFAULT 0');
          }
          if (oldVersion < 3) {
            // Remove color column - create new table without it
            await db.execute('''
              CREATE TABLE habits_new(
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                type INTEGER NOT NULL,
                targetSeconds INTEGER NOT NULL DEFAULT 0,
                category INTEGER NOT NULL DEFAULT 0
              )
            ''');
            // Copy data (color akan diabaikan)
            await db.execute('''
              INSERT INTO habits_new (id, name, type, targetSeconds, category)
              SELECT id, name, type, targetSeconds, category FROM habits
            ''');
            // Drop old table
            await db.execute('DROP TABLE habits');
            // Rename new table
            await db.execute('ALTER TABLE habits_new RENAME TO habits');
          }
        },
      );
      return _db!;
    } catch (_) {
      // jika gagal, aktifkan fallback memory agar app tetap jalan
      _fallbackMemory = true;
      rethrow;
    }
  }

  Future<List<Habit>> loadHabits() async {
    if (_fallbackMemory) {
      final list = _memHabits.values.map(Habit.fromMap).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      for (final h in list) {
        final comps = _memCompletions[h.id];
        if (comps != null) {
          comps.forEach((k, v) => h.completions[k] = v);
        }
      }
      return list;
    }
    final db = await _open();
    final rows = await db.query('habits', orderBy: 'name COLLATE NOCASE ASC');
    final List<Habit> list = rows.map(Habit.fromMap).toList();
    for (final h in list) {
      final comps = await db.query(
        'completions',
        where: 'habit_id = ?',
        whereArgs: [h.id],
      );
      for (final r in comps) {
        final date = r['date'] as String;
        final count = r['count'] as int;
        h.completions[date] = count;
      }
    }
    return list;
  }

  Future<void> insertHabit(Habit h) async {
    if (_fallbackMemory) {
      _memHabits[h.id] = h.toMap();
      return;
    }
    final db = await _open();
    await db.insert('habits', h.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<void> deleteHabit(String id) async {
    if (_fallbackMemory) {
      _memHabits.remove(id);
      _memCompletions.remove(id);
      return;
    }
    final db = await _open();
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCompletion(String habitId, String day) async {
    if (_fallbackMemory) {
      return _memCompletions[habitId]?[day] ?? 0;
    }
    final db = await _open();
    final r = await db.query(
      'completions',
      columns: const ['count'],
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, day],
      limit: 1,
    );
    if (r.isEmpty) return 0;
    return (r.first['count'] as int);
  }

  Future<void> setCompletion(String habitId, String day, int count) async {
    if (_fallbackMemory) {
      final m = _memCompletions.putIfAbsent(habitId, () => {});
      if (count <= 0) {
        m.remove(day);
      } else {
        m[day] = count;
      }
      return;
    }
    final db = await _open();
    await db.insert(
      'completions',
      {'habit_id': habitId, 'date': day, 'count': count},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> incrementCompletion(
      String habitId, String day, int delta) async {
    if (_fallbackMemory) {
      final m = _memCompletions.putIfAbsent(habitId, () => {});
      final current = m[day] ?? 0;
      final next = current + delta;
      if (next <= 0) {
        m.remove(day);
      } else {
        m[day] = next;
      }
      return;
    }
    final db = await _open();
    await db.transaction((txn) async {
      final r = await txn.query(
        'completions',
        columns: const ['count'],
        where: 'habit_id = ? AND date = ?',
        whereArgs: [habitId, day],
        limit: 1,
      );
      final current = r.isEmpty ? 0 : (r.first['count'] as int);
      final next = current + delta;
      if (next <= 0) {
        await txn.delete(
          'completions',
          where: 'habit_id = ? AND date = ?',
          whereArgs: [habitId, day],
        );
      } else {
        await txn.insert(
          'completions',
          {'habit_id': habitId, 'date': day, 'count': next},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
