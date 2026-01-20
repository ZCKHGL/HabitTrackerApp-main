import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../state/app_settings.dart';
import '../state/auth_state.dart';
import '../state/habits_state.dart';
import '../widgets/heatmap_calendar.dart';
import '../widgets/habit_card.dart';
import 'add_habit_page.dart';
import 'analytics_page.dart';
import 'history_page.dart';
import 'login_page.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final hs = context.watch<HabitsState>();
    final aggregated = hs.aggregatedCompletions();
    final goodCompletions = hs.aggregatedGoodCompletions();
    final badCompletions = hs.aggregatedBadCompletions();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsPage()),
              );
            },
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: l10n.analytics,
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
            icon: const Icon(Icons.history_rounded),
            tooltip: l10n.history,
          ),
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              icon: const Icon(Icons.settings_rounded),
              tooltip: l10n.settings,
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
            goodCompletions: goodCompletions,
            badCompletions: badCompletions,
            month: _month,
            showTitle: false,
            habits: hs.habits, // Pass habits untuk detail
          ),
          const SizedBox(height: 8),
          _legend(context),
          const SizedBox(height: 12),
          if (hs.habits.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  l10n.emptyHabit,
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
                          title: Text(l10n.deleteHabit),
                          content: Text(l10n.deleteConfirm(h.name)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel)),
                            FilledButton.tonal(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(l10n.delete)),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (_) async {
                  await context.read<HabitsState>().removeHabit(h.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.habitDeleted(h.name))),
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
        label: Text(l10n.add),
      ),
    );
  }

  Widget _legend(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textStyle = Theme.of(context).textTheme.labelSmall;

    // Good habits: light blue to dark blue
    final goodColors = [
      const Color(0xFFE3F2FD), // Light blue
      const Color(0xFF90CAF9),
      const Color(0xFF42A5F5),
      const Color(0xFF1E88E5),
      const Color(0xFF1565C0), // Dark blue
    ];

    // Bad habits: light red to dark red
    final badColors = [
      const Color(0xFFFFEBEE), // Light red
      const Color(0xFFEF9A9A),
      const Color(0xFFEF5350),
      const Color(0xFFE53935),
      const Color(0xFFC62828), // Dark red
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Good habits legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 14, color: Colors.blue.shade700),
            const SizedBox(width: 4),
            Text('Good: ',
                style: textStyle?.copyWith(fontWeight: FontWeight.bold)),
            ...goodColors.map((c) => Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 6),
        // Bad habits legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined, size: 14, color: Colors.red.shade700),
            const SizedBox(width: 4),
            Text('Bad: ',
                style: textStyle?.copyWith(fontWeight: FontWeight.bold)),
            ...badColors.map((c) => Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 4),
        Text('${l10n.lightActivity}  →  ${l10n.highActivity}',
            style: textStyle),
      ],
    );
  }

  String _monthName(int m) {
    final l10n = AppLocalizations.of(context)!;
    const names = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december'
    ];
    final monthKey = names[m - 1];

    // Get month name based on locale
    switch (monthKey) {
      case 'january':
        return l10n.january;
      case 'february':
        return l10n.february;
      case 'march':
        return l10n.march;
      case 'april':
        return l10n.april;
      case 'may':
        return l10n.may;
      case 'june':
        return l10n.june;
      case 'july':
        return l10n.july;
      case 'august':
        return l10n.august;
      case 'september':
        return l10n.september;
      case 'october':
        return l10n.october;
      case 'november':
        return l10n.november;
      case 'december':
        return l10n.december;
      default:
        return '';
    }
  }
}

class _SettingsDrawer extends StatelessWidget {
  const _SettingsDrawer(); // hilangkan parameter key

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<AppSettings>();
    final writer = context.read<AppSettings>();
    final auth = context.watch<AuthState>();
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            // Account Section Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary,
                    child: auth.isLoggedIn
                        ? Text(
                            auth.displayName[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : Icon(
                            Icons.person_outline,
                            size: 30,
                            color: theme.colorScheme.onPrimary,
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.isLoggedIn ? auth.displayName : l10n.guest,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (auth.isLoggedIn && auth.email != null)
                    Text(
                      auth.email!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (!auth.isLoggedIn)
                    Text(
                      l10n.guestDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),

            // Login/Logout Button
            if (auth.isLoggedIn)
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l10n.logout),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l10n.logout),
                      content: Text(l10n.logoutConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        FilledButton.tonal(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.logout),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await auth.signOut();
                    // Reload habits for guest user
                    if (context.mounted) {
                      await context.read<HabitsState>().onUserChanged('guest');
                      Navigator.pop(context); // Close drawer
                    }
                  }
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.login),
                title: Text(l10n.login),
                subtitle: Text(l10n.loginSubtitleShort),
                onTap: () async {
                  Navigator.pop(context); // Close drawer first
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                  if (result == true && context.mounted) {
                    // Reload habits for new user
                    final newAuth = context.read<AuthState>();
                    await context
                        .read<HabitsState>()
                        .onUserChanged(newAuth.userId);
                  }
                },
              ),

            const Divider(),
            ListTile(
              title: Text(l10n.settings),
              dense: true,
            ),
            SwitchListTile(
              title: Text(l10n.followSystem),
              value: settings.followSystem,
              onChanged: (v) => writer.setFollowSystem(v),
            ),
            if (!settings.followSystem)
              ListTile(
                title: Text(l10n.darkMode),
                trailing: Switch(
                  value: settings.isDark,
                  onChanged: (v) => writer.setDark(v),
                ),
              ),
            ListTile(
              title: Text(l10n.language),
              trailing: DropdownButton<Locale>(
                value: settings.locale,
                onChanged: (locale) {
                  if (locale != null) {
                    writer.setLocale(locale);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: Locale('id'),
                    child: Text('Indonesia'),
                  ),
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: Locale('ar'),
                    child: Text('العربية'),
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
