import 'package:flutter/material.dart';
import '../../services/storage/secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  final SecureStorage _secureStorage;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider({SecureStorage? secureStorage}) 
      : _secureStorage = secureStorage ?? SecureStorage() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadThemeMode() async {
    final savedMode = await _secureStorage.getThemeMode();
    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedMode,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _secureStorage.saveThemeMode(mode.toString());
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      // If system, determine current and toggle
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      if (brightness == Brightness.light) {
        setThemeMode(ThemeMode.dark);
      } else {
        setThemeMode(ThemeMode.light);
      }
    }
  }
}