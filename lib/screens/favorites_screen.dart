import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../models/material_item.dart';
import '../models/vocabulary_item.dart';
import '../models/inspiration_item.dart';
import '../models/plot_item.dart';

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

  IconData _typeIcon(dynamic item) {
    if (item is MaterialItem) return Icons.description_outlined;
    if (item is VocabularyItem) return Icons.text_fields;
    if (item is InspirationItem) return Icons.lightbulb_outline;
    if (item is PlotItem) return Icons.auto_stories_outlined;
    return Icons.article_outlined;
  }

  Color _typeColor(dynamic item) {
    if (item is MaterialItem) return AppTheme.materialColor;
    if (item is VocabularyItem) return AppTheme.vocabularyColor;
    if (item is InspirationItem) return AppTheme.inspirationColor;
    if (item is PlotItem) return AppTheme.plotColor;
    return AppTheme.textSecondary;
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

    // Group by type
    final materialFavs =
        allFavs.whereType<MaterialItem>().toList();
    final vocabFavs =
        allFavs.whereType<VocabularyItem>().toList();
    final inspirationFavs =
        allFavs.whereType<InspirationItem>().toList();
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('收藏夹',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: allFavs.isEmpty
          ? const Center(
              child: Text('暂无收藏内容',
                  style:
                      TextStyle(color: AppTheme.textTertiary, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sections.fold<int>(
                  0, (sum, s) => sum + 1 + s.value.length),
              itemBuilder: (context, index) {
                // Map flat index to section header or item
                int cursor = 0;
                for (final section in sections) {
                  if (index == cursor) {
                    // Section header
                    return Padding(
                      padding: EdgeInsets.only(
                          top: cursor == 0 ? 0 : 20, bottom: 10),
                      child: Text(section.key,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
    final color = _typeColor(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.smallCardDecoration,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_typeIcon(item), color: color, size: 20),
        ),
        title: Text(
          _contentPreview(item),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
          ),
        ),
        subtitle: Text(_typeLabel(item),
            style: TextStyle(color: color, fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 22),
          onPressed: () => _toggleFavorite(item),
        ),
      ),
    );
  }
}
