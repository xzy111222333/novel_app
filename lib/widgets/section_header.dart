import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final VoidCallback? onMore;

  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppTheme.textPrimary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (onMore != null)
            GestureDetector(
              onTap: onMore,
              child: Text(
                '查看更多 >',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
