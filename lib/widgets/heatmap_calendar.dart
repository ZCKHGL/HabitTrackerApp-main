import 'package:flutter/material.dart';
import '../models/habit.dart';

class HeatmapCalendar extends StatelessWidget {
  final Map<DateTime, int> completions; // date -> count (total)
  final Map<DateTime, int>? goodCompletions; // date -> good habit count
  final Map<DateTime, int>? badCompletions; // date -> bad habit count
  final DateTime month; // any day in month
  final int maxScale; // scale intensity
  final bool showTitle; // whether to show the title
  final bool onlyToday; // tambah
  final List<Habit>? habits; // tambah untuk detail per tanggal
  final Function(DateTime)? onDateTap; // callback saat tanggal di-tap

  const HeatmapCalendar({
    super.key,
    required this.completions,
    required this.month,
    this.goodCompletions,
    this.badCompletions,
    this.maxScale = 5,
    this.showTitle = true,
    this.onlyToday = false,
    this.habits,
    this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Color constants for good/bad habits
    const Color goodColorLight = Color(0xFFE3F2FD); // Light blue
    const Color goodColorDark = Color(0xFF1565C0); // Dark blue
    const Color badColorLight = Color(0xFFFFEBEE); // Light red
    const Color badColorDark = Color(0xFFC62828); // Dark red

    // Function to calculate cell color based on good/bad habit counts
    Color getCellColor(DateTime date) {
      final day = DateTime(date.year, date.month, date.day);
      final goodCount = goodCompletions?[day] ?? 0;
      final badCount = badCompletions?[day] ?? 0;
      final totalCount = completions[day] ?? 0;

      if (totalCount <= 0) {
        return scheme.surfaceContainerHighest.withValues(alpha: 0.30);
      }

      // If we have separate good/bad data
      if (goodCompletions != null && badCompletions != null) {
        // Pure bad habits day - light red to dark red gradient
        if (badCount > 0 && goodCount == 0) {
          final t = (badCount / maxScale).clamp(0.0, 1.0);
          return Color.lerp(badColorLight, badColorDark, t)!
              .withValues(alpha: 0.90);
        }

        // Pure good habits day - light green to dark green gradient
        if (goodCount > 0 && badCount == 0) {
          final t = (goodCount / maxScale).clamp(0.0, 1.0);
          return Color.lerp(goodColorLight, goodColorDark, t)!
              .withValues(alpha: 0.90);
        }

        // Mixed day - blend colors based on ratio
        if (goodCount > 0 && badCount > 0) {
          final total = goodCount + badCount;
          final badRatio = badCount / total;

          // Calculate intensity for each
          final badIntensity = (badCount / maxScale).clamp(0.0, 1.0);
          final goodIntensity = (goodCount / maxScale).clamp(0.0, 1.0);

          final badColor =
              Color.lerp(badColorLight, badColorDark, badIntensity)!;
          final goodColor =
              Color.lerp(goodColorLight, goodColorDark, goodIntensity)!;

          // Blend based on ratio
          return Color.lerp(goodColor, badColor, badRatio)!
              .withValues(alpha: 0.90);
        }
      }

      // Fallback to original behavior (primary color)
      final t = (totalCount / maxScale).clamp(0.0, 1.0);
      return Color.lerp(scheme.surfaceContainerHighest, scheme.primary, t)!
          .withValues(alpha: 0.85);
    }

    if (onlyToday) {
      final today = DateTime.now();
      final day = DateTime(today.year, today.month, today.day);

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: getCellColor(day),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text("${day.day}",
                style: Theme.of(context).textTheme.labelSmall),
          ),
        ],
      );
    }

    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // make Sunday=0
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "${_monthName(month.month)} ${month.year}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 1.1,
          ),
          itemCount: rows * 7,
          itemBuilder: (context, index) {
            final dayNum = index - startWeekday + 1;
            if (dayNum <= 0 || dayNum > daysInMonth) {
              return const SizedBox.shrink();
            }
            final date = DateTime(month.year, month.month, dayNum);
            final count =
                completions[DateTime(date.year, date.month, date.day)] ?? 0;

            return GestureDetector(
              onTap: () {
                if (onDateTap != null) {
                  onDateTap!(date);
                } else if (habits != null && count > 0) {
                  _showDateDetails(context, date, habits!);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: getCellColor(date),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$dayNum",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _monthName(int m) {
    const names = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return names[m - 1];
  }

  void _showDateDetails(
      BuildContext context, DateTime date, List<Habit> habits) {
    final key = dateKey(date);
    final completedHabits =
        habits.where((h) => (h.completions[key] ?? 0) > 0).toList();

    if (completedHabits.isEmpty) return;

    final goodHabits =
        completedHabits.where((h) => h.category == HabitCategory.good).toList();
    final badHabits =
        completedHabits.where((h) => h.category == HabitCategory.bad).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${date.day} ${_monthName(date.month)} ${date.year}',
          style: const TextStyle(fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (goodHabits.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      'Good Habits',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...goodHabits.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: h.color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(h.name)),
                          if ((h.completions[key] ?? 0) > 1)
                            Text(
                              '×${h.completions[key]}',
                              style: TextStyle(
                                color: h.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
              ],
              if (badHabits.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.cancel_rounded, size: 16, color: Colors.red),
                    const SizedBox(width: 6),
                    Text(
                      'Bad Habits',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...badHabits.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: h.color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(h.name)),
                          if ((h.completions[key] ?? 0) > 1)
                            Text(
                              '×${h.completions[key]}',
                              style: TextStyle(
                                color: h.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
