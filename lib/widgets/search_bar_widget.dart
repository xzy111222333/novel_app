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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: AppTheme.smallCardDecoration,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppTheme.textTertiary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
