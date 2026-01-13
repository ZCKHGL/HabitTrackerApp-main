import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../state/habits_state.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final todayKey = dateKey(DateTime.now());
    final doneToday = (habit.completions[todayKey] ?? 0) > 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _leading(context, doneToday: doneToday),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(habit.name,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      // Badge untuk kategori
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: habit.category == HabitCategory.good
                              ? Colors.green.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                              habit.category == HabitCategory.good
                                  ? 'Good'
                                  : 'Bad',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: habit.category == HabitCategory.good
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  habit.isTimed
                      ? Text(_timedSubtitle(),
                          style: Theme.of(context).textTheme.bodySmall)
                      : Text('Tap lingkaran untuk tandai selesai hari ini',
                          style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (habit.isTimed)
              _timerControls(context)
            else
              IconButton(
                icon: Icon(doneToday
                    ? Icons.check_circle
                    : Icons.check_circle_outline),
                color: doneToday ? cs.primary : cs.outline,
                onPressed: () =>
                    context.read<HabitsState>().toggleDoneToday(habit.id),
              ),
          ],
        ),
      ),
    );
  }

  Widget _leading(BuildContext context, {required bool doneToday}) {
    if (!habit.isTimed) {
      return GestureDetector(
        onTap: () => context.read<HabitsState>().toggleDoneToday(habit.id),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: habit.color.withValues(alpha: doneToday ? 0.4 : 0.25),
            border: Border.all(color: habit.color, width: 2),
          ),
          child:
              doneToday ? const Icon(Icons.check, color: Colors.white) : null,
        ),
      );
    }
    final progress = habit.progress;
    // Show checkmark if timer is complete (100%) OR if user has completed today
    final showCheckmark = progress >= 1.0 || doneToday;
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress == 0 ? 0.01 : progress,
            strokeCap: StrokeCap.round,
            strokeWidth: 6,
            color: habit.color,
            backgroundColor: habit.color.withValues(alpha: 0.15),
          ),
          if (showCheckmark)
            Container(
              decoration:
                  BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.check, size: 20, color: Colors.white),
            )
          else
            Text("${(progress * 100).floor()}%",
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _timerControls(BuildContext context) {
    final hs = context.read<HabitsState>();
    final isRunning = habit.status == TimerStatus.running;
    final todayKey = dateKey(DateTime.now());
    final doneToday = (habit.completions[todayKey] ?? 0) > 0;
    final isCompleted = habit.progress >= 1.0 || doneToday;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          icon: Icon(isCompleted
              ? Icons.restart_alt_rounded
              : (isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded)),
          onPressed: () {
            if (isCompleted) {
              hs.restartHabit(habit.id);
            } else {
              hs.togglePlayPause(habit.id);
            }
          },
        ),
        const SizedBox(width: 6),
        IconButton.outlined(
          icon: const Icon(Icons.stop_rounded),
          onPressed: isCompleted ? null : () => hs.stopHabit(habit.id),
        ),
      ],
    );
  }

  String _timedSubtitle() {
    String fmt(Duration d) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      final s = d.inSeconds.remainder(60);
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }

    return "${fmt(habit.elapsed)} / ${fmt(habit.target)}";
  }
}
