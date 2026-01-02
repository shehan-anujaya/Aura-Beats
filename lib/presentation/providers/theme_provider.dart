import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage_service.dart';
import '../../core/di/injection_container.dart';

enum AuraThemeMode { aura, spotify }

final themeProvider = StateNotifierProvider<ThemeNotifier, AuraThemeMode>((ref) {
  return ThemeNotifier(sl<LocalStorageService>());
});

class ThemeNotifier extends StateNotifier<AuraThemeMode> {
  final LocalStorageService _storage;
  static const String _themeKey = 'preferred_theme';

  ThemeNotifier(this._storage) : super(AuraThemeMode.aura) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = _storage.get(_themeKey);
    if (savedTheme != null) {
      state = savedTheme == 'spotify' ? AuraThemeMode.spotify : AuraThemeMode.aura;
    }
  }

  void toggleTheme() {
    state = state == AuraThemeMode.aura ? AuraThemeMode.spotify : AuraThemeMode.aura;
    _storage.save(_themeKey, state == AuraThemeMode.spotify ? 'spotify' : 'aura');
  }
}
