import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../models/material_item.dart';
import '../models/vocabulary_item.dart';
import '../models/inspiration_item.dart';
import '../models/plot_item.dart';
import '../widgets/add_inspiration_sheet.dart';
import '../widgets/add_material_sheet.dart';
import '../widgets/add_plot_sheet.dart';
import '../widgets/add_vocabulary_sheet.dart';

class TagManageScreen extends StatefulWidget {
  const TagManageScreen({super.key});

  @override
  State<TagManageScreen> createState() => _TagManageScreenState();
}

class _TagManageScreenState extends State<TagManageScreen> {
  final _ds = DataService.instance;
  String? _selectedTag;

  Future<void> _renameSelectedTag() async {
    final current = _selectedTag;
    if (current == null) {
      return;
    }
    final controller = TextEditingController(text: current);
    final next = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名标签'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入新的标签名'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (next != null && next.isNotEmpty && next != current) {
      _ds.renameTag(current, next);
      setState(() => _selectedTag = next);
    }
  }

  Future<void> _deleteSelectedTag() async {
    final current = _selectedTag;
    if (current == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除标签'),
        content: Text('删除后，会从所有内容中移除“$current”标签。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '删除',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _ds.deleteTag(current);
      setState(() => _selectedTag = null);
    }
  }

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

  String _itemContent(dynamic item) {
    if (item is MaterialItem) return item.content;
    if (item is VocabularyItem) return item.content;
    if (item is InspirationItem) return item.title ?? item.content;
    if (item is PlotItem) return item.displayContent;
    return '';
  }

  void _openItem(dynamic item) {
    if (item is MaterialItem) {
      showAddMaterialSheet(context, item: item);
    } else if (item is VocabularyItem) {
      showAddVocabularySheet(context, item: item);
    } else if (item is InspirationItem) {
      showAddInspirationSheet(context, item: item);
    } else if (item is PlotItem) {
      showAddPlotSheet(context, item: item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags = _ds.allTags.toList()..sort();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('标签管理',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            )),
      ),
      body: tags.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.label_outlined,
                        color: AppTheme.textTertiary, size: 24),
                  ),
                  const SizedBox(height: 12),
                  const Text('暂无标签',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            )
          : Column(
              children: [
                // Tag chips — scrollable to fix overflow
                Expanded(
                  flex: _selectedTag != null ? 0 : 1,
                  child: _selectedTag != null
                      ? Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
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
                                    height: 28,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.textPrimary
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: isSelected ? null : Border.all(color: AppTheme.divider),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$tag ($count)',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppTheme.textPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
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
                                  height: 28,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.textPrimary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: isSelected ? null : Border.all(color: AppTheme.divider),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$tag ($count)',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),

                // Items list for selected tag
                if (_selectedTag != null) ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '包含“$_selectedTag”的内容',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _renameSelectedTag,
                          child: const Text('重命名'),
                        ),
                        TextButton(
                          onPressed: _deleteSelectedTag,
                          child: const Text(
                            '删除',
                            style: TextStyle(color: AppTheme.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: _itemsWithTag(_selectedTag!).length,
                      itemBuilder: (context, index) {
                        final item = _itemsWithTag(_selectedTag!)[index];
                        final typeLabel = _itemTypeLabel(item);
                        final content = _itemContent(item);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: AppTheme.smallCardDecoration,
                          child: ListTile(
                            onTap: () => _openItem(item),
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(typeLabel,
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                            ),
                            title: Text(
                              content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else if (_selectedTag == null) ...[
                  const SizedBox.shrink(),
                ],
              ],
            ),
    );
  }
}
