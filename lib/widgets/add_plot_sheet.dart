import 'package:flutter/material.dart';
import '../models/plot_item.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

void showAddPlotSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AddPlotSheet(),
  );
}

class _AddPlotSheet extends StatefulWidget {
  const _AddPlotSheet();

  @override
  State<_AddPlotSheet> createState() => _AddPlotSheetState();
}

class _AddPlotSheetState extends State<_AddPlotSheet> {
  final _freeContentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  final List<TextEditingController> _stepControllers = [];
  String _selectedCategory = '';
  String _type = 'steps'; // 'steps' or 'free'

  @override
  void initState() {
    super.initState();
    final cats = DataService.instance.plotCategories;
    if (cats.isNotEmpty) _selectedCategory = cats.first;
    // Start with 2 empty steps
    _stepControllers.add(TextEditingController());
    _stepControllers.add(TextEditingController());
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
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
      final item = PlotItem(
        id: DataService.generateId(),
        type: 'steps',
        steps: steps,
        category: _selectedCategory,
        tags: List.from(_tags),
        createdAt: DateTime.now(),
      );
      DataService.instance.addPlot(item);
    } else {
      final content = _freeContentController.text.trim();
      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入剧情内容')),
        );
        return;
      }
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

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('剧情添加成功')),
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
                '添加剧情',
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _type = 'steps'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _type == 'steps'
                                ? AppTheme.plotColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '步骤拆解',
                            style: TextStyle(
                              fontSize: 14,
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
                        onTap: () => setState(() => _type = 'free'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _type == 'free'
                                ? AppTheme.plotColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '自由描述',
                            style: TextStyle(
                              fontSize: 14,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
                        onTap: () => setState(() => _selectedCategory = cat),
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
            // Tags
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
                    hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 13),
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
                    '保存剧情',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
