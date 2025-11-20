import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class ThemeNotifier extends StateNotifier<bool> {
  // true = dark, false = light
  ThemeNotifier() : super(false);

  void setDark(bool v) {
    state = v;
    _persist();
  }

  Future<void> loadFromStorage() async {
    final raw = await StorageService.readAll();
    final theme = raw?['theme'] as String?;
    if (theme != null) {
      state = (theme == 'dark');
    }
  }

  Future<void> _persist() async {
    final raw = await StorageService.readAll() ?? {};
    raw['theme'] = state ? 'dark' : 'light';
    await StorageService.writeAll(raw);
  }
}
