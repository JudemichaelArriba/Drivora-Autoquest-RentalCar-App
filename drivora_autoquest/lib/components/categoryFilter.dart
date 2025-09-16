import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryButton("All", selectedCategory, onCategorySelected),
            ...categories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: _buildCategoryButton(
                  category,
                  selectedCategory,
                  onCategorySelected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    String category,
    String selectedCategory,
    Function(String) onSelected,
  ) {
    final isSelected = category == selectedCategory;
    return GestureDetector(
      onTap: () => onSelected(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFCC5500),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFFF7A30)),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFF7A30) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
