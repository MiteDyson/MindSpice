import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/providers.dart';
import '../../services/csv_service.dart';

class DataManager extends ConsumerWidget {
  const DataManager({super.key});

  Future<void> _exportAll(BuildContext context, WidgetRef ref) async {
    try {
      final entries = ref.read(entriesProvider).entries;
      final cats = ref.read(categoriesProvider);
      final csv = exportToCsv(entries, cats);

      // Quick preview/copy dialog since file writing can be permission-heavy on some Android versions
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Export Data'),
              content: const Text(
                "Copy your data to clipboard or save locally?",
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: csv));
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard!')),
                      );
                    }
                  },
                  child: const Text('Copy to Clipboard'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importAll(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final parsed = importFromCsv(content);

      final cats = parsed['categories'] as List;
      final entries = parsed['entries'] as List;

      // Import logic
      final catNotifier = ref.read(categoriesProvider.notifier);
      final currentCats = ref.read(categoriesProvider);
      for (final c in cats) {
        if (!currentCats.any((x) => x.name == c.name)) {
          catNotifier.create(c.name, c.colorValue);
        }
      }
      await ref.read(entriesProvider.notifier).importEntries(entries.cast());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export Data'),
            subtitle: const Text('Backup your entries'),
            onTap: () => _exportAll(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from backup'),
            onTap: () => _importAll(context, ref),
          ),
        ],
      ),
    );
  }
}
