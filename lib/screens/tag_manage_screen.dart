import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../models/material_item.dart';
import '../models/vocabulary_item.dart';
import '../models/inspiration_item.dart';
import '../models/plot_item.dart';

class TagManageScreen extends StatefulWidget {
  const TagManageScreen({super.key});

  @override
  State<TagManageScreen> createState() => _TagManageScreenState();
}

class _TagManageScreenState extends State<TagManageScreen> {
  final _ds = DataService.instance;
  String? _selectedTag;

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _ds.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _ds.removeListener(_onDataChanged);
    super.dispose();
  }

  int _tagCount(String tag) {
    int count = 0;
    for (final m in _ds.materials) {
      if (m.tags.contains(tag)) count++;
    }
    for (final v in _ds.vocabulary) {
      if (v.tags.contains(tag)) count++;
    }
    for (final i in _ds.inspirations) {
      if (i.tags.contains(tag)) count++;
    }
    for (final p in _ds.plots) {
      if (p.tags.contains(tag)) count++;
    }
    return count;
  }

  List<dynamic> _itemsWithTag(String tag) {
    final items = <dynamic>[];
    for (final m in _ds.materials) {
      if (m.tags.contains(tag)) items.add(m);
    }
    for (final v in _ds.vocabulary) {
      if (v.tags.contains(tag)) items.add(v);
    }
    for (final i in _ds.inspirations) {
      if (i.tags.contains(tag)) items.add(i);
    }
    for (final p in _ds.plots) {
      if (p.tags.contains(tag)) items.add(p);
    }
    return items;
  }

  String _itemTypeLabel(dynamic item) {
    if (item is MaterialItem) return '素材';
    if (item is VocabularyItem) return '词汇';
    if (item is InspirationItem) return '灵感';
    if (item is PlotItem) return '剧情';
    return '';
  }

  Color _itemTypeColor(dynamic item) {
    if (item is MaterialItem) return AppTheme.materialColor;
    if (item is VocabularyItem) return AppTheme.vocabularyColor;
    if (item is InspirationItem) return AppTheme.inspirationColor;
    if (item is PlotItem) return AppTheme.plotColor;
    return AppTheme.textSecondary;
  }

  String _itemContent(dynamic item) {
    if (item is MaterialItem) return item.content;
    if (item is VocabularyItem) return item.content;
    if (item is InspirationItem) return item.title ?? item.content;
    if (item is PlotItem) return item.displayContent;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final tags = _ds.allTags.toList()..sort();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('标签管理',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: tags.isEmpty
          ? const Center(
              child: Text('暂无标签',
                  style:
                      TextStyle(color: AppTheme.textTertiary, fontSize: 16)))
          : Column(
              children: [
                // Tag chips
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: tags.map((tag) {
                      final count = _tagCount(tag);
                      final isSelected = _selectedTag == tag;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTag = isSelected ? null : tag;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.inspirationColor
                                : AppTheme.inspirationBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$tag ($count)',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.inspirationColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Items list for selected tag
                if (_selectedTag != null) ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '包含"$_selectedTag"的内容',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _itemsWithTag(_selectedTag!).length,
                      itemBuilder: (context, index) {
                        final item = _itemsWithTag(_selectedTag!)[index];
                        final typeLabel = _itemTypeLabel(item);
                        final typeColor = _itemTypeColor(item);
                        final content = _itemContent(item);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: AppTheme.smallCardDecoration,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(typeLabel,
                                  style: TextStyle(
                                      color: typeColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                            title: Text(
                              content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else
                  const Expanded(
                    child: Center(
                      child: Text('点击标签查看相关内容',
                          style: TextStyle(
                              color: AppTheme.textTertiary, fontSize: 14)),
                    ),
                  ),
              ],
            ),
    );
  }
}
