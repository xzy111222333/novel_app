import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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

  // ── Delete confirm dialog ──
  void _confirmDelete(PlotItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，确定要删除这条剧情吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              DataService.instance.deletePlot(item.id);
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── Edit bottom sheet ──
  void _showEditPlotSheet(PlotItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditPlotSheet(item: item),
    );
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _buildHeaderButton(Icons.search, () {
                    setState(() => _showSearch = !_showSearch);
                  }),
                  const Spacer(),
                  const Text(
                    '剧情库',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
            const SizedBox(height: 16),

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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '共 ${plots.length} 条剧情',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.textPrimary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  // ── Plot card ──
  Widget _buildPlotCard(PlotItem item) {
    final categoryColor = AppTheme.getCategoryColor(item.category);
    final cardBg = AppTheme.getCategoryBgColor(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
              ),
              const Spacer(),
              // Favorite star
              GestureDetector(
                onTap: () =>
                    DataService.instance.togglePlotFavorite(item.id),
                child: Icon(
                  item.isFavorite ? Icons.star : Icons.star_border,
                  size: 22,
                  color: item.isFavorite
                      ? const Color(0xFFF59E0B)
                      : AppTheme.textTertiary,
                ),
              ),
              const SizedBox(width: 4),
              // Three-dot menu
              SizedBox(
                width: 28,
                height: 28,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: const Icon(Icons.more_vert,
                      size: 20, color: AppTheme.textTertiary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditPlotSheet(item);
                        break;
                      case 'delete':
                        _confirmDelete(item);
                        break;
                      case 'fav':
                        DataService.instance.togglePlotFavorite(item.id);
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('编辑')),
                    const PopupMenuItem(value: 'delete', child: Text('删除')),
                    PopupMenuItem(
                      value: 'fav',
                      child:
                          Text(item.isFavorite ? '取消收藏' : '收藏'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Content
          if (item.type == 'steps')
            _buildStepsContent(item)
          else
            _buildFreeContent(item),

          // Tags row
          if (item.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.tags.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Steps content (max 4 visible) ──
  Widget _buildStepsContent(PlotItem item) {
    final showSteps = item.steps.length > 4
        ? item.steps.sublist(0, 4)
        : item.steps;
    final hasMore = item.steps.length > 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...showSteps.asMap().entries.map((e) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: e.key < showSteps.length - 1 ? 8 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${e.key + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getCategoryColor(item.category),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(
                      fontSize: 13,
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
            padding: EdgeInsets.only(top: 6),
            child: Text('...',
                style: TextStyle(
                    fontSize: 14, color: AppTheme.textTertiary)),
          ),
      ],
    );
  }

  // ── Free text content (max 4 lines) ──
  Widget _buildFreeContent(PlotItem item) {
    return Text(
      item.freeContent,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 13,
        color: AppTheme.textSecondary,
        height: 1.5,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Edit bottom sheet (mirrors AddPlotSheet but pre-fills data)
// ═══════════════════════════════════════════════════════════════
class _EditPlotSheet extends StatefulWidget {
  final PlotItem item;
  const _EditPlotSheet({required this.item});

  @override
  State<_EditPlotSheet> createState() => _EditPlotSheetState();
}

class _EditPlotSheetState extends State<_EditPlotSheet> {
  late final TextEditingController _freeContentController;
  final _tagController = TextEditingController();
  late List<String> _tags;
  late List<TextEditingController> _stepControllers;
  late String _selectedCategory;
  late String _type;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _type = item.type;
    _selectedCategory = item.category;
    _tags = List<String>.from(item.tags);
    _freeContentController = TextEditingController(text: item.freeContent);
    _stepControllers = item.steps.isNotEmpty
        ? item.steps.map((s) => TextEditingController(text: s)).toList()
        : [TextEditingController()];
  }

  @override
  void dispose() {
    _freeContentController.dispose();
    _tagController.dispose();
    for (final c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() => _stepControllers.add(TextEditingController()));
  }

  void _removeStep(int index) {
    if (_stepControllers.length <= 1) return;
    setState(() {
      _stepControllers[index].dispose();
      _stepControllers.removeAt(index);
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _submit() {
    PlotItem updated;
    if (_type == 'steps') {
      final steps = _stepControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (steps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请至少输入一个步骤')),
        );
        return;
      }
      updated = widget.item.copyWith(
        type: 'steps',
        steps: steps,
        freeContent: '',
        category: _selectedCategory,
        tags: List<String>.from(_tags),
      );
    } else {
      final content = _freeContentController.text.trim();
      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入剧情内容')),
        );
        return;
      }
      updated = widget.item.copyWith(
        type: 'free',
        steps: [],
        freeContent: content,
        category: _selectedCategory,
        tags: List<String>.from(_tags),
      );
    }
    DataService.instance.updatePlot(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('剧情已更新')),
    );
  }

  void _addNewCategory() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新增分类'),
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
                setState(() => _selectedCategory = name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final categories = DataService.instance.plotCategories;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                '编辑剧情',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            // Type toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTypeTab('steps', '步骤拆解'),
                    _buildTypeTab('free', '自由描述'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Content
            if (_type == 'steps') ...[
              ...List.generate(_stepControllers.length, (index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.plotBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.plotColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _stepControllers[index],
                            decoration: InputDecoration(
                              hintText: '步骤 ${index + 1}',
                              hintStyle: const TextStyle(
                                  color: AppTheme.textTertiary, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      if (_stepControllers.length > 1)
                        GestureDetector(
                          onTap: () => _removeStep(index),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.remove_circle_outline,
                                size: 20, color: AppTheme.textTertiary),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GestureDetector(
                  onTap: _addStep,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.plotBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 16, color: AppTheme.plotColor),
                        SizedBox(width: 6),
                        Text(
                          '添加步骤',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.plotColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _freeContentController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: '自由描述你的剧情构思...',
                      hintStyle: TextStyle(color: AppTheme.textTertiary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Category label
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '分类',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Category pills
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...categories.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    final color = AppTheme.getCategoryColor(cat);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.plotColor
                                : color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : color,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: _addNewCategory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.add,
                          size: 16, color: AppTheme.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tags label
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '标签',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags
                    .map((tag) => Chip(
                          label: Text(tag,
                              style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () => _removeTag(tag),
                          backgroundColor: AppTheme.plotBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide.none,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ),
            if (_tags.isNotEmpty) const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    hintText: '输入标签后按回车添加',
                    hintStyle:
                        TextStyle(color: AppTheme.textTertiary, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _addTag(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Submit button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.plotColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '保存修改',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(String type, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                _type == type ? AppTheme.plotColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  _type == type ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
