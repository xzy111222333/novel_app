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
  int _topTab = 0; // 0 = 素材打卡, 1 = 创作总览

  // Soft checkin colors: (background circle, checkmark/text)
  static const _checkinBg = [
    Color(0xFFD4E6D4), // 素材 — soft green
    Color(0xFFD4E0E8), // 词汇 — soft blue
    Color(0xFFE8DED0), // 灵感 — soft gold
    Color(0xFFE0D4E0), // 剧情 — soft purple
  ];
  static const _checkinFg = [
    Color(0xFF7AB57A),
    Color(0xFF7AABB5),
    Color(0xFFC4B07A),
    Color(0xFFAA8FAA),
  ];

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

  // ─── Date range computation ───────────────────────────────────────────

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

  String get _rangeTitleLabel {
    switch (_mode) {
      case _RangeMode.week:
        return _offset == 0 ? '本周' : (_offset == -1 ? '上周' : '');
      case _RangeMode.month:
        return _offset == 0 ? '本月' : '';
      case _RangeMode.year:
        return _offset == 0 ? '今年' : '';
    }
  }

  String get _rangeDateLabel {
    final s = _rangeStart;
    final e = _rangeEnd;
    String pad(int v) => v.toString().padLeft(2, '0');
    switch (_mode) {
      case _RangeMode.week:
        return '${pad(s.month)}/${pad(s.day)} → ${pad(e.month)}/${pad(e.day)}';
      case _RangeMode.month:
        return '${s.year}/${pad(s.month)}';
      case _RangeMode.year:
        return '${s.year}';
    }
  }

  bool _inRange(DateTime dt) {
    final d = DateTime(dt.year, dt.month, dt.day);
    final s = DateTime(_rangeStart.year, _rangeStart.month, _rangeStart.day);
    final e = DateTime(_rangeEnd.year, _rangeEnd.month, _rangeEnd.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  // ─── Data aggregation ─────────────────────────────────────────────────

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

  Map<String, Set<int>> get _moduleMonthlyActiveDays {
    final s = _rangeStart;
    final result = <String, Set<int>>{
      'materials': {},
      'vocabulary': {},
      'inspirations': {},
      'plots': {},
    };
    for (final m in _ds.materials) {
      if (m.createdAt.year == s.year && m.createdAt.month == s.month) {
        result['materials']!.add(m.createdAt.day);
      }
    }
    for (final v in _ds.vocabulary) {
      if (v.createdAt.year == s.year && v.createdAt.month == s.month) {
        result['vocabulary']!.add(v.createdAt.day);
      }
    }
    for (final i in _ds.inspirations) {
      if (i.createdAt.year == s.year && i.createdAt.month == s.month) {
        result['inspirations']!.add(i.createdAt.day);
      }
    }
    for (final p in _ds.plots) {
      if (p.createdAt.year == s.year && p.createdAt.month == s.month) {
        result['plots']!.add(p.createdAt.day);
      }
    }
    return result;
  }

  // ─── Build ────────────────────────────────────────────────────────────

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
              const SizedBox(height: 12),
              _buildTopTabBar(),
              const SizedBox(height: 14),
              _buildToggle(),
              const SizedBox(height: 10),
              _buildDateNavigator(),
              const SizedBox(height: 14),
              if (_topTab == 0) ...[
                if (_mode == _RangeMode.week) _buildWeeklyCheckinTable(),
                if (_mode == _RangeMode.month) _buildMonthlyCheckinView(),
                if (_mode == _RangeMode.year) _buildYearlyCheckinSummary(),
              ] else ...[
                _buildSummaryCard(),
                const SizedBox(height: 12),
                _buildModuleRow(),
                const SizedBox(height: 12),
                _buildCalendarHeatmap(),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          const SizedBox(width: 36),
          const Expanded(
            child: Center(
              child: Text(
                '统计',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  // ─── Top Tab Bar (素材打卡 | 创作总览) ────────────────────────────────

  Widget _buildTopTabBar() {
    const tabs = ['素材打卡', '创作总览'];
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppTheme.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(2, (i) {
          final active = _topTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _topTab = i),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: active ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Time Toggle (周 / 月 / 年) ──────────────────────────────────────

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
            padding: const EdgeInsets.symmetric(horizontal: 18),
            margin: EdgeInsets.only(left: i > 0 ? 8 : 0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppTheme.primary : AppTheme.muted,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              labels[i],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── Date Navigator (< 本周  03/30 → 04/05 >) ───────────────────────

  Widget _buildDateNavigator() {
    final title = _rangeTitleLabel;
    return Column(
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => _offset--),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.chevron_left,
                    size: 20, color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _rangeDateLabel,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _offset < 0 ? () => setState(() => _offset++) : null,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color:
                      _offset < 0 ? AppTheme.textSecondary : AppTheme.divider,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  素材打卡 Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // ─── Weekly Checkin Table ─────────────────────────────────────────────

  Widget _buildWeeklyCheckinTable() {
    final dots = _weeklyDots;
    const headers = ['全部', '一', '二', '三', '四', '五', '六', '日'];
    const keys = ['materials', 'vocabulary', 'inspirations', 'plots'];
    const labels = ['素材', '词汇', '灵感', '剧情'];
    const icons = ['📝', '📖', '💡', '🎭'];

    int totalActive = 0;
    for (final k in keys) {
      totalActive += (dots[k] ?? <bool>[]).where((b) => b).length;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Column headers
          Row(
            children: [
              const SizedBox(width: 60),
              ...headers.map((h) => Expanded(
                    child: Center(
                      child: Text(
                        h,
                        style: TextStyle(
                          fontSize: 11,
                          color: h == '全部'
                              ? AppTheme.textSecondary
                              : AppTheme.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppTheme.divider),

          // Module rows
          ...List.generate(4, (row) {
            final active = dots[keys[row]] ?? List.filled(7, false);
            final rowTotal = active.where((b) => b).length;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      // Icon + name
                      SizedBox(
                        width: 60,
                        child: Row(
                          children: [
                            Text(icons[row],
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              labels[row],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // "全部" column — total count
                      Expanded(
                        child: Center(
                          child: Text(
                            '$rowTotal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: rowTotal > 0
                                  ? _checkinFg[row]
                                  : AppTheme.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      // 7 day cells
                      ...List.generate(7, (col) {
                        return Expanded(
                          child: Center(
                            child: active[col]
                                ? Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: _checkinBg[row],
                                    ),
                                    child: Icon(Icons.check,
                                        size: 14, color: _checkinFg[row]),
                                  )
                                : Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppTheme.divider,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                if (row < 3) const Divider(height: 1, color: AppTheme.divider),
              ],
            );
          }),

          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '总计：$totalActive',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Monthly Checkin View (per-module calendars) ──────────────────────

  Widget _buildMonthlyCheckinView() {
    final moduleActive = _moduleMonthlyActiveDays;
    const keys = ['materials', 'vocabulary', 'inspirations', 'plots'];
    const labels = ['素材', '词汇', '灵感', '剧情'];
    const icons = ['📝', '📖', '💡', '🎭'];

    final s = _rangeStart;
    final daysInMonth = DateTime(s.year, s.month + 1, 0).day;
    final firstWeekday = s.weekday;
    final now = DateTime.now();

    return Column(
      children: List.generate(4, (idx) {
        final activeDays = moduleActive[keys[idx]]!;
        final total = activeDays.length;

        final cells = <int?>[
          ...List.filled(firstWeekday - 1, null),
          ...List.generate(daysInMonth, (i) => i + 1),
        ];
        while (cells.length % 7 != 0) {
          cells.add(null);
        }

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: idx < 3 ? 12 : 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module header
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _checkinBg[idx],
                    ),
                    child: Center(
                      child: Text(icons[idx],
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labels[idx],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '总计 $total',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Weekday headers
              Row(
                children: ['一', '二', '三', '四', '五', '六', '日']
                    .map((h) => Expanded(
                          child: Center(
                            child: Text(
                              h,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 6),

              // Calendar grid
              ...List.generate(cells.length ~/ 7, (row) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: List.generate(7, (col) {
                      final day = cells[row * 7 + col];
                      if (day == null) {
                        return const Expanded(child: SizedBox(height: 28));
                      }
                      final isActive = activeDays.contains(day);
                      final isToday = s.year == now.year &&
                          s.month == now.month &&
                          day == now.day;

                      return Expanded(
                        child: SizedBox(
                          height: 28,
                          child: Center(
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: isActive
                                    ? _checkinBg[idx]
                                    : (isToday
                                        ? const Color(0xFFF0F1F3)
                                        : null),
                                border: isToday && !isActive
                                    ? Border.all(
                                        color: AppTheme.textTertiary,
                                        width: 1)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isActive || isToday
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isActive
                                        ? _checkinFg[idx]
                                        : (isToday
                                            ? AppTheme.textPrimary
                                            : AppTheme.textTertiary),
                                  ),
                                ),
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
      }),
    );
  }

  // ─── Yearly Checkin Summary ───────────────────────────────────────────

  Widget _buildYearlyCheckinSummary() {
    final counts = _rangeModuleCounts;
    const keys = ['materials', 'vocabulary', 'inspirations', 'plots'];
    const labels = ['素材', '词汇', '灵感', '剧情'];
    const icons = ['📝', '📖', '💡', '🎭'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            '年度打卡总览',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _checkinBg[i],
                      ),
                      child: Center(
                        child: Text(icons[i],
                            style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[i],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${counts[keys[i]]}条',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: [AppTheme.materialColor, AppTheme.vocabularyColor, AppTheme.inspirationColor, AppTheme.plotColor][i],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 12),
          Text(
            '总计 ${counts.values.fold<int>(0, (a, b) => a + b)} 条记录',
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  创作总览 Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildSummaryCard() {
    final periodLabel = _mode == _RangeMode.week
        ? '本周新增'
        : (_mode == _RangeMode.month ? '本月新增' : '今年新增');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
        borderRadius: BorderRadius.circular(8),
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
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: color,
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
        borderRadius: BorderRadius.circular(8),
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
                                  borderRadius: BorderRadius.circular(6),
                                  color:
                                      AppTheme.primary.withValues(alpha: 0.18),
                                ),
                                child: Center(
                                  child: Text(
                                    '$day',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
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
