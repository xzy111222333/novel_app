import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/sample_data.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String selectedTimeRange = '周';

  // Precomputed word counts
  late final int materialWords;
  late final int vocabularyWords;
  late final int inspirationWords;
  late final int plotWords;
  late final int totalWords;

  // Fixed daily word counts for demo bar chart (Mon–Sun)
  final List<int> dailyWordCounts = [320, 580, 210, 460, 720, 150, 390];

  // Fixed heatmap activity pattern (rows: modules, cols: Mon–Sun)
  // true = has activity, false = no activity
  final List<List<bool>> heatmapData = [
    [true, false, true, true, false, true, false],  // 素材
    [false, true, true, false, true, false, true],   // 词汇
    [true, true, false, false, true, true, false],   // 灵感
    [false, false, true, true, false, true, true],   // 剧情
  ];

  @override
  void initState() {
    super.initState();
    final materials = SampleData.getMaterials();
    final vocabulary = SampleData.getVocabulary();
    final inspirations = SampleData.getInspirations();
    final plots = SampleData.getPlots();

    materialWords = materials.fold<int>(0, (sum, m) => sum + m.wordCount);
    vocabularyWords = vocabulary.fold<int>(0, (sum, v) => sum + v.wordCount);
    inspirationWords = inspirations.fold<int>(0, (sum, i) => sum + i.wordCount);
    plotWords = plots.fold<int>(0, (sum, p) => sum + p.wordCount);
    totalWords = materialWords + vocabularyWords + inspirationWords + plotWords;
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
              _buildTimeRangeCard(),
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.edit_outlined, size: 28, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            '$totalWords',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '累计收集字数',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          // 2x2 module word count grid
          Row(
            children: [
              Expanded(
                child: _buildModuleStat(
                  '素材', '$materialWords 字',
                  AppTheme.materialColor, AppTheme.materialBg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModuleStat(
                  '词汇', '$vocabularyWords 字',
                  AppTheme.vocabularyColor, AppTheme.vocabularyBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildModuleStat(
                  '灵感', '$inspirationWords 字',
                  AppTheme.inspirationColor, AppTheme.inspirationBg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModuleStat(
                  '剧情', '$plotWords 字',
                  AppTheme.plotColor, AppTheme.plotBg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleStat(String label, String value, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Time Range Card ──
  Widget _buildTimeRangeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Toggle buttons
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ['周', '月', '年'].map((range) {
                final isSelected = range == selectedTimeRange;
                return GestureDetector(
                  onTap: () => setState(() => selectedTimeRange = range),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.textPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      range,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.textTertiary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Date range with arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: const Icon(Icons.chevron_left, size: 20, color: AppTheme.textTertiary),
              ),
              const SizedBox(width: 12),
              const Text(
                '本周 03/30 → 04/05',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {},
                child: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Activity Heatmap Grid ──
  Widget _buildHeatmapCard() {
    final dayLabels = ['一', '二', '三', '四', '五', '六', '日'];
    final moduleLabels = ['素材', '词汇', '灵感', '剧情'];
    final moduleIcons = [
      Icons.description_outlined,
      Icons.text_fields_rounded,
      Icons.lightbulb_outline_rounded,
      Icons.auto_stories_outlined,
    ];
    final moduleColors = [
      AppTheme.materialColor,
      AppTheme.vocabularyColor,
      AppTheme.inspirationColor,
      AppTheme.plotColor,
    ];
    final moduleBgColors = [
      AppTheme.materialBg,
      AppTheme.vocabularyBg,
      AppTheme.inspirationBg,
      AppTheme.plotBg,
    ];

    int totalRecords = 0;
    for (final row in heatmapData) {
      totalRecords += row.where((v) => v).length;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
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
            '本周活动',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Day labels row
          Row(
            children: [
              const SizedBox(width: 72),
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
          const SizedBox(height: 8),
          // Module rows
          ...List.generate(4, (rowIdx) {
            return Padding(
              padding: EdgeInsets.only(bottom: rowIdx < 3 ? 10 : 0),
              child: Row(
                children: [
                  // Module icon + name
                  SizedBox(
                    width: 72,
                    child: Row(
                      children: [
                        Icon(moduleIcons[rowIdx], size: 14, color: moduleColors[rowIdx]),
                        const SizedBox(width: 4),
                        Text(
                          moduleLabels[rowIdx],
                          style: TextStyle(
                            fontSize: 11,
                            color: moduleColors[rowIdx],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Activity cells
                  ...List.generate(7, (colIdx) {
                    final active = heatmapData[rowIdx][colIdx];
                    return Expanded(
                      child: Center(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: active ? moduleBgColors[rowIdx] : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: active
                              ? Icon(Icons.check, size: 14, color: moduleColors[rowIdx])
                              : Center(
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(3),
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
          const SizedBox(height: 16),
          Center(
            child: Text(
              '总计: $totalRecords 项记录',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Daily Word Count Bar Chart ──
  Widget _buildBarChartCard() {
    final dayLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final maxCount = dailyWordCounts.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
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
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final ratio = maxCount > 0 ? dailyWordCounts[i] / maxCount : 0.0;
                final barColors = [
                  AppTheme.materialColor,
                  AppTheme.inspirationColor,
                  AppTheme.plotColor,
                  AppTheme.vocabularyColor,
                  AppTheme.materialColor,
                  AppTheme.inspirationColor,
                  AppTheme.plotColor,
                ];
                final barBgColors = [
                  AppTheme.materialBg,
                  AppTheme.inspirationBg,
                  AppTheme.plotBg,
                  AppTheme.vocabularyBg,
                  AppTheme.materialBg,
                  AppTheme.inspirationBg,
                  AppTheme.plotBg,
                ];

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${dailyWordCounts[i]}',
                          style: TextStyle(
                            fontSize: 10,
                            color: barColors[i],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 120 * ratio,
                          decoration: BoxDecoration(
                            color: barBgColors[i],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    barColors[i].withValues(alpha: 0.3),
                                    barBgColors[i],
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
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
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.textPrimary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share_outlined, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text(
              '分享周报',
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
