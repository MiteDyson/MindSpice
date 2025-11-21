import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

// 1. Create a state class to hold both theme settings
class ThemeState {
  final bool isDark;
  final String font;

  const ThemeState({this.isDark = false, this.font = 'Roboto'});

  ThemeState copyWith({bool? isDark, String? font}) {
    return ThemeState(isDark: isDark ?? this.isDark, font: font ?? this.font);
  }
}

// 2. Update the Notifier to manage ThemeState instead of bool
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
    if (raw == null) return;

    final themeStr = raw['theme'] as String?;
    final fontStr = raw['font'] as String?;

    state = ThemeState(isDark: themeStr == 'dark', font: fontStr ?? 'Roboto');
  }

  Future<void> _persist() async {
    final raw = await StorageService.readAll() ?? {};
    raw['theme'] = state.isDark ? 'dark' : 'light';
    raw['font'] = state.font;
    await StorageService.writeAll(raw);
  }
}
