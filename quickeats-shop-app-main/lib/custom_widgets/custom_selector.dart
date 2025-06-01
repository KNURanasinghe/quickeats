import 'package:flutter/material.dart';

class CustomSelector extends StatelessWidget {
  final String selectedCategory;
  final List<String> categoryList;
  final Function(String) onCategoryChanged;
final String titleText;
  const CustomSelector({
    super.key,
    required this.selectedCategory,
    required this.categoryList,
    required this.onCategoryChanged,
    required this.titleText
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      isExpanded: true,
      validator: (value) {
        if (selectedCategory.isEmpty) {
          return "Please select";
        }
        return null;
      },
      value: selectedCategory.isEmpty ? null : selectedCategory,
      items: categoryList.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onCategoryChanged(value);
        }
      },
      decoration:  InputDecoration(labelText: titleText),
    );
  }
}
