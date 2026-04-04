import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

void showAddVocabularySheet(BuildContext context, {VocabularyItem? item}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _AddVocabularyPage(item: item),
    ),
  );
}

class _AddVocabularyPage extends StatefulWidget {
  final VocabularyItem? item;
  const _AddVocabularyPage({this.item});

  @override
  State<_AddVocabularyPage> createState() => _AddVocabularyPageState();
}

class _AddVocabularyPageState extends State<_AddVocabularyPage> {
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  String _selectedCategory = '';
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    final cats = DataService.instance.vocabularyCategories;
    if (widget.item != null) {
      _contentController.text = widget.item!.content;
      _tags.addAll(widget.item!.tags);
      _selectedCategory = widget.item!.category;
      _isFavorite = widget.item!.isFavorite;
    } else if (cats.isNotEmpty) {
      _selectedCategory = cats.first;
    }
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
        title: Text('新增分类', style: AppTheme.headingStyleWith(fontSize: 18)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '输入分类名称',
            hintStyle: TextStyle(color: AppTheme.textPrimary.withAlpha(100)),
            border: OutlineInputBorder(borderRadius: AppTheme.wobblySmall, borderSide: const BorderSide(color: AppTheme.border, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: AppTheme.wobblySmall, borderSide: const BorderSide(color: AppTheme.border, width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: AppTheme.wobblySmall, borderSide: const BorderSide(color: AppTheme.secondary, width: 2)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消', style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                DataService.instance.addCategory('vocabulary', name);
                setState(() => _selectedCategory = name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
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

    if (widget.item != null) {
      final updated = widget.item!.copyWith(
        content: content,
        category: _selectedCategory,
        tags: List.from(_tags),
        isFavorite: _isFavorite,
      );
      DataService.instance.updateVocabulary(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('词汇已更新')),
      );
    } else {
      final item = VocabularyItem(
        id: DataService.generateId(),
        content: content,
        category: _selectedCategory,
        tags: List.from(_tags),
        isFavorite: _isFavorite,
        createdAt: DateTime.now(),
      );
      DataService.instance.addVocabulary(item);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('词汇添加成功')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = DataService.instance.vocabularyCategories;
    final date = widget.item?.createdAt ?? DateTime.now();
    final dateString = "${date.year}年${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leadingWidth: 70,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '取消',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ),
        title: Text(
          widget.item != null ? '编辑词汇' : '新建词汇',
          style: AppTheme.headingStyleWith(fontSize: 18),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: AppTheme.wobblySmall,
                        border: Border.all(color: AppTheme.border, width: 2),
                      ),
                      child: TextField(
                        controller: _contentController,
                        maxLines: 8,
                        minLines: 4,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '输入词汇或短句...',
                          hintStyle: TextStyle(
                              color: AppTheme.textPrimary.withAlpha(100), fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Category label
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '分类',
                      style: AppTheme.headingStyleWith(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Category pills
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        ...categories.map((cat) {
                          final isSelected = cat == _selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.textPrimary
                                      : AppTheme.muted,
                                  borderRadius: AppTheme.wobblyPill,
                                  border: Border.all(
                                    color: isSelected ? AppTheme.border : AppTheme.border.withAlpha(60),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textPrimary,
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
                              color: AppTheme.muted,
                              borderRadius: AppTheme.wobblyPill,
                              border: Border.all(color: AppTheme.border.withAlpha(60), width: 1),
                            ),
                            child: const Icon(Icons.add,
                                size: 16, color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tags
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '标签',
                      style: AppTheme.headingStyleWith(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags
                          .map((tag) => Container(
                                height: 30,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.muted,
                                  borderRadius: AppTheme.wobblyPill,
                                  border: Border.all(color: AppTheme.border.withAlpha(60), width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(tag,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textPrimary)),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => _removeTag(tag),
                                      child: const Icon(Icons.close,
                                          size: 14,
                                          color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  if (_tags.isNotEmpty) const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: AppTheme.wobblySmall,
                        border: Border.all(color: AppTheme.border, width: 1.5),
                      ),
                      child: TextField(
                        controller: _tagController,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '输入标签后按回车添加',
                          hintStyle: TextStyle(
                              color: AppTheme.textPrimary.withAlpha(100), fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _addTag(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom toolbar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.background,
              border: Border(top: BorderSide(color: AppTheme.muted, width: 1.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: AppTheme.wobblyPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(dateString, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                  child: Icon(
                    _isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 22,
                    color: _isFavorite
                        ? AppTheme.accent
                        : AppTheme.textTertiary,
                  ),
                ),
                if (widget.item != null) ...[
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      DataService.instance.deleteVocabulary(widget.item!.id);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.accentSoft,
                        borderRadius: AppTheme.wobblySmall,
                        border: Border.all(color: AppTheme.accent, width: 1.5),
                      ),
                      child: const Icon(Icons.delete_outline, size: 18, color: AppTheme.accent),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

