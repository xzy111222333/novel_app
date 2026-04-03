import 'package:flutter/material.dart';
import '../models/inspiration_item.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

void showAddInspirationSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AddInspirationSheet(),
  );
}

class _AddInspirationSheet extends StatefulWidget {
  const _AddInspirationSheet();

  @override
  State<_AddInspirationSheet> createState() => _AddInspirationSheetState();
}

class _AddInspirationSheetState extends State<_AddInspirationSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];

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

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

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
                '记录灵感',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            // Title field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: '标题（选填）',
                    hintStyle: TextStyle(color: AppTheme.textTertiary),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: '写下你的灵感...',
                    hintStyle: TextStyle(color: AppTheme.textTertiary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
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
                          backgroundColor: AppTheme.inspirationBg,
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
                    backgroundColor: AppTheme.inspirationColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '保存灵感',
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
