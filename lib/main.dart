import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_settings.dart';
import 'state/habits_state.dart';
import 'theme.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettings()),
        ChangeNotifierProvider(create: (_) => HabitsState()),
      ],
      child: Consumer<AppSettings>(
        builder: (_, settings, __) {
          final mode = settings.followSystem
              ? ThemeMode.system
              : (settings.isDark ? ThemeMode.dark : ThemeMode.light);
          return MaterialApp(
            title: 'Habit Tracker',
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: mode,
            debugShowCheckedModeBanner: false,
            // ganti langsung HomePage dengan AppRoot (splash singkat)
            home: const _AppRoot(),
          );
        },
      ),
    );
  }
}

// Splash ringan agar tidak tampak blank saat init di web
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    return const HomePage();
  }
}
