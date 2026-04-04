import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/share_card_util.dart';
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
        title: Text('添加分类',
            style: AppTheme.headingStyleWith(fontSize: 18)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '输入分类名称',
            hintStyle: TextStyle(color: AppTheme.textPrimary.withAlpha(100)),
            border: OutlineInputBorder(
              borderRadius: AppTheme.wobblySmall,
              borderSide: const BorderSide(color: AppTheme.border, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppTheme.wobblySmall,
              borderSide: const BorderSide(color: AppTheme.border, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppTheme.wobblySmall,
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消', style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                DataService.instance.addCategory('vocabulary', name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet(VocabularyItem item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.muted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            _menuTile(Icons.copy, '复制内容', () {
              Navigator.pop(ctx);
              Clipboard.setData(ClipboardData(text: item.content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制')),
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
            const SizedBox(height: 12),
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
          color: isDestructive ? AppTheme.accent : AppTheme.textSecondary),
      title: Text(label,
          style: TextStyle(
              fontSize: 14,
              color: isDestructive ? AppTheme.accent : AppTheme.textPrimary)),
      onTap: onTap,
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                    onTap: () => setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) _searchQuery = '';
                    }),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: _showSearch
                          ? BoxDecoration(
                              color: AppTheme.textPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.border, width: 2),
                              boxShadow: const [BoxShadow(color: Color(0xFF2D2D2D), offset: Offset(2, 2))],
                            )
                          : AppTheme.outlinedCircleDecoration(),
                      child: Icon(
                          _showSearch ? Icons.close : Icons.search,
                          size: 18,
                          color: _showSearch
                              ? Colors.white
                              : AppTheme.textPrimary),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '词汇',
                        style: AppTheme.headingStyleWith(fontSize: 20),
                      ),
                    ),
                  ),
                  // Add button
                  GestureDetector(
                    onTap: () => showAddVocabularySheet(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: AppTheme.outlinedCircleDecoration(),
                      child: const Icon(Icons.add,
                          size: 18, color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ────────────────────────────────────────────────
            if (_showSearch) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: AppTheme.wobblySmall,
                    border: Border.all(color: AppTheme.border, width: 2),
                    boxShadow: AppTheme.hardShadowHover,
                  ),
                  child: TextField(
                    autofocus: true,
                    onChanged: (v) =>
                        setState(() => _searchQuery = v),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: '搜索词汇、分类、标签...',
                      hintStyle: TextStyle(
                          color: AppTheme.textPrimary.withAlpha(100), fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.textPrimary, size: 16),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 36),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Category Pills ────────────────────────────────────────────
            CategoryPills(
              categories: _categories,
              selected: _selectedCategory,
              onSelect: (cat) =>
                  setState(() => _selectedCategory = cat),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: const BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: AppTheme.wobblyPill,
                      border:
                          Border.fromBorderSide(BorderSide(color: AppTheme.border, width: 1.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('最新',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textPrimary)),
                        SizedBox(width: 2),
                        Icon(Icons.keyboard_arrow_down,
                            size: 12, color: AppTheme.textPrimary),
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
                      padding:
                          const EdgeInsets.fromLTRB(14, 0, 14, 100),
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
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
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppTheme.muted,
              borderRadius: AppTheme.wobblyMd,
              border: Border.fromBorderSide(
                BorderSide(color: AppTheme.border, width: 2),
              ),
              boxShadow: [BoxShadow(color: Color(0xFF2D2D2D), offset: Offset(3, 3))],
            ),
            child: const Icon(Icons.text_fields_rounded,
                size: 36, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Text('暂无词汇',
              style: AppTheme.headingStyleWith(fontSize: 16)),
          const SizedBox(height: 6),
          const Text('点击右上角 + 添加',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  // ── Vocabulary Card ─────────────────────────────────────────────────────

  Widget _buildVocabularyCard(VocabularyItem item) {
    return GestureDetector(
      onTap: () => showAddVocabularySheet(context, item: item),
      onLongPress: () => _showOptionsSheet(item),
      child: Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: const BoxDecoration(
                          color: AppTheme.muted,
                          borderRadius: AppTheme.wobblyPill,
                        ),
                        alignment: Alignment.center,
                        child: Text(item.category,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary)),
                      ),
                      if (item.tags.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        ...item.tags.take(2).map((tag) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text('#$tag',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.secondary)),
                            )),
                      ],
                      const Spacer(),
                      Text(_formatRelativeDate(item.createdAt),
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                GestureDetector(
                  onTap: () => DataService.instance
                      .toggleVocabularyFavorite(item.id),
                  child: Icon(
                    item.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 18,
                    color: item.isFavorite
                        ? AppTheme.accent
                        : AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showOptionsSheet(item),
                  child: const Icon(Icons.more_vert,
                      size: 18, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
