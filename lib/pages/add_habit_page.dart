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
  Color _color = const Color(0xFF42A5F5);

  final _palette = const [
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFF5C6BC0),
    Color(0xFF42A5F5),
    Color(0xFF26A69A),
    Color(0xFFFFA726),
  ];

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
      color: _color,
      type: _timed ? HabitType.timed : HabitType.untimed,
      target: _timed ? _target : Duration.zero,
    );
    context.read<HabitsState>().addHabit(habit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
          Text('Pilih Warna', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _palette
                .map((c) => GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c,
                          border: Border.all(
                            color: _color == c ? cs.onPrimary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ))
                .toList(),
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
                Text('Atur Durasi', style: Theme.of(context).textTheme.titleSmall),
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
