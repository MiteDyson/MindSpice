import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

class CategoriesNotifier extends StateNotifier<List<CategoryModel>> {
  CategoriesNotifier() : super([]);

  final _uuid = Uuid();

  List<CategoryModel> get all => state;

  void setAll(List<CategoryModel> list) => state = List.from(list);

  CategoryModel create(String name, int colorValue) {
    final c = CategoryModel(id: _uuid.v4(), name: name, colorValue: colorValue);
    state = [...state, c];
    _persist();
    return c;
  }

  void update(String id, String newName, int newColor) {
    state = [
      for (final c in state)
        if (c.id == id)
          CategoryModel(id: id, name: newName, colorValue: newColor)
        else
          c,
    ];
    _persist();
  }

  void remove(String id) {
    state = state.where((c) => c.id != id).toList();
    _persist();
  }

  // FIXED: Uses the new safe save method
  void _persist() async {
    final data = state.map((c) => c.toJson()).toList();
    await StorageService.save('categories', data);
  }

  Future<void> loadFromStorage() async {
    final raw = await StorageService.readAll();
    final data =
        (raw['categories'] as List<dynamic>?)
            ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    state = data;
  }
}
