import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class ThemeState {
  final bool isDark;
  final String font;

  const ThemeState({this.isDark = false, this.font = 'Roboto'});

  ThemeState copyWith({bool? isDark, String? font}) {
    return ThemeState(isDark: isDark ?? this.isDark, font: font ?? this.font);
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState());

  void setDark(bool v) {
    state = state.copyWith(isDark: v);
    _persist();
  }

  void setFont(String fontName) {
    state = state.copyWith(font: fontName);
    _persist();
  }

  Future<void> loadFromStorage() async {
    final raw = await StorageService.readAll();
    final themeStr = raw['theme'] as String?;
    final fontStr = raw['font'] as String?;

    state = ThemeState(isDark: themeStr == 'dark', font: fontStr ?? 'Roboto');
  }

  // FIXED: Uses the new safe save method
  Future<void> _persist() async {
    // We save these as separate keys or a map, sticking to your existing structure:
    await StorageService.save('theme', state.isDark ? 'dark' : 'light');
    await StorageService.save('font', state.font);
  }
}
