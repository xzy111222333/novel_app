import 'package:flutter/material.dart';
import '../models/inspiration_item.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

void showAddInspirationSheet(BuildContext context, {InspirationItem? item}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _AddInspirationPage(item: item),
    ),
  );
}

class _AddInspirationPage extends StatefulWidget {
  final InspirationItem? item;
  const _AddInspirationPage({this.item});

  @override
  State<_AddInspirationPage> createState() => _AddInspirationPageState();
}

class _AddInspirationPageState extends State<_AddInspirationPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _titleController.text = widget.item!.title ?? '';
      _contentController.text = widget.item!.content;
      _tags.addAll(widget.item!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
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

  void _submit() {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入灵感内容')),
      );
      return;
    }

    final title = _titleController.text.trim();

    if (widget.item != null) {
      final updated = widget.item!.copyWith(
        title: title.isEmpty ? null : title,
        content: content,
        tags: List.from(_tags),
      );
      DataService.instance.updateInspiration(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('灵感已更新')),
      );
    } else {
      final item = InspirationItem(
        id: DataService.generateId(),
        title: title.isEmpty ? null : title,
        content: content,
        tags: List.from(_tags),
        createdAt: DateTime.now(),
      );
      DataService.instance.addInspiration(item);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('灵感添加成功')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    final dateToShow = isEditing ? widget.item!.createdAt : DateTime.now();
    final dateString =
        '${dateToShow.year}年${dateToShow.month.toString().padLeft(2, '0')}月${dateToShow.day.toString().padLeft(2, '0')}日 ${dateToShow.hour.toString().padLeft(2, '0')}:${dateToShow.minute.toString().padLeft(2, '0')}';

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
          isEditing ? '编辑灵感' : '新建灵感',
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: '标题（选填）',
                        hintStyle: TextStyle(
                            color: AppTheme.textTertiary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Content
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          height: 1.5),
                      decoration: const InputDecoration(
                        hintText: '写下你的灵感...',
                        hintStyle: TextStyle(
                            color: AppTheme.textTertiary, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tags
                    if (_tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(tag,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color:
                                                  AppTheme.textPrimary)),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () => _removeTag(tag),
                                        child: const Icon(Icons.close,
                                            size: 14,
                                            color:
                                                AppTheme.textTertiary),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: _tagController,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: '添加标签...',
                        hintStyle: TextStyle(
                            color: AppTheme.textTertiary, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Toolbar
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                children: [
                  Text(dateString,
                      style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 11)),
                  const Spacer(),
                  if (isEditing) ...[
                    GestureDetector(
                      onTap: () {
                        DataService.instance
                            .toggleInspirationFavorite(widget.item!.id);
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
                            .deleteInspiration(widget.item!.id);
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
