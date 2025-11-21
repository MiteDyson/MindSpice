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
  final parts =
      text
          .split(RegExp(r'---CATEGORIES---\n|---ENTRIES---\n'))
          .where((s) => s.trim().isNotEmpty)
          .toList();
  List<CategoryModel> cats = [];
  List<Entry> entries = [];

  if (parts.isNotEmpty) {
    final catCsv = parts[0];
    final catRows = const CsvToListConverter().convert(catCsv);
    // Skip header row (index 0), start from 1
    if (catRows.length > 1) {
      for (var i = 1; i < catRows.length; i++) {
        final r = catRows[i];
        cats.add(
          CategoryModel(
            id: r[0].toString(),
            name: r[1].toString(),
            colorValue: int.parse(r[2].toString()),
          ),
        );
      }
    }
  }

  if (parts.length > 1) {
    final entryCsv = parts[1];
    final entryRows = const CsvToListConverter().convert(entryCsv);
    // Skip header row
    if (entryRows.length > 1) {
      for (var i = 1; i < entryRows.length; i++) {
        final r = entryRows[i];
        entries.add(
          Entry(
            id: r[0].toString(),
            date: DateTime.parse(r[1].toString()),
            title: r[2].toString(),
            description: r[3].toString().replaceAll('\\n', '\n'),
            categories:
                r[4].toString().isEmpty ? [] : r[4].toString().split(';'),
            createdAt: DateTime.parse(r[5].toString()),
            updatedAt: DateTime.parse(r[6].toString()),
          ),
        );
      }
    }
  }

  return {'categories': cats, 'entries': entries};
}
