import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/habits_state.dart';
import '../models/habit.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  void _prevMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hs = context.watch<HabitsState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Month selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _prevMonth,
              ),
              Text(
                "${_monthName(_selectedMonth.month)} ${_selectedMonth.year}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Monthly Progress (Candlestick-style)
          _MonthlyProgressCard(month: _selectedMonth, habits: hs.habits),
          const SizedBox(height: 16),

          // Consistency Percentage
          _ConsistencyCard(month: _selectedMonth, habits: hs.habits),
          const SizedBox(height: 16),

          // Streak
          _StreakCard(habits: hs.habits),
          const SizedBox(height: 16),

          // Habits Percentage
          _HabitsPercentageCard(month: _selectedMonth, habits: hs.habits),
        ],
      ),
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
}

// Monthly Progress Card (Candlestick Style)
class _MonthlyProgressCard extends StatelessWidget {
  final DateTime month;
  final List<Habit> habits;

  const _MonthlyProgressCard({required this.month, required this.habits});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final scheme = Theme.of(context).colorScheme;

    // Calculate daily totals - separate good and bad
    final List<int> dailyGoodTotals = List.generate(daysInMonth, (index) {
      final date = DateTime(month.year, month.month, index + 1);
      final key = dateKey(date);
      int total = 0;
      for (final h in habits.where((h) => h.category == HabitCategory.good)) {
        total += h.completions[key] ?? 0;
      }
      return total;
    });

    final List<int> dailyBadTotals = List.generate(daysInMonth, (index) {
      final date = DateTime(month.year, month.month, index + 1);
      final key = dateKey(date);
      int total = 0;
      for (final h in habits.where((h) => h.category == HabitCategory.bad)) {
        total += h.completions[key] ?? 0;
      }
      return total;
    });

    final List<int> dailyTotals = List.generate(daysInMonth, (index) {
      return dailyGoodTotals[index] + dailyBadTotals[index];
    });

    final maxDaily = dailyTotals.isEmpty
        ? 1
        : dailyTotals.reduce((a, b) => a > b ? a : b).toDouble();

    final totalGood = dailyGoodTotals.reduce((a, b) => a + b);
    final totalBad = dailyBadTotals.reduce((a, b) => a + b);
    final avgDaily = dailyTotals.isEmpty
        ? 0.0
        : dailyTotals.reduce((a, b) => a + b) / dailyTotals.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Monthly Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Candlestick-style chart with good (blue) and bad (red) habits stacked
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(daysInMonth, (index) {
                  final goodCount = dailyGoodTotals[index];
                  final badCount = dailyBadTotals[index];

                  final goodHeight =
                      maxDaily == 0 ? 0.0 : (goodCount / maxDaily) * 130;
                  final badHeight =
                      maxDaily == 0 ? 0.0 : (badCount / maxDaily) * 130;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Stacked bars - bad habits on top, good habits below
                          if (badCount > 0)
                            Container(
                              height: badHeight + 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF5350)
                                    .withOpacity(0.85), // Red for bad
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(2),
                                ),
                              ),
                            ),
                          if (goodCount > 0)
                            Container(
                              height: goodHeight + 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFF42A5F5)
                                    .withOpacity(0.85), // Blue for good
                                borderRadius: badCount > 0
                                    ? BorderRadius.zero
                                    : const BorderRadius.vertical(
                                        top: Radius.circular(2),
                                      ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          if ((index + 1) % 5 == 0)
                            Text(
                              '${index + 1}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontSize: 8,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text('Good Habits',
                    style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(width: 16),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text('Bad Habits',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 12),

            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem('Total Good', totalGood.toString(),
                    const Color(0xFF42A5F5)),
                _StatItem(
                    'Avg/Day', avgDaily.toStringAsFixed(1), scheme.secondary),
                _StatItem(
                    'Total Bad', totalBad.toString(), const Color(0xFFEF5350)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

// Consistency Card
class _ConsistencyCard extends StatelessWidget {
  final DateTime month;
  final List<Habit> habits;

  const _ConsistencyCard({required this.month, required this.habits});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;
    final daysToCheck = isCurrentMonth ? now.day : daysInMonth;

    final scheme = Theme.of(context).colorScheme;

    Map<String, double> habitConsistency = {};

    for (final h in habits) {
      int completedDays = 0;
      for (int i = 1; i <= daysToCheck; i++) {
        final date = DateTime(month.year, month.month, i);
        final key = dateKey(date);
        if ((h.completions[key] ?? 0) > 0) {
          completedDays++;
        }
      }
      habitConsistency[h.name] = (completedDays / daysToCheck) * 100;
    }

    final avgConsistency = habitConsistency.isEmpty
        ? 0.0
        : habitConsistency.values.reduce((a, b) => a + b) /
            habitConsistency.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up_rounded, color: scheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Consistency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Overall consistency
            Center(
              child: Column(
                children: [
                  Text(
                    '${avgConsistency.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Average Consistency',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: avgConsistency / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Streak Card
class _StreakCard extends StatelessWidget {
  final List<Habit> habits;

  const _StreakCard({required this.habits});

  int _calculateStreak(Habit habit) {
    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final key = dateKey(date);
      if ((habit.completions[key] ?? 0) > 0) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final streaks = habits
        .map((h) => {
              'name': h.name,
              'streak': _calculateStreak(h),
              'color': h.color,
            })
        .toList();

    streaks.sort((a, b) => (b['streak'] as int).compareTo(a['streak'] as int));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Streak (Days)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (streaks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No habits yet'),
                ),
              )
            else
              ...streaks.take(5).map((s) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: s['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s['name'] as String,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '${s['streak']} days',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// Habits Percentage Card
class _HabitsPercentageCard extends StatelessWidget {
  final DateTime month;
  final List<Habit> habits;

  const _HabitsPercentageCard({required this.month, required this.habits});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;
    final daysToCheck = isCurrentMonth ? now.day : daysInMonth;

    final scheme = Theme.of(context).colorScheme;

    // Calculate completion percentage for each habit
    final habitData = habits.map((h) {
      int completedDays = 0;
      for (int i = 1; i <= daysToCheck; i++) {
        final date = DateTime(month.year, month.month, i);
        final key = dateKey(date);
        if ((h.completions[key] ?? 0) > 0) {
          completedDays++;
        }
      }
      return {
        'habit': h,
        'percentage': (completedDays / daysToCheck) * 100,
        'completed': completedDays,
      };
    }).toList();

    habitData.sort((a, b) =>
        (b['percentage'] as double).compareTo(a['percentage'] as double));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart_rounded, color: scheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  'Habits Completion',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (habitData.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No habits yet'),
                ),
              )
            else
              ...habitData.map((data) {
                final h = data['habit'] as Habit;
                final percentage = data['percentage'] as double;
                final completed = data['completed'] as int;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                          Expanded(
                            child: Text(
                              h.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: h.color,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                              backgroundColor: scheme.surfaceContainerHighest
                                  .withOpacity(0.3),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(h.color),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$completed/$daysToCheck',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
