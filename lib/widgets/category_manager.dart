import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';

class CategoryManager extends ConsumerWidget {
  const CategoryManager({super.key});

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    Color selectedColor = Colors.indigo;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('New Category'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Name',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children:
                            [
                              Colors.indigo,
                              Colors.blue,
                              Colors.teal,
                              Colors.green,
                              Colors.amber,
                              Colors.deepOrange,
                              Colors.purple,
                              Colors.pink,
                            ].map((c) {
                              return GestureDetector(
                                onTap:
                                    () =>
                                        setDialogState(() => selectedColor = c),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:
                                        selectedColor == c
                                            ? Border.all(
                                              color: Colors.grey,
                                              width: 2,
                                            )
                                            : null,
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: c,
                                    radius: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          ref
                              .read(categoriesProvider.notifier)
                              .create(controller.text, selectedColor.value);
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showAddDialog(context, ref),
                  tooltip: "Add Category",
                ),
              ],
            ),
            if (categories.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "No categories yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  categories
                      .map(
                        (c) => InputChip(
                          label: Text(c.name),
                          labelStyle: TextStyle(
                            color: Color(c.colorValue),
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: Color(c.colorValue).withOpacity(0.1),
                          deleteIconColor: Color(c.colorValue),
                          onDeleted:
                              () => ref
                                  .read(categoriesProvider.notifier)
                                  .remove(c.id),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
