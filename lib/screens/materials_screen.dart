import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_pills.dart';
import '../models/material_item.dart';
import '../services/data_service.dart';
import '../widgets/add_material_sheet.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
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

  List<MaterialItem> get _filteredMaterials {
    var items = List<MaterialItem>.from(DataService.instance.materials);

    if (_selectedCategory != '全部') {
      items = items.where((m) => m.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((m) {
        return m.content.toLowerCase().contains(q) ||
            m.category.toLowerCase().contains(q) ||
            m.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<String> get _categories =>
      ['全部', ...DataService.instance.materialCategories];

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
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
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
                DataService.instance.addCategory('material', name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showItemMenu(MaterialItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _menuTile(Icons.edit_outlined, '编辑', () {
              Navigator.pop(ctx);
              showAddMaterialSheet(context);
            }),
            _menuTile(
              item.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              item.isFavorite ? '取消收藏' : '收藏',
              () {
                Navigator.pop(ctx);
                DataService.instance.toggleMaterialFavorite(item.id);
              },
            ),
            _menuTile(Icons.delete_outline, '删除', () {
              Navigator.pop(ctx);
              _confirmDelete(item);
            }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(MaterialItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('确认删除',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('删除后无法恢复，确定要删除吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              DataService.instance.deleteMaterial(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('已删除'),
                    behavior: SnackBarBehavior.floating),
              );
            },
            child:
                const Text('删除', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
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
    final items = _filteredMaterials;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  // Search icon
                  GestureDetector(
                    onTap: () => setState(() => _showSearch = !_showSearch),
                    child: Container(
                      width: 36,
                      height: 36,
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
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Icon(Icons.search,
                          size: 18,
                          color: _showSearch
                              ? Colors.white
                              : AppTheme.textSecondary),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '素材库',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  // Add button
                  GestureDetector(
                    onTap: () => showAddMaterialSheet(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.textPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ────────────────────────────────────────────────
            if (_showSearch) ...[
              SearchBarWidget(
                placeholder: '搜索素材正文、分类、标签...',
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

            // ── Count + Sort ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '共 ${items.length} 条素材',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textTertiary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('最新',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                        const SizedBox(width: 2),
                        Icon(Icons.keyboard_arrow_down,
                            size: 14, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildMaterialCard(items[index]),
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
            child: Icon(Icons.auto_stories_outlined,
                size: 36,
                color: AppTheme.textTertiary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          const Text('暂无素材',
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

  // ── Material Card ───────────────────────────────────────────────────────

  Widget _buildMaterialCard(MaterialItem item) {
    final catColor = AppTheme.getCategoryColor(item.category);
    final catBgColor = AppTheme.getCategoryBgColor(item.category);
    // Soft pastel card background tinted by category
    final cardBg = catColor.withValues(alpha: 0.06);

    return GestureDetector(
      onLongPress: () => _showItemMenu(item),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: category + tags + star + menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: catBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(item.category,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: catColor)),
                      ),
                      ...item.tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('#$tag',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary)),
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      DataService.instance.toggleMaterialFavorite(item.id),
                  child: Icon(
                    item.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 22,
                    color: item.isFavorite
                        ? const Color(0xFFF59E0B)
                        : AppTheme.textTertiary.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showItemMenu(item),
                  child: const Icon(Icons.more_horiz,
                      size: 20, color: AppTheme.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Text(item.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.7)),
            const SizedBox(height: 12),

            // Bottom: source + time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (item.source.isNotEmpty)
                  Text('来源：${item.source}',
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textTertiary)),
                const Spacer(),
                Text(_formatRelativeDate(item.createdAt),
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textTertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
