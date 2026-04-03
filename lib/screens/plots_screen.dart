import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/share_card_util.dart';
import '../widgets/category_pills.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/add_plot_sheet.dart';
import '../models/plot_item.dart';
import '../services/data_service.dart';

class PlotsScreen extends StatefulWidget {
  const PlotsScreen({super.key});

  @override
  State<PlotsScreen> createState() => _PlotsScreenState();
}

class _PlotsScreenState extends State<PlotsScreen> {
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

  List<PlotItem> get _filteredPlots {
    final plots = DataService.instance.plots;
    final lq = _searchQuery.toLowerCase();
    return plots.where((item) {
      final matchesCategory =
          _selectedCategory == '全部' || item.category == _selectedCategory;
      if (!matchesCategory) return false;
      if (lq.isEmpty) return true;
      if (item.category.toLowerCase().contains(lq)) return true;
      if (item.tags.any((t) => t.toLowerCase().contains(lq))) return true;
      if (item.type == 'steps') {
        if (item.steps.any((s) => s.toLowerCase().contains(lq))) return true;
      } else {
        if (item.freeContent.toLowerCase().contains(lq)) return true;
      }
      return false;
    }).toList();
  }

  Future<void> _shareItemAsImage(PlotItem item) async {
    await ShareCardUtil.shareAsImage(
      context,
      typeLabel: '剧情',
      content: item.displayContent,
      meta: item.category,
      tags: item.tags,
      accentColor: AppTheme.getCategoryColor(item.category),
    );
  }

  void _showAllPlots() {
    setState(() {
      _selectedCategory = '全部';
      _searchQuery = '';
      _showSearch = false;
    });
  }

  // ── Add category dialog ──
  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('新增剧情分类'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入分类名称'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                DataService.instance.addCategory('plot', name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // ── Edit bottom sheet ──
  void _showEditPlotSheet(PlotItem item) {
    showAddPlotSheet(context, item: item);
  }

  @override
  Widget build(BuildContext context) {
    final plots = _filteredPlots;
    final categories = ['全部', ...DataService.instance.plotCategories];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  _buildHeaderButton(Icons.search, () {
                    setState(() => _showSearch = !_showSearch);
                  }),
                  const Spacer(),
                  const Text(
                    '剧情库',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  _buildHeaderButton(Icons.add, () {
                    showAddPlotSheet(context);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Toggleable search bar ──
            if (_showSearch) ...[
              SearchBarWidget(
                placeholder: '搜索剧情内容、分类、标签...',
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 12),
            ],

            // ── Category pills ──
            CategoryPills(
              categories: categories,
              selected: _selectedCategory,
              onSelect: (cat) => setState(() => _selectedCategory = cat),
              onAdd: _showAddCategoryDialog,
            ),
            const SizedBox(height: 12),

            // ── Count row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '共 ${plots.length} 条剧情',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Plot cards / empty state ──
            Expanded(
              child: plots.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_stories_outlined,
                              size: 56, color: AppTheme.textTertiary.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            '暂无剧情，点击右上角 + 添加',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: plots.length,
                      itemBuilder: (context, index) =>
                          _buildPlotCard(plots[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dark circular header button ──
  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.textPrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  void _showOptionsSheet(PlotItem item) {
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
            ListTile(
              leading: const Icon(Icons.copy, size: 22, color: AppTheme.textSecondary),
              title: const Text('复制内容', style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: item.displayContent));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined, size: 22, color: AppTheme.textSecondary),
              title: const Text('分享为图片', style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                await _shareItemAsImage(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notes, size: 22, color: AppTheme.textSecondary),
              title: const Text('查看全部剧情', style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _showAllPlots();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, size: 22, color: Colors.redAccent),
              title: const Text('删除剧情', style: TextStyle(fontSize: 15, color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                DataService.instance.deletePlot(item.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Plot card ──
  Widget _buildPlotCard(PlotItem item) {
    final categoryColor = AppTheme.getCategoryColor(item.category);

    return GestureDetector(
      onTap: () => _showEditPlotSheet(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tag + popup menu
          Row(
            children: [
              Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    DataService.instance.togglePlotFavorite(item.id),
                child: Icon(
                  item.isFavorite ? Icons.star : Icons.star_border,
                  size: 16,
                  color: item.isFavorite
                      ? const Color(0xFFF59E0B)
                      : AppTheme.textTertiary,
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
          if (item.type == 'steps')
            _buildStepsContent(item)
          else
            _buildFreeContent(item),

          // Tags row
          if (item.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: item.tags.map((tag) {
                return Text(
                  '#$tag',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textTertiary,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    ),
  );
}

  // ── Steps content (max 4 visible) ──
  Widget _buildStepsContent(PlotItem item) {
    final showSteps = item.steps.length > 3
        ? item.steps.sublist(0, 3)
        : item.steps;
    final hasMore = item.steps.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...showSteps.asMap().entries.map((e) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: e.key < showSteps.length - 1 ? 6 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppTheme.getCategoryColor(item.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      '${e.key + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getCategoryColor(item.category),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        if (hasMore)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('...',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textTertiary)),
          ),
      ],
    );
  }

  // ── Free text content (max 4 lines) ──
  Widget _buildFreeContent(PlotItem item) {
    return Text(
      item.freeContent,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
        color: AppTheme.textSecondary,
        height: 1.5,
      ),
    );
  }
}

