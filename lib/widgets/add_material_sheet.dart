import 'package:flutter/material.dart';
import '../models/material_item.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

void showAddMaterialSheet(BuildContext context, {MaterialItem? item}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _AddMaterialSheet(item: item),
    ),
  );
}

class _AddMaterialSheet extends StatefulWidget {
  final MaterialItem? item;
  const _AddMaterialSheet({this.item});

  @override
  State<_AddMaterialSheet> createState() => _AddMaterialSheetState();
}

class _AddMaterialSheetState extends State<_AddMaterialSheet> {
  final _contentController = TextEditingController();
  final _sourceController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  String _selectedCategory = '';
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    final cats = DataService.instance.materialCategories;
    if (widget.item != null) {
      _contentController.text = widget.item!.content;
      _sourceController.text = widget.item!.source;
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
    _sourceController.dispose();
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
                DataService.instance.addCategory('material', name);
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
        const SnackBar(content: Text('请输入素材内容')),
      );
      return;
    }

    if (widget.item != null) {
      final updated = widget.item!.copyWith(
        content: content,
        category: _selectedCategory,
        tags: List.from(_tags),
        source: _sourceController.text.trim(),
        isFavorite: _isFavorite,
      );
      DataService.instance.updateMaterial(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('素材已更新')),
      );
    } else {
      final item = MaterialItem(
        id: DataService.generateId(),
        content: content,
        category: _selectedCategory,
        tags: List.from(_tags),
        source: _sourceController.text.trim(),
        createdAt: DateTime.now(),
        isFavorite: _isFavorite,
      );
      DataService.instance.addMaterial(item);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('素材添加成功')),
      );
    }
  }

  Widget _buildBottomToolbar() {
    final createdAt = widget.item?.createdAt ?? DateTime.now();
    final dateStr = '${createdAt.year}年${createdAt.month.toString().padLeft(2, '0')}月${createdAt.day.toString().padLeft(2, '0')}日 ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Text(
            dateStr,
            style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            child: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              size: 24,
              color: _isFavorite ? const Color(0xFFF59E0B) : AppTheme.textTertiary,
            ),
          ),
          if (widget.item != null) ...[
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                DataService.instance.deleteMaterial(widget.item!.id);
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.delete_outline,
                size: 24,
                color: Colors.redAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = DataService.instance.materialCategories;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
        ),
        title: Text(
          widget.item != null ? '编辑素材' : '新建素材',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('完成', style: TextStyle(color: AppTheme.materialColor, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
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
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _contentController,
                        maxLines: 10,
                        minLines: 5,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: '输入素材内容...',
                          hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Category label
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '分类',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
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
                          final color = AppTheme.getCategoryColor(cat);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedCategory = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.materialColor
                                      : color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 12,
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
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.add,
                                size: 16, color: AppTheme.textTertiary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tags
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '标签',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
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
                                height: 28,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.materialBg,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(tag, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => _removeTag(tag),
                                      child: const Icon(Icons.close, size: 14, color: AppTheme.textTertiary),
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
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _tagController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: '输入标签后按回车添加',
                          hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _addTag(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Source
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '来源',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _sourceController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: '来源（选填）',
                          hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Toolbar
          _buildBottomToolbar(),
        ],
      ),
    );
  }
}
