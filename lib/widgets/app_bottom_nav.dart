import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.calendar_today, label: '今日', index: 0),
      _NavItem(icon: Icons.menu_book_rounded, label: '素材', index: 1),
      _NavItem(icon: Icons.edit_note_rounded, label: '灵感', index: 2),
      _NavItem(icon: Icons.bar_chart_rounded, label: '统计', index: 3),
      _NavItem(icon: Icons.person_outline_rounded, label: '我的', index: 4),
    ];

    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 34, top: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((item) {
          final isActive = currentIndex == item.index;
          return GestureDetector(
            onTap: () => onTap(item.index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: isActive
                      ? BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        )
                      : null,
                  child: Icon(
                    item.icon,
                    size: isActive ? 22 : 24,
                    color: isActive ? AppTheme.textPrimary : AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? AppTheme.textPrimary : AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;
  const _NavItem({required this.icon, required this.label, required this.index});
}
