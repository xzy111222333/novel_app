import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryPills extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final Function(String) onSelect;
  final VoidCallback? onAdd;

  const CategoryPills({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          ...categories.map((cat) {
            final isSelected = cat == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => onSelect(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected ? null : Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (onAdd != null)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Icon(Icons.add, size: 14, color: AppTheme.textTertiary),
              ),
            ),
        ],
      ),
    );
  }
}
