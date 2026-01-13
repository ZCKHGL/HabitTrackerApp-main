import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama habit tidak boleh kosong')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Habit'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('SIMPAN'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nama Habit',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Kategori Habit', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<HabitCategory>(
            segments: const [
              ButtonSegment(
                value: HabitCategory.good,
                label: Text('Good Habit'),
                icon: Icon(Icons.check_circle_outline),
              ),
              ButtonSegment(
                value: HabitCategory.bad,
                label: Text('Bad Habit'),
                icon: Icon(Icons.cancel_outlined),
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
                      ? 'Warna: Biru (otomatis untuk good habits)'
                      : 'Warna: Merah (otomatis untuk bad habits)',
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
            title: const Text('Gunakan Timer'),
            value: _timed,
            onChanged: (v) => setState(() => _timed = v),
          ),
          const SizedBox(height: 8),
          if (_timed)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Atur Durasi',
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
