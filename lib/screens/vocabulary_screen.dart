import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/category_pills.dart';
import '../widgets/search_bar_widget.dart';
import '../models/vocabulary_item.dart';
import '../services/sample_data.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  String _selectedCategory = '全部';
  String _searchQuery = '';

  late List<VocabularyItem> _allItems;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _allItems = SampleData.getVocabulary();
    final cats = _allItems.map((e) => e.category).toSet().toList();
    _categories = ['全部', ...cats];
  }

  List<VocabularyItem> get _filteredItems {
    return _allItems.where((item) {
      if (_selectedCategory != '全部' && item.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return item.content.toLowerCase().contains(q) ||
            item.category.toLowerCase().contains(q) ||
            item.tags.any((t) => t.toLowerCase().contains(q));
      }
      return true;
    }).toList();
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(dt.year, dt.month, dt.day);
    final time = DateFormat('HH:mm').format(dt);

    if (itemDate == today) return '今天 $time';
    if (itemDate == yesterday) return '昨天 $time';
    return DateFormat('M月d日 HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

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
                  const Expanded(
                    child: Text(
                      '词汇库',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  _HeaderIconButton(
                    icon: Icons.search,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  _HeaderIconButton(
                    icon: Icons.add,
                    filled: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Search bar
            SearchBarWidget(
              placeholder: '搜索词汇、分类、标签...',
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 14),

            // Category pills
            CategoryPills(
              categories: _categories,
              selected: _selectedCategory,
              onSelect: (cat) => setState(() => _selectedCategory = cat),
              onAdd: () {},
            ),
            const SizedBox(height: 12),

            // Filter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '共 ${filtered.length} 条词汇',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '按时间最新',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.arrow_drop_down,
                            size: 16, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Vocabulary list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return _VocabularyCard(
                    item: filtered[index],
                    formatTime: _formatTime,
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

class _VocabularyCard extends StatelessWidget {
  final VocabularyItem item;
  final String Function(DateTime) formatTime;

  const _VocabularyCard({required this.item, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    final catColor = AppTheme.getCategoryColor(item.category);
    final catBg = AppTheme.getCategoryBgColor(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.smallCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: tags + star
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Category tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: catBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: catColor,
                        ),
                      ),
                    ),
                    // First user tag
                    if (item.tags.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${item.tags.first}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                item.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                size: 20,
                color: item.isFavorite
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFFD1D5DB),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main content
          Text(
            item.content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Timestamp
          Text(
            formatTime(item.createdAt),
            style: const TextStyle(
              fontSize: 10,
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
          color: filled ? AppTheme.textPrimary : Colors.white,
          shape: BoxShape.circle,
          boxShadow: filled
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
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
