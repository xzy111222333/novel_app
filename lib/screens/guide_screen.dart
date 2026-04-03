import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text('使用指南'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: const [
          _GuideCard(
            title: '1. 今日页',
            body: '顶部日期可以切换查看不同天的内容。点击卡片进入编辑，右上角加号用于快速新增。',
          ),
          SizedBox(height: 12),
          _GuideCard(
            title: '2. 收藏和回收站',
            body: '编辑页和列表页都可以收藏内容。删除不会立刻消失，会先进入“最近删除”里等待恢复。',
          ),
          SizedBox(height: 12),
          _GuideCard(
            title: '3. 数据备份',
            body: '在“数据管理”里可以复制完整 JSON 备份，也可以把之前导出的 JSON 粘贴回来恢复。',
          ),
          SizedBox(height: 12),
          _GuideCard(
            title: '4. 模块显示',
            body: '“模块化设置”会真实影响底部导航栏，词汇和剧情页可以按需打开或关闭。',
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final String title;
  final String body;

  const _GuideCard({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.smallCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
