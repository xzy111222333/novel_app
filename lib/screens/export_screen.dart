import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _ds = DataService.instance;

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _ds.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _ds.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> _exportAndCopy() async {
    final json = _ds.exportToJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('数据已复制到剪贴板'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final counts = _ds.totalCounts;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('数据导出',
            style: AppTheme.headingStyleWith(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            decoration: AppTheme.cardDecoration,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: AppTheme.wobblySmall,
                  ),
                  child: const Icon(Icons.file_download_outlined,
                      color: AppTheme.textSecondary, size: 24),
                ),
                const SizedBox(height: 10),
                Text('导出全部数据 (JSON)',
                    style: AppTheme.headingStyleWith(fontSize: 14)),
                const SizedBox(height: 6),
                const Text('将所有内容导出为 JSON 格式并复制到剪贴板',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    )),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _exportAndCopy,
                    icon:
                        const Icon(Icons.copy, color: Colors.white, size: 16),
                    label: const Text('复制到剪贴板',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.wobblySmall,
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Container(
            decoration: AppTheme.cardDecoration,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('数据概览',
                    style: AppTheme.headingStyleWith(fontSize: 14)),
                const SizedBox(height: 10),
                _buildStatRow(
                    Icons.description_outlined,
                    '素材',
                    '${counts['materials']} 条'),
                _buildStatRow(
                    Icons.text_fields_outlined,
                    '词汇',
                    '${counts['vocabulary']} 条'),
                _buildStatRow(
                    Icons.lightbulb_outline,
                    '灵感',
                    '${counts['inspirations']} 条'),
                _buildStatRow(
                    Icons.auto_stories_outlined,
                    '剧情',
                    '${counts['plots']} 条'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.muted,
              borderRadius: AppTheme.wobblySmall,
            ),
            child: Icon(icon, color: AppTheme.textSecondary, size: 14),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
              )),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
