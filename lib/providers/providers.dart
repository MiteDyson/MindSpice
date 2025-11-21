import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindspice/models/category.dart';
import 'entries_notifier.dart';
import 'categories_notifier.dart';
import 'theme_notifier.dart';

final entriesProvider = StateNotifierProvider<EntriesNotifier, EntriesState>(
  (ref) => EntriesNotifier(),
);

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
      (ref) => CategoriesNotifier(),
    );

// UPDATED: Now returns ThemeState instead of bool
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
