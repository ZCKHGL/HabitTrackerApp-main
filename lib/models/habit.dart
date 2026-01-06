import 'package:flutter/material.dart';

enum HabitType { timed, untimed }
enum TimerStatus { stopped, running, paused }

String dateKey(DateTime d) => DateTime(d.year, d.month, d.day).toIso8601String();

class Habit {
  final String id;
  String name;
  Color color;
  HabitType type;

  // Timed only
  Duration target;       // Target total (untimed: Duration.zero)
  Duration elapsed;      // Akumulasi jalannya timer saat ini
  TimerStatus status;    // running/paused/stopped
  DateTime? _lastStart;  // penanda mulai terakhir untuk hitung delta

  // Heatmap
  Map<String, int> get completions => _completions;
  final Map<String, int> _completions = {};

  // Kunci 100% sampai start ulang
  bool lockAtFull = false;

  Habit({
    required this.id,
    required this.name,
    required this.color,
    required this.type,
    Duration? target,
  })  : target = target ?? Duration.zero,
        elapsed = Duration.zero,
        status = TimerStatus.stopped;

  bool get isTimed => type == HabitType.timed;

  double get progress {
    if (!isTimed || target.inMilliseconds == 0) return 0;
    final p = elapsed.inMilliseconds / target.inMilliseconds;
    return p.clamp(0.0, 1.0).toDouble(); // ensure double
  }

  void start() {
    if (!isTimed) return;
    if (lockAtFull) {
      // mulai sesi baru dari 0 jika sebelumnya terkunci penuh
      elapsed = Duration.zero;
      lockAtFull = false;
    }
    if (status == TimerStatus.running) return;
    _lastStart = DateTime.now();
    status = TimerStatus.running;
  }

  void pause() {
    if (!isTimed) return;
    if (status != TimerStatus.running) return;
    final now = DateTime.now();
    if (_lastStart != null) {
      elapsed += now.difference(_lastStart!);
    }
    _lastStart = null;
    status = TimerStatus.paused;
  }

  void stopAndCommit() {
    if (!isTimed) return;

    // akumulasikan jika sedang berjalan
    if (status == TimerStatus.running && _lastStart != null) {
      elapsed += DateTime.now().difference(_lastStart!);
    }
    _lastStart = null;
    status = TimerStatus.stopped;

    // Jika penuh: kunci di 100% (tidak reset)
    if (target > Duration.zero && elapsed >= target) {
      elapsed = target;
      lockAtFull = true;
      return;
    }

    // Jika belum penuh dan ada progress: reset ke nol
    if (elapsed > Duration.zero) {
      elapsed = Duration.zero;
    }
  }

  void tick() {
    if (status == TimerStatus.running && _lastStart != null) {
      final now = DateTime.now();
      elapsed += now.difference(_lastStart!);
      _lastStart = now;
    }
  }

  void togglePlayPause() {
    if (!isTimed) return;
    if (status == TimerStatus.running) {
      pause();
    } else {
      start();
    }
  }

  void toggleDoneToday() {
    final key = dateKey(DateTime.now());
    final current = completions[key] ?? 0;
    completions[key] = current == 0 ? 1 : 0;
  }

  Map<String, Object?> toMap() {
    final argb = (color.alpha << 24) | (color.red << 16) | (color.green << 8) | color.blue;
    return {
      'id': id,
      'name': name,
      'color': argb, // bukan color.value
      'type': isTimed ? 1 : 0,
      'targetSeconds': target.inSeconds,
    };
  }

  static Habit fromMap(Map<String, Object?> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      type: (map['type'] as int) == 1 ? HabitType.timed : HabitType.untimed,
      target: Duration(seconds: (map['targetSeconds'] as int?) ?? 0),
    );
  }
}
