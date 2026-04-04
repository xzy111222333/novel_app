import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/share_card_util.dart';
import '../widgets/category_pills.dart';
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
        title: Text('新增剧情分类',
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
                DataService.instance.addCategory('plot', name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditPlotSheet(PlotItem item) {
    showAddPlotSheet(context, item: item);
  }

  @override
  Widget build(BuildContext context) {
    final plots = _filteredPlots;
    final categories = ['全部', ...DataService.instance.plotCategories];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
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
                        '剧情',
                        style: AppTheme.headingStyleWith(fontSize: 20),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showAddPlotSheet(context),
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

            // ── Toggleable search bar ──
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
                      hintText: '搜索剧情内容、分类、标签...',
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

            // ── Category pills ──
            CategoryPills(
              categories: categories,
              selected: _selectedCategory,
              onSelect: (cat) =>
                  setState(() => _selectedCategory = cat),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
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
                          Text(
                            '暂无剧情',
                            style: AppTheme.headingStyleWith(fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '点击右上角 + 添加',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
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

  void _showOptionsSheet(PlotItem item) {
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
            ListTile(
              leading: const Icon(Icons.copy,
                  size: 22, color: AppTheme.textSecondary),
              title: const Text('复制内容',
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(
                    ClipboardData(text: item.displayContent));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('已复制'),
                      behavior: SnackBarBehavior.floating),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined,
                  size: 22, color: AppTheme.textSecondary),
              title: const Text('分享为图片',
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                await _shareItemAsImage(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notes,
                  size: 22, color: AppTheme.textSecondary),
              title: const Text('查看全部剧情',
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _showAllPlots();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  size: 22, color: AppTheme.accent),
              title: const Text('删除剧情',
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.accent)),
              onTap: () {
                Navigator.pop(ctx);
                DataService.instance.deletePlot(item.id);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── Plot card ──
  Widget _buildPlotCard(PlotItem item) {
    return GestureDetector(
      onTap: () => _showEditPlotSheet(item),
      onLongPress: () => _showOptionsSheet(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content
            if (item.type == 'steps')
              _buildStepsContent(item)
            else
              _buildFreeContent(item),
            const SizedBox(height: 8),

            // Bottom: category tag + tags + star + menu
            Row(
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
                  child: Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
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
                GestureDetector(
                  onTap: () => DataService.instance
                      .togglePlotFavorite(item.id),
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

  // ── Steps content (max 3 visible) ──
  Widget _buildStepsContent(PlotItem item) {
    final showSteps =
        item.steps.length > 3 ? item.steps.sublist(0, 3) : item.steps;
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
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: AppTheme.wobblySmall,
                    border: Border.fromBorderSide(
                      BorderSide(color: AppTheme.border, width: 1.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${e.key + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
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
                    fontSize: 14, color: AppTheme.textSecondary)),
          ),
      ],
    );
  }

  // ── Free text content (max 3 lines) ──
  Widget _buildFreeContent(PlotItem item) {
    return Text(
      item.freeContent,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 14,
        color: AppTheme.textPrimary,
        height: 1.5,
      ),
    );
  }
}
