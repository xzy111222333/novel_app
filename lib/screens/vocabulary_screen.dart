import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/share_card_util.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_pills.dart';
import '../models/vocabulary_item.dart';
import '../services/data_service.dart';
import '../widgets/add_vocabulary_sheet.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  String _selectedCategory = '全部';
  String _searchQuery = '';
  bool _showSearch = false;

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

  // ── Data ────────────────────────────────────────────────────────────────

  List<VocabularyItem> get _filteredItems {
    var items = List<VocabularyItem>.from(DataService.instance.vocabulary);

    if (_selectedCategory != '全部') {
      items = items.where((v) => v.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((v) {
        return v.content.toLowerCase().contains(q) ||
            v.category.toLowerCase().contains(q) ||
            v.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<String> get _categories =>
      ['全部', ...DataService.instance.vocabularyCategories];

  // ── Helpers ─────────────────────────────────────────────────────────────

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    final time = '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    if (diff == 0) return '今天 $time';
    if (diff == 1) return '昨天 $time';
    return '${date.month}月${date.day}日';
  }

  Future<void> _shareItemAsImage(VocabularyItem item) async {
    await ShareCardUtil.shareAsImage(
      context,
      typeLabel: '词汇',
      content: item.content,
      meta: item.category,
      tags: item.tags,
      accentColor: AppTheme.getCategoryColor(item.category),
    );
  }

  void _showAllVocabulary() {
    setState(() {
      _selectedCategory = '全部';
      _searchQuery = '';
      _showSearch = false;
    });
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('添加分类',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '输入分类名称',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                DataService.instance.addCategory('vocabulary', name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet(VocabularyItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            _menuTile(Icons.copy, '复制内容', () {
              Navigator.pop(ctx);
              Clipboard.setData(ClipboardData(text: item.content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制'), behavior: SnackBarBehavior.floating),
              );
            }),
            _menuTile(Icons.image_outlined, '分享为图片', () {
              Navigator.pop(ctx);
              _shareItemAsImage(item);
            }),
            _menuTile(Icons.notes, '查看全部词汇', () {
              Navigator.pop(ctx);
              _showAllVocabulary();
            }),
            _menuTile(Icons.delete_outline, '删除词汇', () {
              Navigator.pop(ctx);
              DataService.instance.deleteVocabulary(item.id);
            }, isDestructive: true),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon,
          size: 22,
          color: isDestructive ? Colors.redAccent : AppTheme.textSecondary),
      title: Text(label,
          style: TextStyle(
              fontSize: 15,
              color:
                  isDestructive ? Colors.redAccent : AppTheme.textPrimary)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Search icon
                  GestureDetector(
                    onTap: () => setState(() => _showSearch = !_showSearch),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _showSearch
                            ? AppTheme.textPrimary
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: _showSearch
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                      child: Icon(Icons.search,
                          size: 16,
                          color: _showSearch
                              ? Colors.white
                              : AppTheme.textSecondary),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '词汇库',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  // Add button
                  GestureDetector(
                    onTap: () => showAddVocabularySheet(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.textPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ────────────────────────────────────────────────
            if (_showSearch) ...[
              SearchBarWidget(
                placeholder: '搜索词汇、分类、标签...',
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 12),
            ],

            // ── Category Pills ────────────────────────────────────────────
            CategoryPills(
              categories: _categories,
              selected: _selectedCategory,
              onSelect: (cat) => setState(() => _selectedCategory = cat),
              onAdd: _showAddCategoryDialog,
            ),
            const SizedBox(height: 12),

            // ── Count Row ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '共 ${items.length} 条词汇',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textTertiary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('最新',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary)),
                        const SizedBox(width: 2),
                        Icon(Icons.keyboard_arrow_down,
                            size: 12, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          _buildVocabularyCard(items[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.text_fields_rounded,
                size: 36,
                color: AppTheme.textTertiary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          const Text('暂无词汇',
              style:
                  TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          const Text('点击右上角 + 添加',
              style:
                  TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }

  // ── Vocabulary Card ─────────────────────────────────────────────────────

  Widget _buildVocabularyCard(VocabularyItem item) {
    final catColor = AppTheme.getCategoryColor(item.category);
    final catBgColor = AppTheme.getCategoryBgColor(item.category);

    return GestureDetector(
      onTap: () => showAddVocabularySheet(context, item: item),
      onLongPress: () => _showOptionsSheet(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: category + tags + star + menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: catBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(item.category,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: catColor)),
                      ),
                      ...item.tags.map((tag) => Text('#$tag',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textTertiary))),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () =>
                      DataService.instance.toggleVocabularyFavorite(item.id),
                  child: Icon(
                    item.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 16,
                    color: item.isFavorite
                        ? const Color(0xFFF59E0B)
                        : AppTheme.textTertiary.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showOptionsSheet(item),
                  child: const Icon(Icons.more_horiz,
                      size: 16, color: AppTheme.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Content
            Text(item.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 6),

            // Timestamp
            Text(_formatRelativeDate(item.createdAt),
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textTertiary)),
          ],
        ),
      ),
    );
  }
}
