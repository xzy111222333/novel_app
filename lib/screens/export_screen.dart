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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('数据导出',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Export option card
          Container(
            decoration: AppTheme.cardDecoration,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.materialBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.file_download_outlined,
                      color: AppTheme.materialColor, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('导出全部数据 (JSON)',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 8),
                const Text('将所有内容导出为 JSON 格式并复制到剪贴板',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _exportAndCopy,
                    icon:
                        const Icon(Icons.copy, color: Colors.white, size: 20),
                    label: const Text('复制到剪贴板',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.materialColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats card
          Container(
            decoration: AppTheme.cardDecoration,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('数据概览',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 16),
                _buildStatRow(
                    Icons.description_outlined,
                    '素材',
                    '${counts['materials']} 条',
                    AppTheme.materialColor,
                    AppTheme.materialBg),
                _buildStatRow(
                    Icons.text_fields,
                    '词汇',
                    '${counts['vocabulary']} 条',
                    AppTheme.vocabularyColor,
                    AppTheme.vocabularyBg),
                _buildStatRow(
                    Icons.lightbulb_outline,
                    '灵感',
                    '${counts['inspirations']} 条',
                    AppTheme.inspirationColor,
                    AppTheme.inspirationBg),
                _buildStatRow(
                    Icons.auto_stories_outlined,
                    '剧情',
                    '${counts['plots']} 条',
                    AppTheme.plotColor,
                    AppTheme.plotBg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      IconData icon, String label, String value, Color color, Color bg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
              )),
          const Spacer(),
          Text(value,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
