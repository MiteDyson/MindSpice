import 'package:flutter/material.dart';
import '../models/entry.dart';

class EntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback? onTap;

  const EntryCard({Key? key, required this.entry, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        title: Text(
          entry.title.isEmpty ? '<Untitled>' : entry.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          entry.description.isEmpty ? 'No content' : entry.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
      ),
    );
  }
}
