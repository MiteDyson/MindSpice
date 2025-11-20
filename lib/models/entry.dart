import 'dart:convert';

class Entry {
  String id;
  DateTime date; // date of the entry (use only date portion)
  String title;
  String description;
  List<String> categories; // list of category names
  DateTime createdAt;
  DateTime updatedAt;

  Entry({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    List<String>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : categories = categories ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Entry.fromJson(Map<String, dynamic> j) => Entry(
    id: j['id'] as String,
    date: DateTime.parse(j['date'] as String),
    title: j['title'] as String? ?? '',
    description: j['description'] as String? ?? '',
    categories: (j['categories'] as List<dynamic>?)?.cast<String>() ?? [],
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'title': title,
    'description': description,
    'categories': categories,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());
}
