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
      backgroundColor: AppTheme.scaffoldBackground,
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                      ),
                      child: const Icon(Icons.more_vert,
                          size: 18, color: Color(0xFF666666)),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '灵感',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showAddInspirationSheet(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                      ),
                      child: const Icon(Icons.add,
                          size: 18, color: Color(0xFF666666)),
                    ),
                  ),
                ],
              ),
            ),

            // Search box — dashed border style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GestureDetector(
                onTap: () => setState(() => _showSearch = !_showSearch),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _showSearch
                          ? AppTheme.textSecondary
                          : const Color(0xFFDDDDDD),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _showSearch
                      ? TextField(
                          autofocus: true,
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: '输入笔记内容',
                            hintStyle: TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 12),
                            prefixIcon: Icon(Icons.search,
                                color: AppTheme.textTertiary, size: 16),
                            prefixIconConstraints:
                                BoxConstraints(minWidth: 36),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search,
                                size: 14, color: AppTheme.textTertiary),
                            SizedBox(width: 4),
                            Text('输入笔记内容',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textTertiary)),
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
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.lightbulb_outline_rounded,
                                size: 36,
                                color: AppTheme.textTertiary
                                    .withValues(alpha: 0.5)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? '没有找到匹配的灵感'
                                : '暂无灵感',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (_searchQuery.isEmpty)
                            const Text('点击右上角 + 添加',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textTertiary)),
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
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timestamp row with yellow dot
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBBF24),
                    shape: BoxShape.circle,
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
                      size: 18, color: AppTheme.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            if (item.title != null && item.title!.isNotEmpty) ...[
              Text(
                item.title!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
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
                    size: 14,
                    color: item.isFavorite
                        ? const Color(0xFFFBBF24)
                        : AppTheme.textTertiary,
                  ),
                ),
                const Spacer(),
                if (isRandom)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(4),
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
                                fontSize: 10,
                                color: AppTheme.textTertiary)),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textTertiary),
          const SizedBox(width: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }

  void _showGlobalMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showOptionsSheet(InspirationItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
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
                  size: 22, color: Colors.redAccent),
              title: const Text('删除灵感',
                  style: TextStyle(
                      fontSize: 14, color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                DataService.instance.deleteInspiration(item.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
