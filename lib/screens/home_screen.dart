import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../models/material_item.dart';
import '../models/vocabulary_item.dart';
import '../models/inspiration_item.dart';
import '../models/plot_item.dart';
import '../services/sample_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  static const _pastelPalette = [
    [Color(0xFFF3E8FF), Color(0xFF8B5CF6)], // purple
    [Color(0xFFFCE7F3), Color(0xFFEC4899)], // pink
    [Color(0xFFDBEAFE), Color(0xFF3B82F6)], // blue
    [Color(0xFFFEF3C7), Color(0xFFD97706)], // amber
    [Color(0xFFD1FAE5), Color(0xFF059669)], // green
    [Color(0xFFFFE4E6), Color(0xFFF43F5E)], // rose
  ];

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日 · ${_weekdays[date.weekday - 1]} '
        '${_formatTime(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final materials = SampleData.getMaterials();
    final vocabulary = SampleData.getVocabulary();
    final inspirations = SampleData.getInspirations();
    final plots = SampleData.getPlots();

    final todayMaterials =
        materials.where((m) => _isToday(m.createdAt)).toList();
    final todayVocabulary =
        vocabulary.where((v) => _isToday(v.createdAt)).toList();
    final todayInspirations =
        inspirations.where((i) => _isToday(i.createdAt)).toList();
    final todayPlots = plots.where((p) => _isToday(p.createdAt)).toList();

    // Random review: pick a past inspiration (not from today)
    final pastInspirations =
        inspirations.where((i) => !_isToday(i.createdAt)).toList();
    final randomInspiration = pastInspirations.isNotEmpty
        ? pastInspirations[Random().nextInt(pastInspirations.length)]
        : null;

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
                  // 1. Random Review
                  if (randomInspiration != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: _buildRandomReviewCard(randomInspiration),
                    ),

                  // 2. Today's Vocabulary
                  if (todayVocabulary.isNotEmpty) ...[
                    SectionHeader(
                      title: '今日词汇',
                      count: todayVocabulary.length,
                      onMore: () {},
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildVocabularyCard(todayVocabulary),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 3. Today's Materials
                  if (todayMaterials.isNotEmpty) ...[
                    SectionHeader(
                      title: '今日素材',
                      count: todayMaterials.length,
                      onMore: () {},
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildMaterialsCard(todayMaterials),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 4. Today's Inspirations
                  if (todayInspirations.isNotEmpty) ...[
                    SectionHeader(
                      title: '今日灵感',
                      count: todayInspirations.length,
                      onMore: () {},
                    ),
                    const SizedBox(height: 12),
                    ...todayInspirations.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildInspirationCard(item),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 5. Today's Plots
                  if (todayPlots.isNotEmpty) ...[
                    SectionHeader(
                      title: '今日剧情',
                      count: todayPlots.length,
                      onMore: () {},
                    ),
                    const SizedBox(height: 12),
                    ...todayPlots.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildPlotCard(item),
                      ),
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

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(String weekday) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '今日 · $weekday',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppTheme.textTertiary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '今天的创作积累总览',
                style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.add, size: 22, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── 1. Random Review Card ───────────────────────────────────────────────

  Widget _buildRandomReviewCard(InspirationItem item) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.textTertiary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '随机回顾',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(item.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.more_horiz,
                size: 16,
                color: AppTheme.textTertiary.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (item.title != null) ...[
            Text(
              item.title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF97316),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            item.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Vocabulary Pills ─────────────────────────────────────────────────

  Widget _buildVocabularyCard(List<VocabularyItem> items) {
    final displayItems = items.length > 5 ? items.sublist(0, 5) : items;
    final showMore = items.length > 5;

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ...displayItems.asMap().entries.map((entry) {
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
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors[1],
                ),
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
              child: Text(
                '···',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── 3. Materials Card ───────────────────────────────────────────────────

  Widget _buildMaterialsCard(List<MaterialItem> items) {
    final displayItems = items.length > 3 ? items.sublist(0, 3) : items;

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...displayItems.map((item) {
            final catColor = AppTheme.getCategoryColor(item.category);
            final catBgColor = AppTheme.getCategoryBgColor(item.category);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: catBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: catColor,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(item.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textTertiary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (items.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Center(
                child: Text(
                  '查看更多',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── 4. Inspiration Card ─────────────────────────────────────────────────

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
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: timeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(timeIcon, size: 12, color: timeColor),
                const SizedBox(width: 6),
                Text(
                  _formatTime(item.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: timeColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Plot Card ────────────────────────────────────────────────────────

  Widget _buildPlotCard(PlotItem item) {
    final catColor = AppTheme.getCategoryColor(item.category);
    final catBgColor = AppTheme.getCategoryBgColor(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: catBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: catColor,
                  ),
                ),
              ),
              Text(
                _formatTime(item.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textTertiary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.displayContent,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
