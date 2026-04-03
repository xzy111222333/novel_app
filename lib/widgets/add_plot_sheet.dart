import 'package:flutter/material.dart';
import '../models/plot_item.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

void showAddPlotSheet(BuildContext context, {PlotItem? item}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _AddPlotPage(item: item),
    ),
  );
}

class _AddPlotPage extends StatefulWidget {
  final PlotItem? item;
  const _AddPlotPage({this.item});

  @override
  State<_AddPlotPage> createState() => _AddPlotPageState();
}

class _AddPlotPageState extends State<_AddPlotPage> {
  final _freeContentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  final List<TextEditingController> _stepControllers = [];
  String _selectedCategory = '';
  String _type = 'steps';

  @override
  void initState() {
    super.initState();
    final cats = DataService.instance.plotCategories;
    if (widget.item != null) {
      _type = widget.item!.type;
      _selectedCategory = widget.item!.category;
      _tags.addAll(widget.item!.tags);
      _freeContentController.text = widget.item!.freeContent;
      if (widget.item!.steps.isNotEmpty) {
        _stepControllers.addAll(
            widget.item!.steps.map((s) => TextEditingController(text: s)));
      } else {
        _stepControllers.add(TextEditingController());
      }
    } else {
      if (cats.isNotEmpty) _selectedCategory = cats.first;
      _stepControllers.add(TextEditingController());
      _stepControllers.add(TextEditingController());
    }
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
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

  void _submit() {
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

      if (widget.item != null) {
        final updated = widget.item!.copyWith(
          type: 'steps',
          steps: steps,
          freeContent: '',
          category: _selectedCategory,
          tags: List.from(_tags),
        );
        DataService.instance.updatePlot(updated);
      } else {
        final item = PlotItem(
          id: DataService.generateId(),
          type: 'steps',
          steps: steps,
          category: _selectedCategory,
          tags: List.from(_tags),
          createdAt: DateTime.now(),
        );
        DataService.instance.addPlot(item);
      }
    } else {
      final content = _freeContentController.text.trim();
      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入剧情内容')),
        );
        return;
      }

      if (widget.item != null) {
        final updated = widget.item!.copyWith(
          type: 'free',
          steps: [],
          freeContent: content,
          category: _selectedCategory,
          tags: List.from(_tags),
        );
        DataService.instance.updatePlot(updated);
      } else {
        final item = PlotItem(
          id: DataService.generateId(),
          type: 'free',
          freeContent: content,
          category: _selectedCategory,
          tags: List.from(_tags),
          createdAt: DateTime.now(),
        );
        DataService.instance.addPlot(item);
      }
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(widget.item != null ? '剧情已更新' : '剧情添加成功')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final categories = DataService.instance.plotCategories;
    final createdAt = widget.item?.createdAt ?? DateTime.now();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14)),
        ),
        title: Text(
          widget.item != null ? '编辑情节' : '新建情节',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('完成',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Type toggle — dark style
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _type = 'steps'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _type == 'steps'
                                        ? const Color(0xFF1A1A1A)
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '步骤拆解',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _type == 'steps'
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _type = 'free'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _type == 'free'
                                        ? const Color(0xFF1A1A1A)
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '自由描述',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _type == 'free'
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Content area based on type
                    if (_type == 'steps') ...[
                      ...List.generate(_stepControllers.length,
                          (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: TextField(
                                    controller:
                                        _stepControllers[index],
                                    style: const TextStyle(
                                        fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: '步骤 ${index + 1}',
                                      hintStyle: const TextStyle(
                                          color:
                                              AppTheme.textTertiary,
                                          fontSize: 14),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10),
                                    ),
                                  ),
                                ),
                              ),
                              if (_stepControllers.length > 1)
                                GestureDetector(
                                  onTap: () => _removeStep(index),
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.only(left: 8),
                                    child: Icon(
                                        Icons
                                            .remove_circle_outline,
                                        size: 20,
                                        color:
                                            AppTheme.textTertiary),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: GestureDetector(
                          onTap: _addStep,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add,
                                    size: 16,
                                    color: AppTheme.textSecondary),
                                SizedBox(width: 4),
                                Text(
                                  '添加步骤',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _freeContentController,
                            maxLines: 8,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: '自由描述你的剧情构思...',
                              hintStyle: TextStyle(
                                  color: AppTheme.textTertiary,
                                  fontSize: 14),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 16),
                      child: Text('分类',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary)),
                    ),
                    const SizedBox(height: 8),
                    // Category pills — gray style
                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        children: [
                          ...categories.map((cat) {
                            final isSelected =
                                cat == _selectedCategory;
                            return Padding(
                              padding:
                                  const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _selectedCategory = cat),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1A1A1A)
                                        : const Color(0xFFF5F5F5),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textSecondary,
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
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.add,
                                  size: 16,
                                  color: AppTheme.textTertiary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tags
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16),
                      child: Text('标签',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary)),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags
                            .map((tag) => Container(
                                  height: 28,
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFFF5F5F5),
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Text(tag,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme
                                                  .textSecondary)),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () =>
                                            _removeTag(tag),
                                        child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: AppTheme
                                                .textTertiary),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    if (_tags.isNotEmpty)
                      const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _tagController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: '输入标签后按回车添加',
                            hintStyle: TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 14),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10),
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Bottom Toolbar
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFF3F4F6),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _formatDate(createdAt),
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  if (widget.item != null) ...[
                    GestureDetector(
                      onTap: () {
                        DataService.instance
                            .togglePlotFavorite(widget.item!.id);
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Icon(
                        widget.item!.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 24,
                        color: widget.item!.isFavorite
                            ? const Color(0xFFF59E0B)
                            : AppTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        DataService.instance
                            .deletePlot(widget.item!.id);
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.delete_outline,
                          size: 24, color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
