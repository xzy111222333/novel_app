import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../models/material_item.dart';
import '../models/vocabulary_item.dart';
import '../models/inspiration_item.dart';
import '../models/plot_item.dart';
import '../services/data_service.dart';
import '../widgets/add_material_sheet.dart';
import '../widgets/add_vocabulary_sheet.dart';
import '../widgets/add_inspiration_sheet.dart';
import '../widgets/add_plot_sheet.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;
  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  static const _pastelPalette = [
    [Color(0xFFD1FAE5), Color(0xFF059669)], // mint green
    [Color(0xFFFEF3C7), Color(0xFFD97706)], // light yellow
    [Color(0xFFFCE7F3), Color(0xFFEC4899)], // peach pink
    [Color(0xFFDBEAFE), Color(0xFF3B82F6)], // light blue
    [Color(0xFFF3E8FF), Color(0xFF8B5CF6)], // light purple
    [Color(0xFFFFE4E6), Color(0xFFF43F5E)], // light rose
  ];

  // Cached random inspiration so it doesn't change on every rebuild
  InspirationItem? _randomInspiration;

  @override
  void initState() {
    super.initState();
    DataService.instance.addListener(_onDataChanged);
    _refreshRandomInspiration();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DataService.instance.removeListener(_onDataChanged);
    super.dispose();
  }

  void _refreshRandomInspiration() {
    _randomInspiration = DataService.instance.getRandomPastInspiration();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日 · ${_weekdays[date.weekday - 1]} '
        '${_formatTime(date)}';
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}天前';
    if (diff.inHours > 0) return '${diff.inHours}小时前';
    if (diff.inMinutes > 0) return '${diff.inMinutes}分钟前';
    return '刚刚';
  }

  // ── Quick Add Sheet ─────────────────────────────────────────────────────

  void _showQuickAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '快速添加',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickAddItem('素材', Icons.auto_stories_rounded,
                    const Color(0xFFD1FAE5), const Color(0xFF059669), () {
                  Navigator.pop(ctx);
                  showAddMaterialSheet(context);
                }),
                _quickAddItem('词汇', Icons.text_fields_rounded,
                    const Color(0xFFFCE7F3), const Color(0xFFEC4899), () {
                  Navigator.pop(ctx);
                  showAddVocabularySheet(context);
                }),
                _quickAddItem('灵感', Icons.lightbulb_outline_rounded,
                    const Color(0xFFFEF3C7), const Color(0xFFD97706), () {
                  Navigator.pop(ctx);
                  showAddInspirationSheet(context);
                }),
                _quickAddItem('剧情', Icons.movie_creation_outlined,
                    const Color(0xFFDBEAFE), const Color(0xFF3B82F6), () {
                  Navigator.pop(ctx);
                  showAddPlotSheet(context);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAddItem(String label, IconData icon, Color bg, Color fg,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: fg, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Three-dot menu on random review ─────────────────────────────────────

  void _showReviewMenu(InspirationItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _menuItem(Icons.auto_stories_rounded, '转素材', () {
              Navigator.pop(ctx);
              DataService.instance.convertInspirationToMaterial(item);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('已转为素材'),
                    behavior: SnackBarBehavior.floating),
              );
            }),
            _menuItem(Icons.text_fields_rounded, '转词汇', () {
              Navigator.pop(ctx);
              DataService.instance.convertInspirationToVocabulary(item);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('已转为词汇'),
                    behavior: SnackBarBehavior.floating),
              );
            }),
            _menuItem(
              item.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              item.isFavorite ? '取消收藏' : '收藏',
              () {
                Navigator.pop(ctx);
                DataService.instance.toggleInspirationFavorite(item.id);
              },
            ),
            _menuItem(Icons.refresh_rounded, '换一条', () {
              Navigator.pop(ctx);
              setState(() => _refreshRandomInspiration());
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 22, color: AppTheme.textSecondary),
      title: Text(label,
          style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ds = DataService.instance;
    final todayMats = ds.todayMaterials;
    final todayVocab = ds.todayVocabulary;
    final todayInsp = ds.todayInspirations;
    final todayPlots = ds.todayPlots;
    final now = DateTime.now();
    final todayWeekday = _weekdays[now.weekday - 1];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(todayWeekday),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  // Random Review
                  if (_randomInspiration != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: _buildRandomReviewCard(_randomInspiration!),
                    ),

                  // Today Vocabulary
                  SectionHeader(
                    title: '今日词汇',
                    count: todayVocab.length,
                    onMore: () => widget.onNavigateToTab?.call(2),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: todayVocab.isEmpty
                        ? _emptyHint('今日暂无新词汇')
                        : _buildVocabularyWrap(todayVocab),
                  ),
                  const SizedBox(height: 24),

                  // Today Materials
                  SectionHeader(
                    title: '今日素材',
                    count: todayMats.length,
                    onMore: () => widget.onNavigateToTab?.call(1),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: todayMats.isEmpty
                        ? _emptyHint('今日暂无新素材')
                        : _buildMaterialsList(todayMats),
                  ),
                  const SizedBox(height: 24),

                  // Today Inspirations
                  SectionHeader(
                    title: '今日灵感',
                    count: todayInsp.length,
                    onMore: () => widget.onNavigateToTab?.call(3),
                  ),
                  const SizedBox(height: 12),
                  if (todayInsp.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _emptyHint('今日暂无新灵感'),
                    )
                  else
                    ...todayInsp.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildInspirationCard(item),
                        )),
                  const SizedBox(height: 24),

                  // Today Plots (only show if any)
                  if (todayPlots.isNotEmpty) ...[
                    SectionHeader(
                      title: '今日剧情',
                      count: todayPlots.length,
                    ),
                    const SizedBox(height: 12),
                    ...todayPlots.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildPlotCard(item),
                        )),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text,
          style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(String weekday) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Column(
            children: [
              Text(
                '今日 · $weekday',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '写作灵感收集',
                style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
              ),
            ],
          ),
          GestureDetector(
            onTap: _showQuickAddMenu,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.textPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.add, size: 22, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Random Review Card ──────────────────────────────────────────────────

  Widget _buildRandomReviewCard(InspirationItem item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8ED),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(item.createdAt),
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textTertiary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _relativeTime(item.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showReviewMenu(item),
                child: const Icon(Icons.more_horiz,
                    size: 20, color: AppTheme.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (item.title != null) ...[
            Text(
              item.title!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            item.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '随机回顾',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  // ── Vocabulary Wrap ─────────────────────────────────────────────────────

  Widget _buildVocabularyWrap(List<VocabularyItem> items) {
    final display = items.length > 5 ? items.sublist(0, 5) : items;
    final showMore = items.length > 5;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...display.asMap().entries.map((entry) {
          final colors = _pastelPalette[entry.key % _pastelPalette.length];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colors[0],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              entry.value.content,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500, color: colors[1]),
            ),
          );
        }),
        if (showMore)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('···',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textTertiary)),
          ),
      ],
    );
  }

  // ── Materials List ──────────────────────────────────────────────────────

  Widget _buildMaterialsList(List<MaterialItem> items) {
    final display = items.length > 3 ? items.sublist(0, 3) : items;

    return Column(
      children: display.map((item) {
        final catColor = AppTheme.getCategoryColor(item.category);
        final catBgColor = AppTheme.getCategoryBgColor(item.category);
        // Tinted card background based on category
        final cardBg = catColor.withValues(alpha: 0.06);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: catBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(item.category,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: catColor)),
                  ),
                  const Spacer(),
                  Text(_formatTime(item.createdAt),
                      style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textTertiary.withValues(alpha: 0.6))),
                ],
              ),
              const SizedBox(height: 8),
              Text(item.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.6)),
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: item.tags.map((t) => Text('#$t',
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textTertiary))).toList(),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Inspiration Card ────────────────────────────────────────────────────

  Widget _buildInspirationCard(InspirationItem item) {
    final hour = item.createdAt.hour;
    final isMorning = hour >= 6 && hour < 18;
    final timeIcon =
        isMorning ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    final timeColor =
        isMorning ? const Color(0xFFF59E0B) : const Color(0xFF818CF8);
    final timeBg =
        isMorning ? const Color(0xFFFEF3C7) : const Color(0xFFEEF2FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: timeBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: timeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(timeIcon, size: 12, color: timeColor),
                    const SizedBox(width: 6),
                    Text(_formatTime(item.createdAt),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: timeColor)),
                  ],
                ),
              ),
              if (item.tags.isNotEmpty) ...[
                const SizedBox(width: 8),
                ...item.tags.take(2).map((t) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text('#$t',
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.textTertiary)),
                    )),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (item.title != null) ...[
            Text(item.title!,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
          ],
          Text(item.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary, height: 1.6)),
        ],
      ),
    );
  }

  // ── Plot Card ───────────────────────────────────────────────────────────

  Widget _buildPlotCard(PlotItem item) {
    final catColor = AppTheme.getCategoryColor(item.category);
    final catBgColor = AppTheme.getCategoryBgColor(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: catColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: catBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item.category,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: catColor)),
              ),
              const Spacer(),
              Text(_formatTime(item.createdAt),
                  style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textTertiary.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.displayContent,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}
