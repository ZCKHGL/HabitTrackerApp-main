import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/habits_state.dart';
import '../models/habit.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hs = context.watch<HabitsState>();

    // Collect all completion dates from all habits
    final Map<String, List<Map<String, dynamic>>> historyByDate = {};

    for (final habit in hs.habits) {
      habit.completions.forEach((dateKey, count) {
        if (count > 0) {
          historyByDate.putIfAbsent(dateKey, () => []);
          historyByDate[dateKey]!.add({
            'habit': habit,
            'count': count,
          });
        }
      });
    }

    // Sort dates in descending order (newest first)
    final sortedDates = historyByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: sortedDates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No history yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start completing habits to see your history',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final dateKey = sortedDates[index];
                final date = DateTime.parse(dateKey);
                final entries = historyByDate[dateKey]!;

                return _HistoryDateCard(
                  date: date,
                  entries: entries,
                );
              },
            ),
    );
  }
}

class _HistoryDateCard extends StatelessWidget {
  final DateTime date;
  final List<Map<String, dynamic>> entries;

  const _HistoryDateCard({
    required this.date,
    required this.entries,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Calculate total completions for the day
    final totalCount =
        entries.fold<int>(0, (sum, entry) => sum + (entry['count'] as int));

    // Separate good and bad habits
    final goodHabits = entries
        .where((e) => (e['habit'] as Habit).category == HabitCategory.good)
        .toList();
    final badHabits = entries
        .where((e) => (e['habit'] as Habit).category == HabitCategory.bad)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDate(date),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getDayName(date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalCount',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Good Habits Section
            if (goodHabits.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 16, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    'Good Habits',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...goodHabits.map((entry) => _HabitEntry(
                    habit: entry['habit'] as Habit,
                    count: entry['count'] as int,
                  )),
              const SizedBox(height: 12),
            ],

            // Bad Habits Section
            if (badHabits.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.cancel_rounded, size: 16, color: Colors.red),
                  const SizedBox(width: 6),
                  Text(
                    'Bad Habits',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...badHabits.map((entry) => _HabitEntry(
                    habit: entry['habit'] as Habit,
                    count: entry['count'] as int,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _HabitEntry extends StatelessWidget {
  final Habit habit;
  final int count;

  const _HabitEntry({
    required this.habit,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: habit.color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habit.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (count > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: habit.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '×$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: habit.color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
