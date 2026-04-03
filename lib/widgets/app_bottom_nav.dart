import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNavItem {
  final IconData icon;
  final String label;
  const BottomNavItem({required this.icon, required this.label});
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = currentIndex == index;
          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: items.length <= 5 ? 56 : 48,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.textPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      item.icon,
                      size: 22,
                      color: isActive ? Colors.white : AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                      color: isActive
                          ? AppTheme.textPrimary
                          : AppTheme.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
