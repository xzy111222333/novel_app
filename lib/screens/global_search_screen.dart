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

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _ds = DataService.instance;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];

  void _onDataChanged() {
    if (mounted) {
      _doSearch(_searchController.text);
    }
  }

  @override
  void initState() {
    super.initState();
    _ds.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _ds.removeListener(_onDataChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _doSearch(String query) {
    setState(() {
      _results = _ds.globalSearch(query.trim());
    });
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'material':
        return '素材';
      case 'vocabulary':
        return '词汇';
      case 'inspiration':
        return '灵感';
      case 'plot':
        return '剧情';
      default:
        return '';
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'material':
        return AppTheme.materialColor;
      case 'vocabulary':
        return AppTheme.vocabularyColor;
      case 'inspiration':
        return AppTheme.inspirationColor;
      case 'plot':
        return AppTheme.plotColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _contentPreview(Map<String, dynamic> result) {
    final item = result['item'];
    if (item is MaterialItem) return item.content;
    if (item is VocabularyItem) return item.content;
    if (item is InspirationItem) return item.title ?? item.content;
    if (item is PlotItem) return item.displayContent;
    return '';
  }

  String _categoryTag(Map<String, dynamic> result) {
    final item = result['item'];
    if (item is MaterialItem) return item.category;
    if (item is VocabularyItem) return item.category;
    if (item is PlotItem) return item.category;
    return '';
  }

  void _openResult(Map<String, dynamic> result) {
    final item = result['item'];
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
    final query = _searchController.text.trim();

    // Group results by type
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final r in _results) {
      final type = r['type'] as String;
      grouped.putIfAbsent(type, () => []);
      grouped[type]!.add(r);
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('全局搜索',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: SizedBox(
              height: 36,
              child: Container(
                decoration: AppTheme.smallCardDecoration,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _doSearch,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: '搜索素材、词汇、灵感、剧情...',
                    hintStyle:
                        const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.textTertiary, size: 18),
                    prefixIconConstraints: const BoxConstraints(minWidth: 36),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppTheme.textTertiary, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              _doSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child: query.isEmpty
                ? const Center(
                    child: Text('搜索素材、词汇、灵感、剧情...',
                        style: TextStyle(
                            color: AppTheme.textTertiary, fontSize: 12)),
                  )
                : _results.isEmpty
                    ? const Center(
                        child: Text('未找到相关内容',
                            style: TextStyle(
                                color: AppTheme.textTertiary, fontSize: 12)),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: grouped.entries.expand((entry) {
                          final type = entry.key;
                          final items = entry.value;
                          final color = _typeColor(type);
                          return [
                            // Section header
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${_typeLabel(type)} (${items.length})',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            // Items
                            ...items.map((r) => _buildResultCard(r)),
                          ];
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final type = result['type'] as String;
    final color = _typeColor(type);
    final content = _contentPreview(result);
    final category = _categoryTag(result);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: AppTheme.smallCardDecoration,
      child: ListTile(
        onTap: () => _openResult(result),
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(_typeLabel(type),
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
        title: Text(
          content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
        ),
        trailing: category.isNotEmpty
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.getCategoryBgColor(category),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(category,
                    style: TextStyle(
                      color: AppTheme.getCategoryColor(category),
                      fontSize: 10,
                    )),
              )
            : null,
      ),
    );
  }
}
