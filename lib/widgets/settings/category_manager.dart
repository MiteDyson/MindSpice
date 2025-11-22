import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/category.dart'; // Need this for the model type

class CategoryManager extends ConsumerWidget {
  const CategoryManager({super.key});

  // Unified dialog for both Creating and Editing
  void _showDialog(
    BuildContext context,
    WidgetRef ref, {
    CategoryModel? category,
  }) {
    final isEditing = category != null;
    final controller = TextEditingController(
      text: isEditing ? category.name : '',
    );
    // Default to Indigo for new, or existing color for edit
    Color selectedColor =
        isEditing ? Color(category.colorValue) : Colors.indigo;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(isEditing ? 'Edit Category' : 'New Category'),
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
                              Colors.grey,
                              Colors
                                  .black, // Added Black/Grey for "Skipped" styles
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
                                        selectedColor.value == c.value
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
                          if (isEditing) {
                            // Update existing
                            ref
                                .read(categoriesProvider.notifier)
                                .update(
                                  category.id,
                                  controller.text,
                                  selectedColor.value,
                                );
                          } else {
                            // Create new
                            ref
                                .read(categoriesProvider.notifier)
                                .create(controller.text, selectedColor.value);
                          }
                          Navigator.pop(ctx);
                        }
                      },
                      child: Text(isEditing ? 'Save' : 'Add'),
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
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                  onPressed:
                      () => _showDialog(context, ref), // Open Create Dialog
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
                          backgroundColor: Color(
                            c.colorValue,
                          ).withValues(alpha: 0.1),
                          deleteIconColor: Color(c.colorValue),
                          onDeleted:
                              () => ref
                                  .read(categoriesProvider.notifier)
                                  .remove(c.id),
                          // ADDED: Tap to Edit
                          onPressed:
                              () => _showDialog(context, ref, category: c),
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
