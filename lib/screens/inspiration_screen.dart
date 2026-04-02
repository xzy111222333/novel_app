import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/inspiration_item.dart';
import '../services/sample_data.dart';

class InspirationScreen extends StatefulWidget {
  const InspirationScreen({super.key});

  @override
  State<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends State<InspirationScreen> {
  late List<InspirationItem> _items;

  @override
  void initState() {
    super.initState();
    _items = SampleData.getInspirations();
  }

  static String _weekday(int w) =>
      ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][w - 1];

  Map<String, List<InspirationItem>> _groupByDate(List<InspirationItem> items) {
    final grouped = <String, List<InspirationItem>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      final itemDate =
          DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      final dateStr =
          '${item.createdAt.month}月${item.createdAt.day}日 ${_weekday(item.createdAt.weekday)}';
      String key;
      if (itemDate == today) {
        key = '今天 · $dateStr';
      } else if (itemDate == yesterday) {
        key = '昨天 · $dateStr';
      } else {
        key = '${item.createdAt.month}月${item.createdAt.day}日 · ${_weekday(item.createdAt.weekday)}';
      }
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  // Rotate dot colors per date section
  static const _dotColors = [
    Color(0xFFFBBF24), // amber
    Color(0xFFA78BFA), // violet
    Color(0xFF34D399), // emerald
    Color(0xFFF472B6), // pink
    Color(0xFF60A5FA), // blue
  ];

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(_items);
    final dateKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '灵感日记',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  _HeaderIconButton(
                    icon: Icons.search,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _HeaderIconButton(
                    icon: Icons.add,
                    filled: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Scrollable grouped list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: dateKeys.length,
                itemBuilder: (context, sectionIndex) {
                  final key = dateKeys[sectionIndex];
                  final items = grouped[key]!;
                  final dotColor =
                      _dotColors[sectionIndex % _dotColors.length];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                key,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Inspiration cards
                        ...items.map((item) => _InspirationCard(item: item)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InspirationCard extends StatelessWidget {
  final InspirationItem item;

  const _InspirationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final hour = item.createdAt.hour;
    final isNight = hour < 6 || hour >= 20;
    final timeStr = DateFormat('HH:mm').format(item.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isNight
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 12,
                  color: isNight
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFD97706),
                ),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isNight
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Title
          if (item.title != null && item.title!.isNotEmpty) ...[
            Text(
              item.title!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Content
          Text(
            item.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),

          // Tags
          if (item.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: item.tags.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Bottom actions
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF9FAFB), width: 1),
              ),
            ),
            child: Row(
              children: [
                _ActionButton(
                    icon: Icons.arrow_forward_rounded, label: '转素材'),
                const SizedBox(width: 16),
                _ActionButton(icon: Icons.translate_rounded, label: '转词汇'),
                const SizedBox(width: 16),
                _ActionButton(
                    icon: Icons.bookmark_border_rounded, label: '收藏'),
                const Spacer(),
                _ActionButton(
                    icon: Icons.more_horiz_rounded, label: '更多'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textTertiary),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    this.filled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: filled ? AppTheme.textPrimary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? Colors.white : AppTheme.textSecondary,
        ),
      ),
    );
  }
}
