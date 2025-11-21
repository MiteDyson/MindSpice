import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/providers.dart';
import '../../services/csv_service.dart';

class DataManager extends ConsumerWidget {
  const DataManager({super.key});

  Future<void> _saveToFile(BuildContext context, WidgetRef ref) async {
    try {
      // 1. Generate CSV Data
      final entries = ref.read(entriesProvider).entries;
      final cats = ref.read(categoriesProvider);
      final csv = exportToCsv(entries, cats);

      // 2. Create a filename
      final fileName =
          'mindspice_export_${DateTime.now().millisecondsSinceEpoch}.csv';

      // 3. Pick Directory (Platform specific)
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        // User canceled the picker
        return;
      }

      // 4. Write File
      final path = '$selectedDirectory/$fileName';
      final file = File(path);
      await file.writeAsString(csv);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to: $path'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                // Optional: Logic to open file could go here if using open_file package
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save file: $e')));
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context, WidgetRef ref) async {
    final entries = ref.read(entriesProvider).entries;
    final cats = ref.read(categoriesProvider);
    final csv = exportToCsv(entries, cats);

    await Clipboard.setData(ClipboardData(text: csv));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CSV copied to clipboard!')));
    }
  }

  Future<void> _importAll(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Allow any file type to avoid extension issues
      );
      if (result == null) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final parsed = importFromCsv(content);

      final cats = parsed['categories'] as List;
      final entries = parsed['entries'] as List;

      // Import Categories
      final catNotifier = ref.read(categoriesProvider.notifier);
      final currentCats = ref.read(categoriesProvider);
      for (final c in cats) {
        if (!currentCats.any((x) => x.name == c.name)) {
          catNotifier.create(c.name, c.colorValue);
        }
      }
      // Import Entries
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
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Export to File'),
            subtitle: const Text('Save CSV to device storage'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _saveToFile(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy to Clipboard'),
            subtitle: const Text('Copy CSV data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _copyToClipboard(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from backup'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _importAll(context, ref),
          ),
        ],
      ),
    );
  }
}
