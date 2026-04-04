import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/share_card_util.dart';
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

  Future<void> _shareItemAsImage(MaterialItem item) async {
    await ShareCardUtil.shareAsImage(
      context,
      typeLabel: '素材',
      content: item.content,
      meta: item.source.isEmpty
          ? item.category
          : '${item.category} · ${item.source}',
      tags: item.tags,
      accentColor: AppTheme.getCategoryColor(item.category),
    );
  }

  void _showAllMaterials() {
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
                DataService.instance.addCategory('material', name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet(MaterialItem item) {
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
            _menuTile(Icons.notes, '查看全部素材', () {
              Navigator.pop(ctx);
              _showAllMaterials();
            }),
            _menuTile(Icons.delete_outline, '删除素材', () {
              Navigator.pop(ctx);
              DataService.instance.deleteMaterial(item.id);
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
              color:
                  isDestructive ? AppTheme.accent : AppTheme.textPrimary)),
      onTap: onTap,
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final items = _filteredMaterials;

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
                        '素材',
                        style: AppTheme.headingStyleWith(fontSize: 20),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showAddMaterialSheet(context),
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
                      hintText: '搜索素材正文、分类、标签...',
                      hintStyle: TextStyle(
                          color: AppTheme.textPrimary.withAlpha(100), fontSize: 13),
                      prefixIcon: Icon(Icons.search,
                          color: AppTheme.textPrimary.withAlpha(100), size: 18),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 40),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
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

            // ── Count + Sort ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '共 ${items.length} 条素材',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: AppTheme.wobblyPill,
                      border: Border.all(color: AppTheme.border, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('最新',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textPrimary)),
                        SizedBox(width: 2),
                        Icon(Icons.keyboard_arrow_down,
                            size: 14, color: AppTheme.textPrimary),
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
            child: const Icon(Icons.auto_stories_outlined,
                size: 36, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Text('暂无素材',
              style: AppTheme.headingStyleWith(fontSize: 16)),
          const SizedBox(height: 6),
          const Text('点击右上角 + 添加',
              style: TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  // ── Material Card ───────────────────────────────────────────────────────

  Widget _buildMaterialCard(MaterialItem item) {
    return GestureDetector(
      onTap: () => showAddMaterialSheet(context, item: item),
      onLongPress: () => _showOptionsSheet(item),
      child: Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.6)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 22,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8),
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
                if (item.source.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(item.source,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary)),
                  ),
                Text(_formatRelativeDate(item.createdAt),
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => DataService.instance
                      .toggleMaterialFavorite(item.id),
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
                const SizedBox(width: 4),
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
