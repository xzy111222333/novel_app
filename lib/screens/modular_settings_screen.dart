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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('模块化设置',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text('自定义底部标签栏显示的页面',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                )),
          ),

          // Default tabs section
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('默认标签页（不可关闭）',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                )),
          ),
          _buildLockedRow(Icons.today, '今日', '查看今日创作内容'),
          _buildLockedRow(Icons.description_outlined, '素材', '管理写作素材'),
          _buildLockedRow(Icons.lightbulb_outline, '灵感', '记录灵感闪念'),
          _buildLockedRow(Icons.bar_chart, '统计', '查看创作数据统计'),
          _buildLockedRow(Icons.person_outline, '我的', '个人中心与设置'),

          const SizedBox(height: 24),

          // Optional tabs section
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('可选标签页（可开关）',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
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

          const SizedBox(height: 24),

          // Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.inspirationBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppTheme.inspirationColor, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text('开启后将显示在底部标签栏中',
                      style: TextStyle(
                        color: AppTheme.inspirationColor,
                        fontSize: 13,
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.smallCardDecoration,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.textTertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 20),
        ),
        title: Text(label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            )),
        subtitle: Text(desc,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            )),
        trailing: const Icon(Icons.lock_outline,
            color: AppTheme.textTertiary, size: 20),
      ),
    );
  }

  Widget _buildToggleRow(
      IconData icon, String label, String desc, String tabKey) {
    final enabled = _ds.isOptionalTabEnabled(tabKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.smallCardDecoration,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled
                ? AppTheme.materialColor.withValues(alpha: 0.12)
                : AppTheme.textTertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              color: enabled
                  ? AppTheme.materialColor
                  : AppTheme.textSecondary,
              size: 20),
        ),
        title: Text(label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            )),
        subtitle: Text(desc,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            )),
        trailing: Switch(
          value: enabled,
          onChanged: (_) => _ds.toggleOptionalTab(tabKey),
          activeTrackColor: AppTheme.materialColor.withValues(alpha: 0.4),
          activeThumbColor: AppTheme.materialColor,
        ),
      ),
    );
  }
}
