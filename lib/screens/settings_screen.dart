import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../providers/providers.dart';
import '../services/csv_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  Color _selectedColor = Colors.indigo;

  // secret tap tracking
  int _titleTapCount = 0;
  bool _showSecretLock = false;

  // simple palette
  final List<Color> _palette = const [
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.amber,
    Colors.deepOrange,
    Colors.purple,
    Colors.pink,
    Colors.grey,
    Colors.brown,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ---------- export / import (unchanged) ----------
  Future<void> _exportAll(WidgetRef ref, BuildContext context) async {
    try {
      final entries = ref.read(entriesProvider).entries;
      final cats = ref.read(categoriesProvider);
      final csv = exportToCsv(entries, cats);

      final raw = await FilePicker.platform.getDirectoryPath() ?? '';
      if (raw.isEmpty) {
        await showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Export CSV (Preview)'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(child: SelectableText(csv)),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: csv));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('CSV copied to clipboard'),
                        ),
                      );
                    },
                    child: const Text('Copy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
        );
        return;
      }

      final path =
          '$raw/mindspice_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final f = File(path);
      await f.writeAsString(csv, flush: true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exported to $path')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _importAll(WidgetRef ref, BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );
      if (result == null) return;
      final content = String.fromCharCodes(
        result.files.single.bytes ??
            await File(result.files.single.path!).readAsBytes(),
      );
      final parsed = importFromCsv(content);
      final cats = parsed['categories'] as List;
      final entries = parsed['entries'] as List;

      for (final c in cats) {
        final exists = ref
            .read(categoriesProvider)
            .any((x) => x.name == c.name);
        if (!exists) {
          ref.read(categoriesProvider.notifier).create(c.name, c.colorValue);
        }
      }
      await ref.read(entriesProvider.notifier).importEntries(entries.cast());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Import completed')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  // ---------- categories editing (unchanged) ----------
  Future<void> _showEditCategoryDialog(
    WidgetRef ref,
    BuildContext context,
    dynamic cat,
  ) async {
    final nameController = TextEditingController(text: cat.name);
    Color tmpColor = Color(cat.colorValue);

    await showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Text('Edit Category'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children:
                            _palette.map((c) {
                              final selected = c.value == tmpColor.value;
                              return GestureDetector(
                                onTap: () => setStateDialog(() => tmpColor = c),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  padding:
                                      selected
                                          ? const EdgeInsets.all(3)
                                          : EdgeInsets.zero,
                                  decoration:
                                      selected
                                          ? BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              width: 2,
                                            ),
                                          )
                                          : null,
                                  child: CircleAvatar(
                                    backgroundColor: c,
                                    radius: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final newName = nameController.text.trim();
                        if (newName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Name can not be empty'),
                            ),
                          );
                          return;
                        }
                        final _catNotifierDyn =
                            ref.read(categoriesProvider.notifier) as dynamic;
                        try {
                          _catNotifierDyn.update(
                            cat.id,
                            newName,
                            tmpColor.value,
                          );
                        } catch (e) {
                          ref.read(categoriesProvider.notifier).remove(cat.id);
                          ref
                              .read(categoriesProvider.notifier)
                              .create(newName, tmpColor.value);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _confirmDelete(
    WidgetRef ref,
    BuildContext context,
    dynamic cat,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete category?'),
            content: Text(
              'Are you sure you want to delete "${cat.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (ok == true) {
      ref.read(categoriesProvider.notifier).remove(cat.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted "${cat.name}"')));
    }
  }

  void _addCategory(dynamic catNotifier) {
    final t = _nameCtrl.text.trim();
    if (t.isEmpty) return;
    catNotifier.create(t, _selectedColor.value);
    _nameCtrl.clear();
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added category "$t"')));
  }

  // ---------- secret/wipe helpers ----------
  Future<Directory> _appDocDir() async =>
      await getApplicationDocumentsDirectory();

  /// delete exported CSV files starting with mindspice_export_
  Future<int> _deleteExportedFiles() async {
    try {
      final dir = await _appDocDir();
      final files = dir.listSync().whereType<File>().toList();
      int deleted = 0;
      for (final f in files) {
        final name =
            f.uri.pathSegments.isNotEmpty ? f.uri.pathSegments.last : f.path;
        if (name.startsWith('mindspice_export_')) {
          try {
            await f.delete();
            deleted++;
          } catch (_) {
            // continue
          }
        }
      }
      return deleted;
    } catch (_) {
      return 0;
    }
  }

  /// wipe app data: delete all entries and categories from providers
  Future<void> _wipeAppData() async {
    final entries = ref.read(entriesProvider).entries;
    final cats = ref.read(categoriesProvider);
    final entriesNotifier = ref.read(entriesProvider.notifier);
    final catsNotifier = ref.read(categoriesProvider.notifier);

    // delete entries
    for (final e in entries.toList()) {
      try {
        entriesNotifier.delete(e.id);
      } catch (_) {}
    }
    // delete categories
    for (final c in cats.toList()) {
      try {
        catsNotifier.remove(c.id);
      } catch (_) {}
    }
  }

  Future<void> _showSecretMenu() async {
    final refLocal = ref; // capture
    await showModalBottomSheet(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Delete all app data'),
                  subtitle: const Text(
                    'Removes all entries and categories (irreversible)',
                  ),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) {
                        final TextEditingController confirmCtrl =
                            TextEditingController();
                        return AlertDialog(
                          title: const Text('Confirm wipe all data'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Type DELETE to permanently remove all app data (entries & categories).',
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: confirmCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Type DELETE to confirm',
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed:
                                  () => Navigator.of(
                                    context,
                                  ).pop(confirmCtrl.text.trim() == 'DELETE'),
                              child: const Text('Confirm'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed == true) {
                      // perform wipe (best effort)
                      await _wipeAppData();
                      // also wipe exported files optionally
                      final deletedFiles = await _deleteExportedFiles();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'All app data removed. Deleted $deletedFiles export files.',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Wipe cancelled')),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dangerous, color: Colors.orange),
                  title: const Text('Delete exported CSV files'),
                  subtitle: const Text(
                    'Removes exported CSV files created by the app',
                  ),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final deleted = await _deleteExportedFiles();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deleted $deleted export file(s)'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
    );
  }

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final dark = ref.watch(themeProvider);
    final categories = ref.watch(categoriesProvider);
    final catNotifier = ref.read(categoriesProvider.notifier);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            setState(() {
              _titleTapCount++;
              if (_titleTapCount >= 5) _showSecretLock = true;
            });
          },
          child: const Text('Settings'),
        ),
        centerTitle: true,
        elevation: 0.5,
        actions: [
          if (_showSecretLock)
            IconButton(
              icon: const Icon(Icons.lock),
              tooltip: 'Secret actions',
              onPressed: _showSecretMenu,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: Icon(
                  dark ? Icons.dark_mode : Icons.light_mode,
                  size: 28,
                ),
                title: const Text('Theme'),
                subtitle: Text(
                  dark ? 'Dark mode enabled' : 'Light mode enabled',
                ),
                trailing: Switch(
                  value: dark,
                  onChanged: (v) => themeNotifier.setDark(v),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Data Management',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Export or import your CSV data.'),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _exportAll(ref, context),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Export CSV'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _importAll(ref, context),
                            icon: const Icon(Icons.download),
                            label: const Text('Import CSV'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tip: If you cancel export you can copy the CSV to clipboard from the preview.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Category Management',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Create, edit or remove categories used across the app.',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Category name',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _addCategory(catNotifier),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _addCategory(catNotifier),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        const Text('Pick a color:'),
                        ..._palette.map((c) {
                          final selected = c.value == _selectedColor.value;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding:
                                  selected
                                      ? const EdgeInsets.all(3)
                                      : const EdgeInsets.all(0),
                              decoration:
                                  selected
                                      ? BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          width: 2,
                                        ),
                                      )
                                      : null,
                              child: CircleAvatar(
                                backgroundColor: c,
                                radius: 16,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          categories.map((c) {
                            final color = Color(c.colorValue);
                            return InputChip(
                              label: Text(c.name),
                              avatar: CircleAvatar(backgroundColor: color),
                              backgroundColor: color.withOpacity(0.12),
                              onPressed:
                                  () =>
                                      _showEditCategoryDialog(ref, context, c),
                              onDeleted: () => _confirmDelete(ref, context, c),
                              deleteIcon: const Icon(Icons.delete_outline),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'MindSpice • Settings',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
