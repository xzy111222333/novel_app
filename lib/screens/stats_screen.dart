import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';

enum _RangeMode { week, month, year }

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _ds = DataService.instance;
  _RangeMode _mode = _RangeMode.week;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _ds.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ds.removeListener(_onDataChanged);
    super.dispose();
  }

  DateTime get _rangeStart {
    final now = DateTime.now();
    switch (_mode) {
      case _RangeMode.week:
        final monday = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        return monday.add(Duration(days: _offset * 7));
      case _RangeMode.month:
        return DateTime(now.year, now.month + _offset, 1);
      case _RangeMode.year:
        return DateTime(now.year + _offset, 1, 1);
    }
  }

  DateTime get _rangeEnd {
    switch (_mode) {
      case _RangeMode.week:
        return _rangeStart.add(const Duration(days: 6));
      case _RangeMode.month:
        final next = DateTime(_rangeStart.year, _rangeStart.month + 1, 1);
        return next.subtract(const Duration(days: 1));
      case _RangeMode.year:
        return DateTime(_rangeStart.year, 12, 31);
    }
  }

  String get _rangeLabel {
    final s = _rangeStart;
    final e = _rangeEnd;
    String pad(int v) => v.toString().padLeft(2, '0');
    switch (_mode) {
      case _RangeMode.week:
        final label = _offset == 0 ? '本周' : (_offset == -1 ? '上周' : '');
        return '$label ${pad(s.month)}/${pad(s.day)} → ${pad(e.month)}/${pad(e.day)}';
      case _RangeMode.month:
        return _offset == 0 ? '本月 ${s.year}/${pad(s.month)}' : '${s.year}/${pad(s.month)}';
      case _RangeMode.year:
        return _offset == 0 ? '今年 ${s.year}' : '${s.year}';
    }
  }

  bool _inRange(DateTime dt) {
    final d = DateTime(dt.year, dt.month, dt.day);
    final s = DateTime(_rangeStart.year, _rangeStart.month, _rangeStart.day);
    final e = DateTime(_rangeEnd.year, _rangeEnd.month, _rangeEnd.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  int get _rangeWordCount {
    int c = 0;
    for (final m in _ds.materials) {
      if (_inRange(m.createdAt)) c += m.content.length;
    }
    for (final v in _ds.vocabulary) {
      if (_inRange(v.createdAt)) c += v.content.length;
    }
    for (final i in _ds.inspirations) {
      if (_inRange(i.createdAt)) c += i.content.length + (i.title?.length ?? 0);
    }
    for (final p in _ds.plots) {
      if (_inRange(p.createdAt)) {
        c += p.type == 'steps'
            ? p.steps.fold<int>(0, (s, step) => s + step.length)
            : p.freeContent.length;
      }
    }
    return c;
  }

  Map<String, int> get _rangeModuleWords {
    int mat = 0, voc = 0, ins = 0, plo = 0;
    for (final m in _ds.materials) {
      if (_inRange(m.createdAt)) mat += m.content.length;
    }
    for (final v in _ds.vocabulary) {
      if (_inRange(v.createdAt)) voc += v.content.length;
    }
    for (final i in _ds.inspirations) {
      if (_inRange(i.createdAt)) ins += i.content.length + (i.title?.length ?? 0);
    }
    for (final p in _ds.plots) {
      if (_inRange(p.createdAt)) {
        plo += p.type == 'steps'
            ? p.steps.fold<int>(0, (s, step) => s + step.length)
            : p.freeContent.length;
      }
    }
    return {'materials': mat, 'vocabulary': voc, 'inspirations': ins, 'plots': plo};
  }

  Map<String, int> get _rangeModuleCounts {
    int mat = 0, voc = 0, ins = 0, plo = 0;
    for (final m in _ds.materials) {
      if (_inRange(m.createdAt)) mat++;
    }
    for (final v in _ds.vocabulary) {
      if (_inRange(v.createdAt)) voc++;
    }
    for (final i in _ds.inspirations) {
      if (_inRange(i.createdAt)) ins++;
    }
    for (final p in _ds.plots) {
      if (_inRange(p.createdAt)) plo++;
    }
    return {'materials': mat, 'vocabulary': voc, 'inspirations': ins, 'plots': plo};
  }

  Map<String, List<bool>> get _weeklyDots {
    final start = _rangeStart;
    final result = <String, List<bool>>{
      'materials': List.filled(7, false),
      'vocabulary': List.filled(7, false),
      'inspirations': List.filled(7, false),
      'plots': List.filled(7, false),
    };
    for (final m in _ds.materials) {
      final d = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day)
          .difference(DateTime(start.year, start.month, start.day))
          .inDays;
      if (d >= 0 && d < 7) result['materials']![d] = true;
    }
    for (final v in _ds.vocabulary) {
      final d = DateTime(v.createdAt.year, v.createdAt.month, v.createdAt.day)
          .difference(DateTime(start.year, start.month, start.day))
          .inDays;
      if (d >= 0 && d < 7) result['vocabulary']![d] = true;
    }
    for (final i in _ds.inspirations) {
      final d = DateTime(i.createdAt.year, i.createdAt.month, i.createdAt.day)
          .difference(DateTime(start.year, start.month, start.day))
          .inDays;
      if (d >= 0 && d < 7) result['inspirations']![d] = true;
    }
    for (final p in _ds.plots) {
      final d = DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day)
          .difference(DateTime(start.year, start.month, start.day))
          .inDays;
      if (d >= 0 && d < 7) result['plots']![d] = true;
    }
    return result;
  }

  Set<int> get _calendarActiveDays {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month + _offset, 1);
    final active = <int>{};
    for (final m in _ds.materials) {
      if (m.createdAt.year == month.year && m.createdAt.month == month.month) {
        active.add(m.createdAt.day);
      }
    }
    for (final v in _ds.vocabulary) {
      if (v.createdAt.year == month.year && v.createdAt.month == month.month) {
        active.add(v.createdAt.day);
      }
    }
    for (final i in _ds.inspirations) {
      if (i.createdAt.year == month.year && i.createdAt.month == month.month) {
        active.add(i.createdAt.day);
      }
    }
    for (final p in _ds.plots) {
      if (p.createdAt.year == month.year && p.createdAt.month == month.month) {
        active.add(p.createdAt.day);
      }
    }
    return active;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildToggle(),
              const SizedBox(height: 10),
              _buildDateNavigator(),
              const SizedBox(height: 14),
              _buildSummaryCard(),
              const SizedBox(height: 12),
              _buildModuleRow(),
              const SizedBox(height: 12),
              if (_mode == _RangeMode.week) ...[
                _buildActivityTable(),
                const SizedBox(height: 12),
              ],
              _buildCalendarHeatmap(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Center(
      child: Text(
        '统计',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildToggle() {
    const labels = ['周', '月', '年'];
    const modes = _RangeMode.values;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = _mode == modes[i];
        return GestureDetector(
          onTap: () => setState(() {
            _mode = modes[i];
            _offset = 0;
          }),
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              labels[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDateNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _offset--),
          child: const Icon(Icons.chevron_left, size: 18, color: AppTheme.textTertiary),
        ),
        const SizedBox(width: 8),
        Text(
          _rangeLabel,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _offset < 0 ? () => setState(() => _offset++) : null,
          child: Icon(
            Icons.chevron_right,
            size: 18,
            color: _offset < 0 ? AppTheme.textTertiary : AppTheme.divider,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final periodLabel = _mode == _RangeMode.week
        ? '本周新增'
        : (_mode == _RangeMode.month ? '本月新增' : '今年新增');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '总收集字数',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              Text(
                '${_ds.totalWordCount}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$periodLabel $_rangeWordCount 字',
            style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleRow() {
    final words = _rangeModuleWords;
    final counts = _rangeModuleCounts;
    const modules = [
      ('素材', 'materials', AppTheme.materialColor),
      ('词汇', 'vocabulary', AppTheme.vocabularyColor),
      ('灵感', 'inspirations', AppTheme.inspirationColor),
      ('剧情', 'plots', AppTheme.plotColor),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: List.generate(modules.length, (i) {
            final (label, key, color) = modules[i];
            return Expanded(
              child: Row(
                children: [
                  if (i > 0)
                    Container(
                      width: 0.5,
                      color: AppTheme.divider,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${words[key]}字',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${counts[key]}条',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActivityTable() {
    final dots = _weeklyDots;
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 36),
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
          const SizedBox(height: 6),
          Divider(height: 1, color: AppTheme.divider),
          ...List.generate(4, (row) {
            final active = dots[moduleKeys[row]] ?? List.filled(7, false);
            return Column(
              children: [
                SizedBox(
                  height: 28,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          moduleLabels[row],
                          style: TextStyle(
                            fontSize: 11,
                            color: moduleColors[row],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...List.generate(7, (col) {
                        return Expanded(
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: active[col] ? moduleColors[row] : const Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                if (row < 3) Divider(height: 1, color: AppTheme.divider),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCalendarHeatmap() {
    final now = DateTime.now();
    final monthDate = DateTime(now.year, now.month + _offset, 1);
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final firstWeekday = monthDate.weekday;
    final activeDays = _calendarActiveDays;
    final monthLabel = '${monthDate.year}年${monthDate.month}月';

    final cells = <int?>[
      ...List.filled(firstWeekday - 1, null),
      ...List.generate(daysInMonth, (i) => i + 1),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    const weekHeaders = ['一', '二', '三', '四', '五', '六', '日'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            monthLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: weekHeaders
                .map((h) => Expanded(
                      child: Center(
                        child: Text(
                          h,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          ...List.generate(cells.length ~/ 7, (row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: List.generate(7, (col) {
                  final day = cells[row * 7 + col];
                  if (day == null) {
                    return const Expanded(child: SizedBox(height: 22));
                  }
                  final hasActivity = activeDays.contains(day);
                  return Expanded(
                    child: SizedBox(
                      height: 22,
                      child: Center(
                        child: hasActivity
                            ? Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.accent.withValues(alpha: 0.18),
                                ),
                                child: Center(
                                  child: Text(
                                    '$day',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                '$day',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}
