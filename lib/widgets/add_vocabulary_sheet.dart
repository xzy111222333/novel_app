import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

void showAddVocabularySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AddVocabularySheet(),
  );
}

class _AddVocabularySheet extends StatefulWidget {
  const _AddVocabularySheet();

  @override
  State<_AddVocabularySheet> createState() => _AddVocabularySheetState();
}

class _AddVocabularySheetState extends State<_AddVocabularySheet> {
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    final cats = DataService.instance.vocabularyCategories;
    if (cats.isNotEmpty) _selectedCategory = cats.first;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
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
                DataService.instance.addCategory('vocabulary', name);
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
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入词汇内容')),
      );
      return;
    }

    final item = VocabularyItem(
      id: DataService.generateId(),
      content: content,
      category: _selectedCategory,
      tags: List.from(_tags),
      createdAt: DateTime.now(),
    );

    DataService.instance.addVocabulary(item);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('词汇添加成功')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final categories = DataService.instance.vocabularyCategories;

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
                '添加词汇',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: '输入词汇或短句...',
                    hintStyle: TextStyle(color: AppTheme.textTertiary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
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
                                ? AppTheme.vocabularyColor
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
                          backgroundColor: AppTheme.vocabularyBg,
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
                    backgroundColor: AppTheme.vocabularyColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '保存词汇',
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
