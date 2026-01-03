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
      state = savedTheme == 'spotify' ? AuraThemeMode.spotify : AuraThemeMode.aura;
    }
  }

  void setTheme(AuraThemeMode mode) {
    state = mode;
    _storage.saveTheme(mode == AuraThemeMode.spotify ? 'spotify' : 'aura');
  }

  void toggleTheme() {
    setTheme(state == AuraThemeMode.aura ? AuraThemeMode.spotify : AuraThemeMode.aura);
  }
}
