import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/habit.dart';
import '../state/habits_state.dart';
import '../widgets/wheel_timer_picker.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _nameCtrl = TextEditingController();
  bool _timed = false;
  Duration _target = const Duration(minutes: 25);
  HabitCategory _category = HabitCategory.good; // Default good habit

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.habitNameEmpty)),
      );
      return;
    }
    final habit = Habit(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      type: _timed ? HabitType.timed : HabitType.untimed,
      target: _timed ? _target : Duration.zero,
      category: _category, // Category determines color automatically
    );
    context.read<HabitsState>().addHabit(habit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addHabit),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: l10n.addHabit,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.habitCategory, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<HabitCategory>(
            segments: [
              ButtonSegment(
                value: HabitCategory.good,
                label: Text(l10n.goodHabit),
                icon: const Icon(Icons.check_circle_outline),
              ),
              ButtonSegment(
                value: HabitCategory.bad,
                label: Text(l10n.badHabit),
                icon: const Icon(Icons.cancel_outlined),
              ),
            ],
            selected: {_category},
            onSelectionChanged: (Set<HabitCategory> newSelection) {
              setState(() {
                _category = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 8),
          // Info warna otomatis
          Row(
            children: [
              Icon(
                Icons.palette_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _category == HabitCategory.good
                      ? l10n.colorBlueAutomatic
                      : l10n.colorRedAutomatic,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _category == HabitCategory.good
                      ? const Color(0xFF42A5F5)
                      : const Color(0xFFEF5350),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(l10n.useTimer),
            value: _timed,
            onChanged: (v) => setState(() => _timed = v),
          ),
          const SizedBox(height: 8),
          if (_timed)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.setDuration,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: WheelTimerPicker(
                    initial: _target,
                    onChanged: (d) => _target = d,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
