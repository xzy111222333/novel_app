import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({
    super.key,
    required this.placeholder,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: AppTheme.wobblySmall,
        border: Border.all(color: AppTheme.border, width: 2),
        boxShadow: AppTheme.hardShadowHover,
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
              color: AppTheme.textPrimary.withAlpha(100), fontSize: 13),
          prefixIcon: Icon(Icons.search,
              color: AppTheme.textPrimary.withAlpha(100), size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
