import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import '../models/entry.dart';
import '../models/category.dart';

String exportToCsv(List<Entry> entries, List<CategoryModel> categories) {
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

  return '---CATEGORIES---\n$csvCat\n---ENTRIES---\n$csvEntries';
}

Map<String, dynamic> importFromCsv(String text) {
  // FIX: Updated Regex to handle commas or whitespace after the marker
  // Matches: ---CATEGORIES--- followed by anything until a newline
  final splitPattern = RegExp(
    r'---CATEGORIES---.*(?:\r?\n|\r)|---ENTRIES---.*(?:\r?\n|\r)',
  );

  // We split manually to keep track of which part is which
  final parts = text.split(splitPattern);

  // The split usually results in [ "", "category_data", "entry_data" ]
  // We filter out empty parts
  final validParts = parts.where((s) => s.trim().isNotEmpty).toList();

  List<CategoryModel> cats = [];
  List<Entry> entries = [];

  // Process Categories (usually the first valid part)
  if (validParts.isNotEmpty) {
    final catCsv = validParts[0];
    try {
      final catRows = const CsvToListConverter().convert(catCsv, eol: '\n');
      // Skip header row
      if (catRows.length > 1) {
        for (var i = 1; i < catRows.length; i++) {
          final r = catRows[i];
          if (r.length < 3) continue;

          int colorVal;
          try {
            // Handle scientific notation or large ints if Excel messed them up
            final valStr = r[2].toString().trim();
            if (valStr.contains('E')) {
              colorVal = double.parse(valStr).toInt();
            } else {
              colorVal = int.parse(valStr);
            }
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

  // Process Entries (usually the second valid part)
  if (validParts.length > 1) {
    final entryCsv = validParts[1];
    try {
      final entryRows = const CsvToListConverter().convert(entryCsv, eol: '\n');
      if (entryRows.length > 1) {
        for (var i = 1; i < entryRows.length; i++) {
          final r = entryRows[i];
          if (r.length < 7) continue;

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
