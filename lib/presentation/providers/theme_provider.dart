import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/datasources/local_storage_service.dart';
import '../../core/di/injection_container.dart';
import '../../core/theme/app_theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AuraThemeMode>((ref) {
  return ThemeNotifier(sl<LocalStorageService>());
});

class ThemeNotifier extends StateNotifier<AuraThemeMode> {
  final LocalStorageService _storage;

  ThemeNotifier(this._storage) : super(AuraThemeMode.aura) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = _storage.getTheme();
    if (savedTheme != null) {
      if (savedTheme == 'spotify') {
        state = AuraThemeMode.spotify;
      } else if (savedTheme == 'sunset') {
        state = AuraThemeMode.sunset;
      } else {
        state = AuraThemeMode.aura;
      }
    }
  }

  void setTheme(AuraThemeMode mode) {
    state = mode;
    String themeString;
    switch (mode) {
      case AuraThemeMode.aura:
        themeString = 'aura';
        break;
      case AuraThemeMode.spotify:
        themeString = 'spotify';
        break;
      case AuraThemeMode.sunset:
        themeString = 'sunset';
        break;
    }
    _storage.saveTheme(themeString);
  }



  void toggleTheme() {
    switch (state) {
      case AuraThemeMode.aura:
        setTheme(AuraThemeMode.spotify);
        break;
      case AuraThemeMode.spotify:
        setTheme(AuraThemeMode.sunset);
        break;
      case AuraThemeMode.sunset:
        setTheme(AuraThemeMode.aura);
        break;
    }
  }
}
