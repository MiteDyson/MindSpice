import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:mindspice/models/category.dart';
import '../providers/providers.dart';
import '../models/entry.dart';
import '../screens/edit_entry_screen.dart';
import '../screens/create_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String query = '';
  String selectedCategory = 'ALL';
  bool isSearching = false;

  final Set<String> _selectedIds = {};
  bool get selectionMode => _selectedIds.isNotEmpty;

  void _clearSelection() => setState(() => _selectedIds.clear());

  void _toggleSelection(String id) => setState(() {
    if (_selectedIds.contains(id))
      _selectedIds.remove(id);
    else
      _selectedIds.add(id);
  });

  String _relativeDateLabel(DateTime d) {
    final today = DateTime.now();
    final a = DateTime(today.year, today.month, today.day);
    final b = DateTime(d.year, d.month, d.day);
    final diff = a.difference(b).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat.EEEE().format(d);
    return DateFormat.yMMMd().format(d);
  }

  Future<void> _deleteEntriesWithUndo(
    BuildContext context,
    List<Entry> toDelete,
  ) async {
    if (toDelete.isEmpty) return;
    final ids = toDelete.map((e) => e.id).toList();
    final notifier = ref.read(entriesProvider.notifier);
    for (final id in ids) notifier.delete(id);
    _clearSelection();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deleted ${toDelete.length} entr${toDelete.length == 1 ? 'y' : 'ies'}',
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            for (final e in toDelete) ref.read(entriesProvider.notifier).add(e);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesState = ref.watch(entriesProvider);
    final categories = ref.watch(categoriesProvider);
    final allEntries = entriesState.entries;

    final q = query.toLowerCase();
    List<Entry> filtered =
        allEntries.where((e) {
          if (selectedCategory != 'ALL' &&
              !e.categories.contains(selectedCategory))
            return false;
          if (q.isEmpty) return true;
          return e.title.toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q) ||
              e.categories.any((c) => c.toLowerCase().contains(q));
        }).toList();

    final Map<String, List<Entry>> grouped = {};
    for (var e in filtered) {
      final key = DateFormat('yyyy-MM-dd').format(e.date);
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    PreferredSizeWidget buildAppBar() {
      if (selectionMode) {
        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _clearSelection,
            tooltip: 'Clear selection',
          ),
          title: Text('${_selectedIds.length} selected'),
          actions: [
            IconButton(
              tooltip:
                  _selectedIds.length == filtered.length
                      ? 'Deselect all'
                      : 'Select all',
              icon: Icon(
                _selectedIds.isEmpty
                    ? Icons.check_box_outline_blank
                    : _selectedIds.length == filtered.length
                    ? Icons.check_box
                    : Icons.indeterminate_check_box,
              ),
              onPressed: () {
                setState(() {
                  if (_selectedIds.length == filtered.length)
                    _selectedIds.clear();
                  else
                    _selectedIds.addAll(filtered.map((e) => e.id));
                });
              },
            ),
            IconButton(
              tooltip: 'Delete selected',
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                final toDelete =
                    allEntries
                        .where((e) => _selectedIds.contains(e.id))
                        .toList();
                _deleteEntriesWithUndo(context, toDelete);
              },
            ),
          ],
        );
      }

      if (isSearching) {
        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed:
                () => setState(() {
                  isSearching = false;
                  query = '';
                }),
            tooltip: 'Back',
          ),
          title: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search entries...',
              border: InputBorder.none,
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          actions: [
            if (query.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => query = ''),
                tooltip: 'Clear',
              ),
          ],
        );
      }

      return AppBar(
        title: const Text('MindSpice'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => setState(() => isSearching = true),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.grey,
            height: 1,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: buildAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // push CreateScreen, which will replace itself with the editor
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (!isSearching && !selectionMode)
            SizedBox(
              height: 64,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  ChoiceChip(
                    label: const Text('ALL'),
                    selected: selectedCategory == 'ALL',
                    onSelected: (_) => setState(() => selectedCategory = 'ALL'),
                  ),
                  ...categories.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ChoiceChip(
                        avatar: CircleAvatar(
                          backgroundColor: Color(c.colorValue),
                          radius: 8,
                        ),
                        label: Text(c.name),
                        selected: selectedCategory == c.name,
                        onSelected:
                            (_) => setState(() => selectedCategory = c.name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child:
                grouped.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sticky_note_2,
                              size: 56,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.9),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No entries yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap the + button to create your first note.',
                            ),
                          ],
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 84),
                      itemCount: sortedKeys.length,
                      itemBuilder: (context, idx) {
                        final key = sortedKeys[idx];
                        final list = grouped[key]!;
                        final headerDate = DateTime.parse(key);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 12.0,
                              ),
                              child: Text(
                                '${_relativeDateLabel(headerDate)} • ${DateFormat('MMM dd, yyyy').format(headerDate)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...list.map((e) {
                              final isSelected = _selectedIds.contains(e.id);
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Dismissible(
                                  key: ValueKey(e.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade600,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (_) async {
                                    await _deleteEntriesWithUndo(context, [e]);
                                  },
                                  child: Card(
                                    color:
                                        isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.12)
                                            : null,
                                    child: ListTile(
                                      leading:
                                          selectionMode
                                              ? Checkbox(
                                                value: isSelected,
                                                onChanged:
                                                    (_) =>
                                                        _toggleSelection(e.id),
                                              )
                                              : null,
                                      selected: isSelected,
                                      title: Text(
                                        e.title.isEmpty
                                            ? '<untitled>'
                                            : e.title,
                                      ),
                                      subtitle: Text(
                                        e.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Wrap(
                                        spacing: 6,
                                        children:
                                            e.categories.map((name) {
                                              final cat = categories.firstWhere(
                                                (c) => c.name == name,
                                                orElse:
                                                    () => CategoryModel(
                                                      id: '',
                                                      name: name,
                                                      colorValue: 0xff888888,
                                                    ),
                                              );
                                              return CircleAvatar(
                                                radius: 6,
                                                backgroundColor: Color(
                                                  cat.colorValue,
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                      onTap: () {
                                        if (selectionMode)
                                          _toggleSelection(e.id);
                                        else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => EditEntryScreen(
                                                    entryId: e.id,
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                      onLongPress: () => _toggleSelection(e.id),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
