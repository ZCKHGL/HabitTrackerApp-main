import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'state/app_settings.dart';
import 'state/auth_state.dart';
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
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => HabitsState()),
      ],
      child: Consumer<AppSettings>(
        builder: (_, settings, __) {
          final mode = settings.followSystem
              ? ThemeMode.system
              : (settings.isDark ? ThemeMode.dark : ThemeMode.light);
          return MaterialApp(
  title: 'Habit Tracker',

  locale: settings.locale,

  supportedLocales: const [
    Locale('id'),
    Locale('en'),
    Locale('ar'),
  ],

  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],

  theme: buildLightTheme(),
  darkTheme: buildDarkTheme(),
  themeMode: mode,
  debugShowCheckedModeBanner: false,
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
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (!mounted) return;
    
    final auth = context.read<AuthState>();
    final habits = context.read<HabitsState>();
    
    // Wait for auth to be initialized
    while (!auth.initialized) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
    }
    
    _lastUserId = auth.userId;
    await habits.onUserChanged(auth.userId);
    
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth changes and reload habits
    final auth = context.watch<AuthState>();
    
    // When auth state changes, reload habits for new user (only if userId changed)
    if (_ready && _lastUserId != auth.userId) {
      _lastUserId = auth.userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<HabitsState>().onUserChanged(auth.userId);
        }
      });
    }

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
