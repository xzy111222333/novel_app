import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _ds = DataService.instance;

  @override
  void initState() {
    super.initState();
    DataService.instance.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DataService.instance.removeListener(_onDataChanged);
    super.dispose();
  }

  String _formatNumber(int n) => NumberFormat('#,###').format(n);

  int get _todayWordCount {
    int count = 0;
    for (final m in _ds.todayMaterials) {
      count += m.content.length;
    }
    for (final v in _ds.todayVocabulary) {
      count += v.content.length;
    }
    for (final i in _ds.todayInspirations) {
      count += i.content.length + (i.title?.length ?? 0);
    }
    for (final p in _ds.todayPlots) {
      count += p.type == 'steps'
          ? p.steps.fold<int>(0, (s, step) => s + step.length)
          : p.freeContent.length;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Header
              const Text(
                '统计',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _buildHeroCard(),
              const SizedBox(height: 20),
              _buildModuleGrid(),
              const SizedBox(height: 20),
              _buildHeatmapCard(),
              const SizedBox(height: 20),
              _buildBarChartCard(),
              const SizedBox(height: 20),
              _buildShareButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Total Word Count Hero Card ──
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(Icons.edit_note_rounded, size: 26, color: Color(0xFFFF8F00)),
          ),
          const SizedBox(height: 16),
          Text(
            _formatNumber(_ds.totalWordCount),
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE65100),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '总收集字数',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFBF8A30),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '今日收集 $_todayWordCount 字',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9E7520),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2×2 Module Breakdown Grid ──
  Widget _buildModuleGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildModuleCard(
                '素材',
                _ds.materialWordCount,
                '${_ds.materials.length}条',
                AppTheme.materialColor,
                AppTheme.materialBg,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModuleCard(
                '词汇',
                _ds.vocabularyWordCount,
                '${_ds.vocabulary.length}条',
                AppTheme.vocabularyColor,
                AppTheme.vocabularyBg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildModuleCard(
                '灵感',
                _ds.inspirationWordCount,
                '${_ds.inspirations.length}条',
                AppTheme.inspirationColor,
                AppTheme.inspirationBg,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModuleCard(
                '剧情',
                _ds.plotWordCount,
                '${_ds.plots.length}条',
                AppTheme.plotColor,
                AppTheme.plotBg,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    String label,
    int wordCount,
    String itemCount,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatNumber(wordCount),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '字 · $itemCount',
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ── Weekly Activity Heatmap ──
  Widget _buildHeatmapCard() {
    final activity = _ds.getWeeklyActivity();
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final dateRange =
        '${monday.month}/${monday.day} - ${sunday.month}/${sunday.day}';

    const dayLabels = ['一', '二', '三', '四', '五', '六', '日'];
    const moduleKeys = ['materials', 'vocabulary', 'inspirations', 'plots'];
    const moduleLabels = ['素材', '词汇', '灵感', '剧情'];
    const moduleColors = [
      AppTheme.materialColor,
      AppTheme.vocabularyColor,
      AppTheme.inspirationColor,
      AppTheme.plotColor,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              const Text(
                '本周活动',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateRange,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Day labels row
          Row(
            children: [
              const SizedBox(width: 48),
              ...dayLabels.map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          // Module rows
          ...List.generate(4, (rowIdx) {
            final counts = activity[moduleKeys[rowIdx]] ?? List.filled(7, 0);
            return Padding(
              padding: EdgeInsets.only(bottom: rowIdx < 3 ? 10 : 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Text(
                      moduleLabels[rowIdx],
                      style: TextStyle(
                        fontSize: 11,
                        color: moduleColors[rowIdx],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...List.generate(7, (colIdx) {
                    final active = counts[colIdx] > 0;
                    return Expanded(
                      child: Center(
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active
                                ? moduleColors[rowIdx].withValues(alpha: 0.2)
                                : const Color(0xFFF3F4F6),
                          ),
                          child: active
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: moduleColors[rowIdx],
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFE0E0E0),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Daily Word Count Bar Chart ──
  Widget _buildBarChartCard() {
    final dailyCounts = _ds.getDailyWordCounts();
    final maxCount = dailyCounts.reduce((a, b) => max(a, b));
    const dayLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    const barColor = Color(0xFF4A8B9F);
    const barBg = Color(0xFFD0E8F2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            '每日字数',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 170,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final ratio =
                    maxCount > 0 ? dailyCounts[i] / maxCount : 0.0;
                final barHeight = max(4.0, 120.0 * ratio);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (dailyCounts[i] > 0)
                          Text(
                            '${dailyCounts[i]}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: barColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                barColor.withValues(alpha: 0.4),
                                barBg,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayLabels[i],
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Share Button ──
  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('功能开发中'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.textPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share_outlined, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text(
              '分享统计',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
