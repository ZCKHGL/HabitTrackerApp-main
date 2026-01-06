import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_settings.dart';
import '../state/habits_state.dart';
import '../widgets/heatmap_calendar.dart';
import '../widgets/habit_card.dart';
import 'add_habit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  Timer? _monthChecker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startMonthChecker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _monthChecker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndUpdateMonth();
    }
  }

  void _startMonthChecker() {
    // Check every minute if the month has changed
    _monthChecker = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAndUpdateMonth();
    });
  }

  void _checkAndUpdateMonth() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    // Check if the displayed month was the previous month and now it's a new month
    // This handles the case where user is viewing current month when it transitions
    if (_month.isBefore(currentMonth)) {
      final nextMonthAfterDisplayed =
          DateTime(_month.year, _month.month + 1, 1);
      // If the displayed month + 1 equals current month, auto-update
      if (nextMonthAfterDisplayed.year == currentMonth.year &&
          nextMonthAfterDisplayed.month == currentMonth.month) {
        setState(() {
          _month = currentMonth;
        });
      }
    }
  }

  void _prevMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month + 1, 1);
    });
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(now.year - 3, 1, 1),
      lastDate: DateTime(now.year + 3, 12, 31),
      helpText: 'Pilih Tanggal (bulan & tahun)',
    );
    if (!mounted) return; // mounted-check setelah await
    if (selected != null) {
      setState(() {
        _month = DateTime(selected.year, selected.month, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hs = context.watch<HabitsState>();
    final aggregated = hs.aggregatedCompletions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              icon: const Icon(Icons.settings_rounded),
              tooltip: 'Setting',
            ),
          ),
        ],
      ),
      endDrawer: const _SettingsDrawer(), // const constructor
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: const Icon(Icons.chevron_left), onPressed: _prevMonth),
              GestureDetector(
                onTap: _pickMonth,
                onLongPress: () => setState(() {
                  _month =
                      DateTime(DateTime.now().year, DateTime.now().month, 1);
                }),
                child: Text(
                  "${_monthName(_month.month)} ${_month.year}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.chevron_right), onPressed: _nextMonth),
            ],
          ),
          const SizedBox(height: 8),
          HeatmapCalendar(
            completions: aggregated,
            month: _month,
            showTitle: false,
          ),
          const SizedBox(height: 8),
          _legend(context),
          const SizedBox(height: 12),
          if (hs.habits.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Belum ada habit.\nTap + untuk menambahkan.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else ...[
            for (final h in hs.habits)
              Dismissible(
                key: ValueKey(h.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.delete_rounded,
                      color: Theme.of(context).colorScheme.onErrorContainer),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Hapus Habit?'),
                          content:
                              Text('Hapus "${h.name}" beserta riwayatnya?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal')),
                            FilledButton.tonal(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Hapus')),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (_) async {
                  await context.read<HabitsState>().removeHabit(h.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Habit "${h.name}" dihapus')),
                    );
                  }
                },
                child: HabitCard(habit: h),
              ),
          ],
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitPage()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _legend(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall;
    final colors = [
      Colors.lightBlue.shade50,
      Colors.lightBlue.shade100,
      Colors.lightBlue.shade200,
      Colors.lightBlue.shade400,
      Colors.lightBlue.shade700,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: 6,
          children: colors
              .map((c) => Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                        color: c, borderRadius: BorderRadius.circular(4)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        Text(
            'Biru terang: aktivitas sedikit  •  Biru menyala: aktivitas banyak',
            style: textStyle),
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
}

class _SettingsDrawer extends StatelessWidget {
  const _SettingsDrawer(); // hilangkan parameter key

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final writer = context.read<AppSettings>();
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            ListTile(
              title: const Text('Pengaturan'),
              dense: true,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Ikuti Tema Sistem'),
              value: settings.followSystem,
              onChanged: (v) => writer.setFollowSystem(v),
            ),
            if (!settings.followSystem)
              ListTile(
                title: const Text('Mode Gelap'),
                trailing: Switch(
                  value: settings.isDark,
                  onChanged: (v) => writer.setDark(v),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
