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
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          ...categories.map((cat) {
            final isSelected = cat == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.textPrimary
                        : AppTheme.cardBackground,
                    borderRadius: AppTheme.wobblyPill,
                    border: Border.all(
                      color: AppTheme.border,
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? AppTheme.hardShadowHover
                        : null,
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.textPrimary,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: AppTheme.wobblyPill,
                  border: Border.all(
                    color: AppTheme.border,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Icon(Icons.add,
                    size: 15, color: AppTheme.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
