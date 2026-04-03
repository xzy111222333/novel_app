import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/inspiration_item.dart';
import '../services/data_service.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/add_inspiration_sheet.dart';

class InspirationScreen extends StatefulWidget {
  const InspirationScreen({super.key});

  @override
  State<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends State<InspirationScreen> {
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    DataService.instance.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DataService.instance.removeListener(_onDataChanged);
    super.dispose();
  }

  List<InspirationItem> get _filteredItems {
    final all = DataService.instance.inspirations;
    if (_searchQuery.isEmpty) return all;
    final lq = _searchQuery.toLowerCase();
    return all.where((item) {
      return item.content.toLowerCase().contains(lq) ||
          (item.title?.toLowerCase().contains(lq) ?? false) ||
          item.tags.any((t) => t.toLowerCase().contains(lq));
    }).toList();
  }

  static String _weekday(int w) =>
      ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][w - 1];

  Map<String, List<InspirationItem>> _groupByDate(List<InspirationItem> items) {
    final grouped = <String, List<InspirationItem>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      final itemDate = DateTime(
          item.createdAt.year, item.createdAt.month, item.createdAt.day);
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

  static const _dotColors = [
    Color(0xFFFBBF24),
    Color(0xFFA78BFA),
    Color(0xFF34D399),
    Color(0xFFF472B6),
    Color(0xFF60A5FA),
  ];

  void _showEditSheet(InspirationItem item) {
    final titleController = TextEditingController(text: item.title ?? '');
    final contentController = TextEditingController(text: item.content);
    final tagsController =
        TextEditingController(text: item.tags.join(', '));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text('编辑灵感',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: '标题（可选）',
                  hintStyle: TextStyle(color: AppTheme.textTertiary),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '灵感内容',
                  hintStyle: TextStyle(color: AppTheme.textTertiary),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagsController,
                decoration: InputDecoration(
                  hintText: '标签（用逗号分隔）',
                  hintStyle: TextStyle(color: AppTheme.textTertiary),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final tags = tagsController.text
                        .split(RegExp(r'[,，]'))
                        .map((t) => t.trim())
                        .where((t) => t.isNotEmpty)
                        .toList();
                    final updated = item.copyWith(
                      title: titleController.text.isEmpty
                          ? null
                          : titleController.text,
                      content: contentController.text,
                      tags: tags,
                    );
                    DataService.instance.updateInspiration(updated);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('保存',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(InspirationItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，确定要删除这条灵感吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('取消', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              DataService.instance.deleteInspiration(item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('已删除'),
                    behavior: SnackBarBehavior.floating),
              );
            },
            child:
                const Text('删除', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    final grouped = _groupByDate(items);
    final dateKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  _HeaderIconButton(
                    icon: _showSearch ? Icons.close : Icons.search,
                    onTap: () => setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) _searchQuery = '';
                    }),
                  ),
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
                    icon: Icons.add,
                    filled: true,
                    onTap: () => showAddInspirationSheet(context),
                  ),
                ],
              ),
            ),

            // Search bar
            if (_showSearch) ...[
              SearchBarWidget(
                placeholder: '搜索标题、内容、标签...',
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 12),
            ],

            // Content
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('✨',
                              style: TextStyle(
                                  fontSize: 48,
                                  color: AppTheme.textTertiary
                                      .withValues(alpha: 0.5))),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? '没有找到匹配的灵感'
                                : '记录你的第一个灵感吧 ✨',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () =>
                                  showAddInspirationSheet(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.textPrimary,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Text('记录灵感',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: dateKeys.length,
                      itemBuilder: (context, sectionIndex) {
                        final key = dateKeys[sectionIndex];
                        final sectionItems = grouped[key]!;
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
                              // Cards
                              ...sectionItems.map((item) =>
                                  _buildInspirationCard(item)),
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

  Widget _buildInspirationCard(InspirationItem item) {
    final hour = item.createdAt.hour;
    final isDaytime = hour >= 6 && hour < 18;
    final timeStr = DateFormat('HH:mm').format(item.createdAt);

    // Pastel tint based on time of day
    final cardBg = isDaytime
        ? const Color(0xFFFFFDF7) // warm cream
        : const Color(0xFFF5F7FF); // cool lavender

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDaytime
              ? const Color(0xFFFDE68A).withValues(alpha: 0.4)
              : const Color(0xFFC7D2FE).withValues(alpha: 0.4),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isDaytime
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFF818CF8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            // Card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDaytime
                            ? const Color(0xFFFFFBEB)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDaytime
                                ? Icons.wb_sunny_rounded
                                : Icons.nightlight_round,
                            size: 12,
                            color: isDaytime
                                ? const Color(0xFFD97706)
                                : const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDaytime
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
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

                    // Action row
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Colors.black.withValues(alpha: 0.04)),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildActionBtn(
                            Icons.arrow_forward_rounded,
                            '转素材',
                            () {
                              DataService.instance
                                  .convertInspirationToMaterial(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('已转为素材'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 14),
                          _buildActionBtn(
                            Icons.translate_rounded,
                            '转词汇',
                            () {
                              DataService.instance
                                  .convertInspirationToVocabulary(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('已转为词汇'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () => DataService.instance
                                .toggleInspirationFavorite(item.id),
                            child: Icon(
                              item.isFavorite
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 18,
                              color: item.isFavorite
                                  ? const Color(0xFFFBBF24)
                                  : AppTheme.textTertiary,
                            ),
                          ),
                          const Spacer(),
                          _buildMoreMenu(item),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textTertiary),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreMenu(InspirationItem item) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showEditSheet(item);
            break;
          case 'delete':
            _confirmDelete(item);
            break;
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text('编辑')),
        const PopupMenuItem(
          value: 'delete',
          child: Text('删除', style: TextStyle(color: Color(0xFFEF4444))),
        ),
      ],
      child: const Icon(Icons.more_horiz_rounded,
          size: 18, color: AppTheme.textTertiary),
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
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: filled ? AppTheme.textPrimary : const Color(0xFFF3F4F6),
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
