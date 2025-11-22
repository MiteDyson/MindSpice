import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import '../models/entry.dart';
import '../models/category.dart';

// Export entries + categories in a simple CSV format:
// We'll produce two CSVs concatenated with a header marker.

String exportToCsv(List<Entry> entries, List<CategoryModel> categories) {
  // Categories CSV
  final catRows = [
    ['id', 'name', 'colorValue'],
    ...categories.map((c) => [c.id, c.name, c.colorValue.toString()]),
  ];

  final entryRows = [
    [
      'id',
      'date',
      'title',
      'description',
      'categories',
      'createdAt',
      'updatedAt',
    ],
    ...entries.map(
      (e) => [
        e.id,
        e.date.toIso8601String(),
        e.title,
        e.description.replaceAll('\n', '\\n'),
        e.categories.join(';'),
        e.createdAt.toIso8601String(),
        e.updatedAt.toIso8601String(),
      ],
    ),
  ];

  final csvCat = const ListToCsvConverter().convert(catRows);
  final csvEntries = const ListToCsvConverter().convert(entryRows);

  // simple concatenation with marker
  return '---CATEGORIES---\n$csvCat\n---ENTRIES---\n$csvEntries';
}

// Import: simple parser that splits by marker
Map<String, dynamic> importFromCsv(String text) {
  // FIX: Use \r?\n to handle both Windows (\r\n) and Linux (\n) newlines
  final parts =
      text
          .split(RegExp(r'---CATEGORIES---\r?\n|---ENTRIES---\r?\n'))
          .where((s) => s.trim().isNotEmpty)
          .toList();

  List<CategoryModel> cats = [];
  List<Entry> entries = [];

  if (parts.isNotEmpty) {
    final catCsv = parts[0];
    // FIX: Handle potentially malformed CSV lines
    try {
      final catRows = const CsvToListConverter().convert(catCsv, eol: '\n');
      // Skip header row (index 0), start from 1
      if (catRows.length > 1) {
        for (var i = 1; i < catRows.length; i++) {
          final r = catRows[i];
          if (r.length < 3) continue; // Safety check

          // FIX: Safe integer parsing for color
          int colorVal;
          try {
            colorVal = int.parse(r[2].toString().trim());
          } catch (_) {
            colorVal = 0xFF9E9E9E; // Fallback gray
          }

          cats.add(
            CategoryModel(
              id: r[0].toString().trim(),
              name: r[1].toString().trim(),
              colorValue: colorVal,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error parsing categories: $e");
    }
  }

  if (parts.length > 1) {
    final entryCsv = parts[1];
    try {
      final entryRows = const CsvToListConverter().convert(entryCsv, eol: '\n');
      // Skip header row
      if (entryRows.length > 1) {
        for (var i = 1; i < entryRows.length; i++) {
          final r = entryRows[i];
          if (r.length < 7) continue; // Safety check

          entries.add(
            Entry(
              id: r[0].toString().trim(),
              date: DateTime.tryParse(r[1].toString().trim()) ?? DateTime.now(),
              title: r[2].toString().trim(),
              description: r[3].toString().replaceAll('\\n', '\n').trim(),
              categories:
                  r[4].toString().trim().isEmpty
                      ? []
                      : r[4].toString().trim().split(';'),
              createdAt:
                  DateTime.tryParse(r[5].toString().trim()) ?? DateTime.now(),
              updatedAt:
                  DateTime.tryParse(r[6].toString().trim()) ?? DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error parsing entries: $e");
    }
  }

  return {'categories': cats, 'entries': entries};
}
