import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/category_pills.dart';
import '../widgets/search_bar_widget.dart';
import '../models/plot_item.dart';
import '../services/sample_data.dart';

class PlotsScreen extends StatefulWidget {
  const PlotsScreen({super.key});

  @override
  State<PlotsScreen> createState() => _PlotsScreenState();
}

class _PlotsScreenState extends State<PlotsScreen> {
  String selectedCategory = '全部';
  String searchQuery = '';
  late List<PlotItem> allPlots;

  @override
  void initState() {
    super.initState();
    allPlots = SampleData.getPlots();
  }

  List<PlotItem> get filteredPlots {
    return allPlots.where((item) {
      final matchesCategory =
          selectedCategory == '全部' || item.category == selectedCategory;
      final matchesSearch = searchQuery.isEmpty ||
          item.displayContent.contains(searchQuery) ||
          item.category.contains(searchQuery) ||
          item.tags.any((t) => t.contains(searchQuery));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final plots = filteredPlots;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Spacer(),
                  const Text(
                    '剧情库',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  _buildHeaderButton(Icons.search, () {}),
                  const SizedBox(width: 8),
                  _buildHeaderButton(Icons.add, () {}),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            SearchBarWidget(
              placeholder: '搜索剧情内容、分类、标签...',
              onChanged: (value) => setState(() => searchQuery = value),
            ),
            const SizedBox(height: 16),

            // Category pills
            CategoryPills(
              categories: SampleData.plotCategories,
              selected: selectedCategory,
              onSelect: (cat) => setState(() => selectedCategory = cat),
              onAdd: () {},
            ),
            const SizedBox(height: 12),

            // Filter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    '共 ${plots.length} 条剧情',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sort, size: 14, color: AppTheme.textTertiary),
                          SizedBox(width: 4),
                          Text(
                            '最新',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Plot cards list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: plots.length,
                itemBuilder: (context, index) {
                  return _buildPlotCard(plots[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildPlotCard(PlotItem item) {
    final categoryColor = AppTheme.getCategoryColor(item.category);
    final categoryBgColor = AppTheme.getCategoryBgColor(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: category + tags + favorite
          Row(
            children: [
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // User tags
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: item.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Favorite button
              GestureDetector(
                onTap: () {
                  setState(() {
                    final idx = allPlots.indexOf(item);
                    if (idx != -1) {
                      allPlots[idx] = item.copyWith(isFavorite: !item.isFavorite);
                    }
                  });
                },
                child: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: item.isFavorite
                      ? const Color(0xFFEF4444)
                      : AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Content
          if (item.type == 'steps') _buildStepsContent(item) else _buildFreeContent(item),

          const SizedBox(height: 14),

          // Timestamp
          Text(
            _formatTime(item.createdAt),
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsContent(PlotItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: item.steps.asMap().entries.map((e) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: e.key < item.steps.length - 1 ? 8 : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.getCategoryBgColor(item.category),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${e.key + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getCategoryColor(item.category),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  e.value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFreeContent(PlotItem item) {
    return Text(
      item.freeContent,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 13,
        color: AppTheme.textSecondary,
        height: 1.5,
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
