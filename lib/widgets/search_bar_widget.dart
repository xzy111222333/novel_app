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
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
          prefixIcon: Icon(Icons.search, color: AppTheme.textTertiary, size: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 36),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
