import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/inspiration_item.dart';
import '../services/data_service.dart';
import '../utils/share_card_util.dart';
import '../widgets/add_inspiration_sheet.dart';

class InspirationScreen extends StatefulWidget {
  const InspirationScreen({super.key});

  @override
  State<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends State<InspirationScreen> {
  bool _showSearch = false;
  String _searchQuery = '';

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

  List<InspirationItem> get _filteredItems {
    final all = DataService.instance.inspirations;
    if (_searchQuery.isEmpty) return all;
    final lq = _searchQuery.toLowerCase();
    return all.where((item) {
      return item.content.toLowerCase().contains(lq) ||
          (item.title?.toLowerCase().contains(lq) ?? false) ||
          item.tags.any((t) => t.toLowerCase().contains(lq));
    }).toList();
  }

  static String _weekday(int w) =>
      ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][w - 1];

  Map<String, List<InspirationItem>> _groupByDate(List<InspirationItem> items) {
    final grouped = <String, List<InspirationItem>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      final itemDate = DateTime(
          item.createdAt.year, item.createdAt.month, item.createdAt.day);
      final ymd =
          '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')}';
      String key;
      if (itemDate == today) {
        key = '$ymd 今天';
      } else if (itemDate == yesterday) {
        key = '$ymd 昨天';
      } else {
        key = ymd;
      }
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  String _cardTimestamp(InspirationItem item) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(
        item.createdAt.year, item.createdAt.month, item.createdAt.day);
    final time = DateFormat('HH:mm').format(item.createdAt);
    final base =
        '${item.createdAt.month}月${item.createdAt.day}日·${_weekday(item.createdAt.weekday)} ${item.createdAt.year} $time';
    if (itemDate == today) return '$base (今天)';
    if (itemDate == yesterday) return '$base (昨天)';
    return base;
  }

  Future<void> _shareItemAsImage(InspirationItem item) async {
    await ShareCardUtil.shareAsImage(
      context,
      typeLabel: '笔记',
      title: item.title,
      content: item.content,
      meta: DateFormat('yyyy年M月d日 HH:mm').format(item.createdAt),
      tags: item.tags,
      accentColor: AppTheme.accent,
    );
  }

  void _showOtherNotes() {
    setState(() {
      _showSearch = false;
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    final grouped = _groupByDate(items);
    final dateKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showGlobalMenu(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: AppTheme.outlinedCircleDecoration(),
                      child: const Icon(Icons.more_vert,
                          size: 18, color: AppTheme.textPrimary),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '灵感',
                        style: AppTheme.headingStyleWith(fontSize: 20),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showAddInspirationSheet(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: AppTheme.outlinedCircleDecoration(),
                      child: const Icon(Icons.add,
                          size: 18, color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // Search box — hand-drawn style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GestureDetector(
                onTap: () => setState(() => _showSearch = !_showSearch),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: AppTheme.wobblySmall,
                    border: Border.all(
                      color: _showSearch ? AppTheme.secondary : AppTheme.border,
                      width: 2,
                    ),
                    boxShadow: AppTheme.hardShadowHover,
                  ),
                  child: _showSearch
                      ? TextField(
                          autofocus: true,
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: '输入笔记内容',
                            hintStyle: TextStyle(
                                color: AppTheme.textPrimary.withAlpha(100),
                                fontSize: 13),
                            prefixIcon: Icon(Icons.search,
                                color: AppTheme.textPrimary.withAlpha(100), size: 18),
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 40),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search,
                                size: 16, color: AppTheme.textPrimary.withAlpha(100)),
                            const SizedBox(width: 4),
                            Text('输入笔记内容',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textPrimary.withAlpha(100))),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Content
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: AppTheme.muted,
                              borderRadius: AppTheme.wobblyMd,
                              border: Border.fromBorderSide(BorderSide(color: AppTheme.border, width: 2)),
                              boxShadow: [BoxShadow(color: Color(0xFF2D2D2D), offset: Offset(3, 3))],
                            ),
                            child: const Icon(Icons.lightbulb_outline_rounded,
                                size: 36,
                                color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? '没有找到匹配的灵感'
                                : '暂无灵感',
                            style: AppTheme.headingStyleWith(fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          if (_searchQuery.isEmpty)
                            const Text('点击右上角 + 添加',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
                      itemCount: dateKeys.length,
                      itemBuilder: (context, sectionIndex) {
                        final key = dateKeys[sectionIndex];
                        final sectionItems = grouped[key]!;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date header
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8, left: 2),
                                child: Text(
                                  key,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                              // Cards
                              ...sectionItems.map(
                                  (item) => _buildInspirationCard(item)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspirationCard(InspirationItem item) {
    final random = DataService.instance.getRandomPastInspiration();
    final isRandom = random != null && random.id == item.id;

    return GestureDetector(
      onTap: () => showAddInspirationSheet(context, item: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timestamp row with yellow dot
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24),
                    borderRadius: AppTheme.wobblySmall,
                    border: Border.all(color: AppTheme.border, width: 1.5),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _cardTimestamp(item),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showOptionsSheet(item),
                  child: const Icon(Icons.more_vert,
                      size: 18, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            if (item.title != null && item.title!.isNotEmpty) ...[
              Text(
                item.title!,
                style: AppTheme.headingStyleWith(fontSize: 15, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
            ],

            // Content
            Text(
              item.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),

            // Tags + action row
            const SizedBox(height: 8),
            Row(
              children: [
                // Convert buttons
                _buildActionBtn(Icons.arrow_forward_rounded, '转素材', () {
                  DataService.instance.convertInspirationToMaterial(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('已转为素材'),
                        behavior: SnackBarBehavior.floating),
                  );
                }),
                const SizedBox(width: 12),
                _buildActionBtn(Icons.translate_rounded, '转词汇', () {
                  DataService.instance.convertInspirationToVocabulary(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('已转为词汇'),
                        behavior: SnackBarBehavior.floating),
                  );
                }),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => DataService.instance
                      .toggleInspirationFavorite(item.id),
                  child: Icon(
                    item.isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 16,
                    color: item.isFavorite
                        ? AppTheme.accent
                        : AppTheme.textTertiary,
                  ),
                ),
                const Spacer(),
                if (isRandom)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: AppTheme.wobblyPill,
                    ),
                    child: const Text('随机回顾',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary)),
                  ),
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  ...item.tags.take(2).map((tag) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text('#$tag',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.secondary)),
                      )),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: AppTheme.wobblyPill,
          border: Border.all(color: AppTheme.border.withAlpha(80), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppTheme.textSecondary),
            const SizedBox(width: 3),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  void _showGlobalMenu(BuildContext context) {
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
              leading: const Icon(Icons.notes, size: 22,
                  color: AppTheme.textSecondary),
              title: const Text('查看其它笔记',
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _showOtherNotes();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showOptionsSheet(InspirationItem item) {
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
              leading: const Icon(Icons.copy,
                  size: 22, color: AppTheme.textSecondary),
              title: const Text('复制内容',
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: item.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('已复制'),
                      behavior: SnackBarBehavior.floating),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined,
                  size: 22, color: AppTheme.textSecondary),
              title: const Text('分享为图片',
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                await _shareItemAsImage(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notes,
                  size: 22, color: AppTheme.textSecondary),
              title: const Text('查看其它笔记',
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _showOtherNotes();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  size: 22, color: AppTheme.accent),
              title: const Text('删除灵感',
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.accent)),
              onTap: () {
                Navigator.pop(ctx);
                DataService.instance.deleteInspiration(item.id);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
