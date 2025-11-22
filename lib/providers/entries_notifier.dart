import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/entry.dart';
import '../services/storage_service.dart';

class EntriesState {
  final List<Entry> entries;
  EntriesState(this.entries);
}

class EntriesNotifier extends StateNotifier<EntriesState> {
  EntriesNotifier() : super(EntriesState([]));

  final _uuid = Uuid();

  void setEntries(List<Entry> list) {
    state = EntriesState(List.from(list));
  }

  void delete(String id) {
    state.entries.removeWhere((x) => x.id == id);
    _persist();
    state = EntriesState(List.from(state.entries));
  }

  List<Entry> get all => List.unmodifiable(state.entries);

  void add(Entry e) {
    state.entries.add(e);
    _persist();
    state = EntriesState(List.from(state.entries));
  }

  void update(Entry e) {
    final idx = state.entries.indexWhere((x) => x.id == e.id);
    if (idx >= 0) {
      e.updatedAt = DateTime.now();
      state.entries[idx] = e;
      _persist();
      state = EntriesState(List.from(state.entries));
    }
  }

  void remove(String id) {
    state.entries.removeWhere((x) => x.id == id);
    _persist();
    state = EntriesState(List.from(state.entries));
  }

  Entry createForDate(DateTime date) {
    final id = _uuid.v4();
    final entry = Entry(id: id, date: date, title: '', description: '');
    add(entry);
    return entry;
  }

  // FIXED: Uses the new safe save method
  Future<void> _persist() async {
    final data = state.entries.map((e) => e.toJson()).toList();
    await StorageService.save('entries', data);
  }

  Future<void> loadFromStorage() async {
    final raw = await StorageService.readAll();
    final list =
        (raw['entries'] as List<dynamic>?)
            ?.map((e) => Entry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    state = EntriesState(list);
  }

  Future<void> importEntries(List<Entry> imported) async {
    final existIds = state.entries.map((e) => e.id).toSet();
    for (final e in imported) {
      if (!existIds.contains(e.id)) state.entries.add(e);
    }
    _persist();
    state = EntriesState(List.from(state.entries));
  }
}
