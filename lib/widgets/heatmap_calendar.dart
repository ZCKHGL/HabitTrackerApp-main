import 'package:flutter/material.dart';

class HeatmapCalendar extends StatelessWidget {
  final Map<DateTime, int> completions; // date -> count
  final DateTime month; // any day in month
  final int maxScale;   // scale intensity
  final bool showTitle; // whether to show the title
  final bool onlyToday; // tambah

  const HeatmapCalendar({
    super.key,
    required this.completions,
    required this.month,
    this.maxScale = 5,
    this.showTitle = true,
    this.onlyToday = false,
  });

  @override
  Widget build(BuildContext context) {
    if (onlyToday) {
      final today = DateTime.now();
      final day = DateTime(today.year, today.month, today.day);
      final count = completions[day] ?? 0;
      final scheme = Theme.of(context).colorScheme;
      Color cellColor(int c) {
        if (c <= 0) return scheme.surfaceContainerHighest.withOpacity(0.3);
        final t = (c / maxScale).clamp(0.0, 1.0);
        return Color.lerp(scheme.surfaceContainerHighest, scheme.primary, t)!.withValues(alpha: 0.85);
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cellColor(count),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text("${day.day}", style: Theme.of(context).textTheme.labelSmall),
          ),
        ],
      );
    }

    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // make Sunday=0
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final scheme = Theme.of(context).colorScheme;
    final base = scheme.primary;

    Color cellColor(int count) {
      if (count <= 0) {
        return scheme.surfaceContainerHighest.withValues(alpha: 0.30);
      }
      final t = (count / maxScale).clamp(0.0, 1.0);
      final c = Color.lerp(scheme.surfaceContainerHighest, base, t)!;
      return c.withValues(alpha: 0.85);
    }

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
            final count = completions[DateTime(date.year, date.month, date.day)] ?? 0;
            return Container(
              decoration: BoxDecoration(
                color: cellColor(count),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                "$dayNum",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember'
    ];
    return names[m - 1];
  }
}
