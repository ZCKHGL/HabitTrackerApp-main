import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  bool followSystem = true;
  bool isDark = false;

  void setFollowSystem(bool value) {
    followSystem = value;
    notifyListeners();
  }

  void setDark(bool value) {
    isDark = value;
    notifyListeners();
  }
}
