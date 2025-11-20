import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    Key? key,
    required this.category,
    this.selected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(category.name),
      selected: selected,
      avatar: CircleAvatar(
        backgroundColor: Color(category.colorValue),
        radius: 6,
      ),
      onSelected: (_) => onTap?.call(),
    );
  }
}
