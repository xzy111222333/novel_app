import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/inspiration_item.dart';
import '../services/data_service.dart';
import '../utils/share_card_util.dart';
import '../widgets/search_bar_widget.dart';
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
      final dateStr =
          '${item.createdAt.month}月${item.createdAt.day}日 ${_weekday(item.createdAt.weekday)}';
      String key;
      if (itemDate == today) {
        key = '今天 · $dateStr';
      } else if (itemDate == yesterday) {
        key = '昨天 · $dateStr';
      } else {
        key = '${item.createdAt.month}月${item.createdAt.day}日 · ${_weekday(item.createdAt.weekday)}';
      }
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
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
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  _HeaderIconButton(
                    icon: _showSearch ? Icons.close : Icons.search,
                    onTap: () => setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) _searchQuery = '';
                    }),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '灵感日记',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  _HeaderIconButton(
                    icon: Icons.add,
                    filled: true,
                    onTap: () => showAddInspirationSheet(context),
                  ),
                ],
              ),
            ),

            // Search bar
            if (_showSearch) ...[
              SearchBarWidget(
                placeholder: '搜索标题、内容、标签...',
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 12),
            ],

            // Content
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('✨',
                              style: TextStyle(
                                  fontSize: 48,
                                  color: AppTheme.textTertiary
                                      .withValues(alpha: 0.5))),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? '没有找到匹配的灵感'
                                : '记录你的第一个灵感吧 ✨',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () =>
                                  showAddInspirationSheet(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.textPrimary,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Text('记录灵感',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
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
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFBBF24),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      key,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Cards
                              ...sectionItems.map((item) =>
                                  _buildInspirationCard(item)),
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
    final timeStr = DateFormat('HH:mm').format(item.createdAt);

    return GestureDetector(
      onTap: () => showAddInspirationSheet(context, item: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeStr,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          if (item.title != null && item.title!.isNotEmpty) ...[
            Text(
              item.title!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Content
          Text(
            item.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),

          // Tags
          if (item.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: item.tags.map((tag) {
                return Text(
                  '#$tag',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textTertiary,
                  ),
                );
              }).toList(),
            ),
          ],

          // Action row
          const SizedBox(height: 8),
          Row(
            children: [
              _buildActionBtn(
                Icons.arrow_forward_rounded,
                '转素材',
                () {
                  DataService.instance
                      .convertInspirationToMaterial(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('已转为素材'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildActionBtn(
                Icons.translate_rounded,
                '转词汇',
                () {
                  DataService.instance
                      .convertInspirationToVocabulary(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('已转为词汇'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
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
              _buildMoreMenu(item),
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
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary),
          ),
        ],
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
              leading: const Icon(Icons.copy, size: 22, color: AppTheme.textSecondary),
              title: const Text('复制内容', style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: item.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined, size: 22, color: AppTheme.textSecondary),
              title: const Text('分享为图片', style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                await _shareItemAsImage(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notes, size: 22, color: AppTheme.textSecondary),
              title: const Text('查看其它笔记', style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _showOtherNotes();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, size: 22, color: Colors.redAccent),
              title: const Text('删除灵感', style: TextStyle(fontSize: 15, color: Colors.redAccent)),
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

  Widget _buildMoreMenu(InspirationItem item) {
    return GestureDetector(
      onTap: () => _showOptionsSheet(item),
      child: const Icon(Icons.more_horiz_rounded, size: 18, color: AppTheme.textTertiary),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    this.filled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: filled ? AppTheme.textPrimary : const Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: filled ? Colors.white : AppTheme.textSecondary,
        ),
      ),
    );
  }
}
