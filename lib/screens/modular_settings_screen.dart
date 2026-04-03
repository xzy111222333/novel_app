import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

class ModularSettingsScreen extends StatefulWidget {
  const ModularSettingsScreen({super.key});

  @override
  State<ModularSettingsScreen> createState() => _ModularSettingsScreenState();
}

class _ModularSettingsScreenState extends State<ModularSettingsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('模块化设置',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Text('自定义底部标签栏显示的页面',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                )),
          ),

          // Default tabs section
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('默认标签页（不可关闭）',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
          ),
          _buildLockedRow(Icons.today, '今日', '查看今日创作内容'),
          _buildLockedRow(Icons.description_outlined, '素材', '管理写作素材'),
          _buildLockedRow(Icons.lightbulb_outline, '灵感', '记录灵感闪念'),
          _buildLockedRow(Icons.bar_chart, '统计', '查看创作数据统计'),
          _buildLockedRow(Icons.person_outline, '我的', '个人中心与设置'),

          const SizedBox(height: 16),

          // Optional tabs section
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('可选标签页（可开关）',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
          ),
          _buildToggleRow(
            Icons.text_fields,
            '词汇',
            '收集好词好句',
            'vocabulary',
          ),
          _buildToggleRow(
            Icons.auto_stories_outlined,
            '剧情',
            '管理剧情模板',
            'plots',
          ),

          const SizedBox(height: 16),

          // Note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.inspirationBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppTheme.inspirationColor, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text('开启后将显示在底部标签栏中',
                      style: TextStyle(
                        color: AppTheme.inspirationColor,
                        fontSize: 11,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedRow(IconData icon, String label, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: AppTheme.smallCardDecoration,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.textTertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 16),
        ),
        title: Text(label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            )),
        subtitle: Text(desc,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 10,
            )),
        trailing: const Icon(Icons.lock_outline,
            color: AppTheme.textTertiary, size: 16),
      ),
    );
  }

  Widget _buildToggleRow(
      IconData icon, String label, String desc, String tabKey) {
    final enabled = _ds.isOptionalTabEnabled(tabKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: AppTheme.smallCardDecoration,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: enabled
                ? AppTheme.materialColor.withValues(alpha: 0.12)
                : AppTheme.textTertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: enabled
                  ? AppTheme.materialColor
                  : AppTheme.textSecondary,
              size: 16),
        ),
        title: Text(label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            )),
        subtitle: Text(desc,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 10,
            )),
        trailing: Transform.scale(
          scale: 0.8,
          child: Switch(
            value: enabled,
            onChanged: (_) => _ds.toggleOptionalTab(tabKey),
            activeTrackColor: AppTheme.materialColor.withValues(alpha: 0.4),
            activeThumbColor: AppTheme.materialColor,
          ),
        ),
      ),
    );
  }
}
