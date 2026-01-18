import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  bool followSystem = true;
  bool isDark = false;

  Locale _locale = const Locale('id');
  Locale get locale => _locale;

  void setFollowSystem(bool value) {
    followSystem = value;
    notifyListeners();
  }

  void setDark(bool value) {
    isDark = value;
    notifyListeners();
  }

  void setLocale(Locale value) {
    _locale = value;
    notifyListeners();
  }
}
