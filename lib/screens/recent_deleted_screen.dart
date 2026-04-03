import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/deleted_record.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';

class RecentlyDeletedScreen extends StatefulWidget {
  const RecentlyDeletedScreen({super.key});

  @override
  State<RecentlyDeletedScreen> createState() => _RecentlyDeletedScreenState();
}

class _RecentlyDeletedScreenState extends State<RecentlyDeletedScreen> {
  final _data = DataService.instance;

  @override
  void initState() {
    super.initState();
    _data.addListener(_handleChange);
  }

  @override
  void dispose() {
    _data.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (mounted) {
      setState(() {});
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'material':
        return '素材';
      case 'vocabulary':
        return '词汇';
      case 'inspiration':
        return '灵感';
      case 'plot':
        return '剧情';
      default:
        return '内容';
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'material':
        return AppTheme.materialColor;
      case 'vocabulary':
        return AppTheme.vocabularyColor;
      case 'inspiration':
        return AppTheme.inspirationColor;
      case 'plot':
        return AppTheme.plotColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _preview(DeletedRecord record) {
    switch (record.type) {
      case 'material':
      case 'vocabulary':
        return (record.payload['content'] as String?) ?? '';
      case 'inspiration':
        return (record.payload['title'] as String?)?.trim().isNotEmpty == true
            ? record.payload['title'] as String
            : (record.payload['content'] as String? ?? '');
      case 'plot':
        final type = record.payload['type'] as String? ?? 'free';
        if (type == 'steps') {
          final steps = List<String>.from(record.payload['steps'] as List? ?? const []);
          return steps.join(' ');
        }
        return (record.payload['freeContent'] as String?) ?? '';
      default:
        return '';
    }
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空最近删除'),
        content: const Text('清空后无法恢复，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '清空',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _data.clearRecentlyDeleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _data.recentlyDeleted;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text('最近删除'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: _confirmClearAll,
              child: const Text(
                '清空',
                style: TextStyle(
                  color: AppTheme.danger,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.softBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppTheme.textTertiary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '最近删除为空',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '删除的内容会先进入这里，你可以恢复或彻底清除。',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemBuilder: (context, index) {
                final item = items[index];
                final color = _typeColor(item.type);
                return Container(
                  decoration: AppTheme.smallCardDecoration,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _typeLabel(item.type),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('M月d日 HH:mm').format(item.deletedAt),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _preview(item),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.55,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _data.purgeDeleted(item.id),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.danger,
                                  side: const BorderSide(color: AppTheme.divider),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text('彻底删除'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => _data.restoreDeleted(item.id),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.textPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text('恢复'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: items.length,
            ),
    );
  }
}
