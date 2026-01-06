import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const seed = Color(0xFF1E88E5);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(centerTitle: true),
    listTileTheme: const ListTileThemeData(visualDensity: VisualDensity.comfortable),
  );
}

ThemeData buildDarkTheme() {
  const seed = Color(0xFF90CAF9);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true),
    listTileTheme: const ListTileThemeData(visualDensity: VisualDensity.comfortable),
  );
}
