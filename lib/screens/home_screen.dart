import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/inspiration_item.dart';
import '../models/material_item.dart';
import '../models/plot_item.dart';
import '../models/vocabulary_item.dart';
import '../screens/inspiration_screen.dart';
import '../screens/materials_screen.dart';
import '../screens/plots_screen.dart';
import '../screens/vocabulary_screen.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../utils/share_card_util.dart';
import '../widgets/add_inspiration_sheet.dart';
import '../widgets/add_material_sheet.dart';
import '../widgets/add_plot_sheet.dart';
import '../widgets/add_vocabulary_sheet.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<String>? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  late DateTime _selectedDate;
  late PageController _weekPageController;
  InspirationItem? _randomInspiration;
  bool _isCalendarExpanded = true;

  // Week-based calendar: page 0 = far past, center page = current week
  static const int _totalWeekPages = 200;
  static const int _centerWeekPage = 100;
  late DateTime _baseMonday; // Monday of current week

  DateTime _mondayOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  List<DateTime> _weekDaysForPage(int page) {
    final offset = page - _centerWeekPage;
    final monday = _baseMonday.add(Duration(days: offset * 7));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  bool _dayHasEntries(DateTime date) {
    final ds = DataService.instance;
    return ds.materials.any((m) => _isSameDay(m.createdAt, date)) ||
        ds.vocabulary.any((v) => _isSameDay(v.createdAt, date)) ||
        ds.inspirations.any((i) => _isSameDay(i.createdAt, date)) ||
        ds.plots.any((p) => _isSameDay(p.createdAt, date));
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _baseMonday = _mondayOfWeek(_selectedDate);
    _weekPageController = PageController(initialPage: _centerWeekPage);
    DataService.instance.addListener(_onDataChanged);
    _refreshRandomInspiration();
  }

  @override
  void dispose() {
    DataService.instance.removeListener(_onDataChanged);
    _weekPageController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _refreshRandomInspiration() {
    _randomInspiration = DataService.instance.getRandomPastInspiration();
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
    _weekPageController.animateToPage(
      _centerWeekPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  List<MaterialItem> get _selectedMaterials => DataService.instance.materials
      .where((m) => _isSameDay(m.createdAt, _selectedDate))
      .toList();

  List<VocabularyItem> get _selectedVocabulary =>
      DataService.instance.vocabulary
          .where((v) => _isSameDay(v.createdAt, _selectedDate))
          .toList();

  List<InspirationItem> get _selectedInspirations =>
      DataService.instance.inspirations
          .where((i) => _isSameDay(i.createdAt, _selectedDate))
          .toList();

  List<PlotItem> get _selectedPlots => DataService.instance.plots
      .where((p) => _isSameDay(p.createdAt, _selectedDate))
      .toList();

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';


  String _menuLabelForType(String typeLabel) {
    switch (typeLabel) {
      case '素材':
        return '查看全部素材';
      case '词汇':
        return '查看全部词汇';
      case '剧情':
        return '查看全部剧情';
      default:
        return '查看其它笔记';
    }
  }

  Future<void> _shareItemAsImage(dynamic item, String typeLabel) async {
    String content = '';
    String? title;
    String? meta;
    List<String> tags = const [];
    Color accentColor = AppTheme.accent;

    if (item is MaterialItem) {
      content = item.content;
      meta = item.source.isEmpty
          ? item.category
          : '${item.category} · ${item.source}';
      tags = item.tags;
      accentColor = AppTheme.getCategoryColor(item.category);
    } else if (item is VocabularyItem) {
      content = item.content;
      meta = item.category;
      tags = item.tags;
      accentColor = AppTheme.getCategoryColor(item.category);
    } else if (item is InspirationItem) {
      content = item.content;
      title = item.title;
      meta = DateFormat('M月d日 HH:mm').format(item.createdAt);
      tags = item.tags;
    } else if (item is PlotItem) {
      content = item.displayContent;
      meta = item.category;
      tags = item.tags;
      accentColor = AppTheme.getCategoryColor(item.category);
    }

    await ShareCardUtil.shareAsImage(
      context,
      typeLabel: typeLabel,
      title: title,
      content: content,
      meta: meta,
      tags: tags,
      accentColor: accentColor,
    );
  }

  void _openListPageForType(String typeLabel) {
    if (widget.onNavigateToTab != null) {
      switch (typeLabel) {
        case '素材':
          widget.onNavigateToTab!.call('materials');
          return;
        case '词汇':
          widget.onNavigateToTab!.call('vocabulary');
          return;
        case '剧情':
          widget.onNavigateToTab!.call('plots');
          return;
        default:
          widget.onNavigateToTab!.call('inspirations');
          return;
      }
    }

    Widget screen;
    switch (typeLabel) {
      case '素材':
        screen = const MaterialsScreen();
        break;
      case '词汇':
        screen = const VocabularyScreen();
        break;
      case '剧情':
        screen = const PlotsScreen();
        break;
      default:
        screen = const InspirationScreen();
        break;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showOptionsSheet(
      dynamic item, String typeLabel, VoidCallback onDelete) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.muted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.copy, size: 20, color: AppTheme.textSecondary),
              title: const Text('复制内容',
                  style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                final contentToCopy =
                    item is PlotItem ? item.displayContent : item.content;
                Clipboard.setData(ClipboardData(text: contentToCopy));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('已复制'),
                      behavior: SnackBarBehavior.floating),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined,
                  size: 20, color: AppTheme.textSecondary),
              title: const Text('分享为图片',
                  style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                await _shareItemAsImage(item, typeLabel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notes, size: 20, color: AppTheme.textSecondary),
              title: Text(
                _menuLabelForType(typeLabel),
                style:
                    const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _openListPageForType(typeLabel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  size: 20, color: AppTheme.danger),
              title: Text('删除$typeLabel',
                  style:
                      const TextStyle(fontSize: 14, color: AppTheme.danger)),
              onTap: () {
                Navigator.pop(ctx);
                onDelete();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inspirations = _selectedInspirations;
    final materials = _selectedMaterials;
    final vocabulary = _selectedVocabulary;
    final plots = _selectedPlots;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            // weekday labels now inside day cells
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _isCalendarExpanded
                  ? _buildWeekPageView()
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _buildQuickActionPills(context),
                  if (_randomInspiration != null) ...[
                    const SizedBox(height: 10),
                    _buildRandomReviewCard(_randomInspiration!),
                  ],
                  const SizedBox(height: 14),
                  _buildVocabularySection(vocabulary),
                  const SizedBox(height: 14),
                  _buildMaterialsSection(materials),
                  const SizedBox(height: 14),
                  _buildInspirationsSection(inspirations),
                  if (plots.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildPlotsSection(plots),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header: "今日 • 周六 ▾" style with collapsible toggle
  Widget _buildHeader(BuildContext context) {
    final weekdayName = _weekdays[_selectedDate.weekday - 1];
    final isToday = _isToday(_selectedDate);
    final dateLabel = isToday
        ? '今日 • $weekdayName'
        : '${_selectedDate.month}月${_selectedDate.day}日 • $weekdayName';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 14, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _isCalendarExpanded = !_isCalendarExpanded),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dateLabel,
                  style: AppTheme.headingStyleWith(fontSize: 16),
                ),
                const SizedBox(width: 2),
                Icon(
                  _isCalendarExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
          if (!isToday) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _goToToday,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: AppTheme.wobblyPill,
                  border: Border.all(color: AppTheme.accent, width: 1),
                ),
                child: const Text(
                  '回今天',
                  style: TextStyle(fontSize: 10, color: AppTheme.accent),
                ),
              ),
            ),
          ],
          const Spacer(),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showQuickAddMenu(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: AppTheme.outlinedCircleDecoration(),
        child: const Icon(Icons.add, size: 18, color: AppTheme.textPrimary),
      ),
    );
  }

  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              _quickAddTile('添加素材', Icons.note_add_outlined, () {
                Navigator.pop(ctx);
                showAddMaterialSheet(context);
              }),
              _quickAddTile('添加词汇', Icons.text_fields, () {
                Navigator.pop(ctx);
                showAddVocabularySheet(context);
              }),
              _quickAddTile('添加灵感', Icons.lightbulb_outline, () {
                Navigator.pop(ctx);
                showAddInspirationSheet(context);
              }),
              _quickAddTile('添加剧情', Icons.auto_stories_outlined, () {
                Navigator.pop(ctx);
                showAddPlotSheet(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAddTile(String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      leading: Icon(icon, size: 18, color: AppTheme.textSecondary),
      title: Text(label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
      onTap: onTap,
    );
  }

  // ── Week-mode: swipeable PageView showing one week row
  Widget _buildWeekPageView() {
    return SizedBox(
      height: 60,
      child: PageView.builder(
        controller: _weekPageController,
        itemCount: _totalWeekPages,
        onPageChanged: (_) => setState(() {}),
        itemBuilder: (_, page) {
          final days = _weekDaysForPage(page);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: days.map((d) => Expanded(child: _dayCell(d))).toList(),
            ),
          );
        },
      ),
    );
  }

  // ── Individual day cell
  Widget _dayCell(DateTime date) {
    final isSelected = _isSameDay(date, _selectedDate);
    final today = _isToday(date);
    final hasData = _dayHasEntries(date);
    final weekdayIndex = date.weekday - 1; // 0=Mon .. 6=Sun

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      child: Center(
        child: Container(
          width: 40,
          height: 54,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.textPrimary : Colors.transparent,
            borderRadius: AppTheme.wobblySmall,
            border: today && !isSelected
                ? Border.all(color: AppTheme.border, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _weekdays[weekdayIndex],
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white70
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: isSelected || today
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              if (hasData)
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white54 : AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildQuickActionPills(BuildContext context) {
    final actions = [
      ('素材', () => showAddMaterialSheet(context)),
      ('词汇', () => showAddVocabularySheet(context)),
      ('灵感', () => showAddInspirationSheet(context)),
      ('剧情', () => showAddPlotSheet(context)),
    ];

    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, onTap) = actions[i];
          return GestureDetector(
            onTap: onTap,
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: AppTheme.wobblyPill,
                border: Border.all(color: AppTheme.border, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 12, color: AppTheme.textPrimary),
                  const SizedBox(width: 2),
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRandomReviewCard(InspirationItem item) {
    final dateStr = DateFormat('yyyy.MM.dd').format(item.createdAt);
    return GestureDetector(
      onTap: () => showAddInspirationSheet(context, item: item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: AppTheme.wobblySmall,
                    border: Border.all(color: AppTheme.border, width: 1.5),
                  ),
                ),
                const SizedBox(width: 6),
                Text(dateStr,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showOptionsSheet(item, '灵感', () {
                    DataService.instance.deleteInspiration(item.id);
                    _refreshRandomInspiration();
                  }),
                  child: const Icon(Icons.more_vert,
                      size: 16, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => _refreshRandomInspiration()),
                  child: const Icon(Icons.refresh,
                      size: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
            if (item.title != null && item.title!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.title!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Text(
              item.content,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: const BoxDecoration(
                color: AppTheme.muted,
                borderRadius: AppTheme.wobblyPill,
              ),
              child: const Text(
                '随机回顾',
                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabularySection(List<VocabularyItem> items) {
    final dayLabel = _isToday(_selectedDate)
        ? '今日'
        : '${_selectedDate.month}/${_selectedDate.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('$dayLabel词汇', items.length, onMore: () {
          widget.onNavigateToTab?.call('vocabulary');
        }),
        const SizedBox(height: 6),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text('暂无记录',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...items.take(6).map((v) => _vocabPill(v)),
              if (items.length > 6)
                const Text('···',
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
      ],
    );
  }

  Widget _vocabPill(VocabularyItem v) {
    return GestureDetector(
      onTap: () => showAddVocabularySheet(context, item: v),
      onLongPress: () => _showOptionsSheet(v, '词汇', () {
        DataService.instance.deleteVocabulary(v.id);
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: AppTheme.wobblyPill,
          border: Border.all(color: AppTheme.border, width: 1.5),
        ),
        child: Text(
          v.content,
          style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildMaterialsSection(List<MaterialItem> items) {
    final dayLabel = _isToday(_selectedDate)
        ? '今日'
        : '${_selectedDate.month}/${_selectedDate.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('$dayLabel素材', items.length, onMore: () {
          widget.onNavigateToTab?.call('materials');
        }),
        const SizedBox(height: 6),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text('暂无记录',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          )
        else
          ...items.take(3).map(_buildMaterialCard),
      ],
    );
  }

  Widget _buildMaterialCard(MaterialItem item) {
    return GestureDetector(
      onTap: () => showAddMaterialSheet(context, item: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.smallCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: AppTheme.wobblyPill,
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showOptionsSheet(item, '素材', () {
                    DataService.instance.deleteMaterial(item.id);
                  }),
                  child: const Icon(Icons.more_vert,
                      size: 16, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.content,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textPrimary, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.tags.map((t) => '#$t').join(' '),
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.secondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInspirationsSection(List<InspirationItem> items) {
    final dayLabel = _isToday(_selectedDate)
        ? '今日'
        : '${_selectedDate.month}/${_selectedDate.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('$dayLabel灵感', items.length, onMore: () {
          widget.onNavigateToTab?.call('inspirations');
        }),
        const SizedBox(height: 6),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text('暂无记录',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          )
        else
          ...items.take(3).map(_buildInspirationEntry),
      ],
    );
  }

  Widget _buildInspirationEntry(InspirationItem item) {
    return GestureDetector(
      onTap: () => showAddInspirationSheet(context, item: item),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: AppTheme.wobblySmall,
                    border: Border.all(color: AppTheme.border, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(item.createdAt),
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => _showOptionsSheet(item, '灵感', () {
                            DataService.instance.deleteInspiration(item.id);
                          }),
                          child: const Icon(Icons.more_vert,
                              size: 16, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.content,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlotsSection(List<PlotItem> items) {
    final dayLabel = _isToday(_selectedDate)
        ? '今日'
        : '${_selectedDate.month}/${_selectedDate.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('$dayLabel剧情', items.length, onMore: () {
          widget.onNavigateToTab?.call('plots');
        }),
        const SizedBox(height: 6),
        ...items.take(3).map(_buildPlotCard),
      ],
    );
  }

  Widget _buildPlotCard(PlotItem item) {
    return GestureDetector(
      onTap: () => showAddPlotSheet(context, item: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.smallCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: AppTheme.wobblyPill,
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showOptionsSheet(item, '剧情', () {
                    DataService.instance.deletePlot(item.id);
                  }),
                  child: const Icon(Icons.more_vert,
                      size: 16, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.displayContent,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textPrimary, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.tags.map((t) => '#$t').join(' '),
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.secondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, {VoidCallback? onMore}) {
    return Row(
      children: [
        Text(title, style: AppTheme.headingStyleWith(fontSize: 16)),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: const BoxDecoration(
              color: AppTheme.muted,
              borderRadius: AppTheme.wobblyPill,
            ),
            child: Text('$count',
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ),
        ],
        const Spacer(),
        if (onMore != null) ...[
          Container(
            width: 32,
            height: 32,
            decoration: AppTheme.outlinedCircleDecoration(size: 32),
            child: const Icon(Icons.more_vert, size: 16, color: AppTheme.textPrimary),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onMore,
            child: Container(
              width: 32,
              height: 32,
              decoration: AppTheme.outlinedCircleDecoration(size: 32),
              child: const Icon(Icons.add, size: 16, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ],
    );
  }
}
