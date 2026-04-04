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

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _ds = DataService.instance;

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

  void _toggleFavorite(dynamic item) {
    if (item is MaterialItem) {
      _ds.toggleMaterialFavorite(item.id);
    } else if (item is VocabularyItem) {
      _ds.toggleVocabularyFavorite(item.id);
    } else if (item is InspirationItem) {
      _ds.toggleInspirationFavorite(item.id);
    } else if (item is PlotItem) {
      _ds.togglePlotFavorite(item.id);
    }
  }

  String _typeLabel(dynamic item) {
    if (item is MaterialItem) return '素材';
    if (item is VocabularyItem) return '词汇';
    if (item is InspirationItem) return '灵感';
    if (item is PlotItem) return '剧情';
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

  IconData _typeIcon(dynamic item) {
    if (item is MaterialItem) return Icons.description_outlined;
    if (item is VocabularyItem) return Icons.text_fields_outlined;
    if (item is InspirationItem) return Icons.lightbulb_outline;
    if (item is PlotItem) return Icons.auto_stories_outlined;
    return Icons.article_outlined;
  }

  String _contentPreview(dynamic item) {
    if (item is MaterialItem) return item.content;
    if (item is VocabularyItem) return item.content;
    if (item is InspirationItem) return item.title ?? item.content;
    if (item is PlotItem) return item.displayContent;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final allFavs = _ds.favorites;

    final materialFavs = allFavs.whereType<MaterialItem>().toList();
    final vocabFavs = allFavs.whereType<VocabularyItem>().toList();
    final inspirationFavs = allFavs.whereType<InspirationItem>().toList();
    final plotFavs = allFavs.whereType<PlotItem>().toList();

    final sections = <MapEntry<String, List<dynamic>>>[];
    if (materialFavs.isNotEmpty) {
      sections.add(MapEntry('素材', materialFavs));
    }
    if (vocabFavs.isNotEmpty) {
      sections.add(MapEntry('词汇', vocabFavs));
    }
    if (inspirationFavs.isNotEmpty) {
      sections.add(MapEntry('灵感', inspirationFavs));
    }
    if (plotFavs.isNotEmpty) {
      sections.add(MapEntry('剧情', plotFavs));
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('收藏夹',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            )),
      ),
      body: allFavs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_outline_rounded,
                    color: AppTheme.textTertiary,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text('暂无收藏内容',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
              itemCount: sections.fold<int>(
                  0, (sum, s) => sum + 1 + s.value.length),
              itemBuilder: (context, index) {
                int cursor = 0;
                for (final section in sections) {
                  if (index == cursor) {
                    return Padding(
                      padding: EdgeInsets.only(
                          top: cursor == 0 ? 0 : 18, bottom: 8),
                      child: Text(section.key,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          )),
                    );
                  }
                  cursor++;
                  if (index < cursor + section.value.length) {
                    final item = section.value[index - cursor];
                    return _buildFavoriteCard(item);
                  }
                  cursor += section.value.length;
                }
                return const SizedBox.shrink();
              },
            ),
    );
  }

  Widget _buildFavoriteCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppTheme.smallCardDecoration,
      child: ListTile(
        onTap: () => _openItem(item),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.muted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_typeIcon(item), color: AppTheme.textSecondary, size: 18),
        ),
        title: Text(
          _contentPreview(item),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.muted,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_typeLabel(item),
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: AppTheme.danger, size: 20),
          onPressed: () => _toggleFavorite(item),
        ),
      ),
    );
  }
}
