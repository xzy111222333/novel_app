import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildUserInfoCard(),
              const SizedBox(height: 20),
              _buildFunctionGrid(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Row(
      children: [
        _buildCircleButton(Icons.headphones_outlined),
        const Spacer(),
        const Text(
          '我的',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        _buildCircleButton(Icons.settings_outlined),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: AppTheme.textSecondary),
    );
  }

  // ── User Info Card ──
  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar + name + badge row
          Row(
            children: [
              // Avatar
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFFFCEFC7),
                child: Icon(Icons.person, size: 32, color: Color(0xFFD4A017)),
              ),
              const SizedBox(width: 16),
              // Name + join info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '墨客',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '已加入小灵感 128 天',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Premium badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEFC7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium, size: 14, color: Color(0xFFD4A017)),
                    SizedBox(width: 4),
                    Text(
                      '高级会员',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD4A017),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Divider
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 20),

          // Stats row
          IntrinsicHeight(
            child: Row(
              children: [
                _buildStatColumn('素材数', '128'),
                _buildVerticalDivider(),
                _buildStatColumn('词汇数', '86'),
                _buildVerticalDivider(),
                _buildStatColumn('灵感数', '35'),
                _buildVerticalDivider(),
                _buildStatColumn('剧情数', '42'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 14),

          // Bottom action strip
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.storage_outlined, size: 14, color: AppTheme.textTertiary),
                      const SizedBox(width: 6),
                      Text(
                        '数据管理',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '8小时前',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right, size: 14, color: AppTheme.textTertiary),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 16, color: const Color(0xFFF3F4F6)),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 14, color: AppTheme.textTertiary),
                      const SizedBox(width: 6),
                      Text(
                        '使用指南',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: const Color(0xFFF3F4F6),
    );
  }

  // ── Function Grid ──
  Widget _buildFunctionGrid() {
    final items = [
      _FunctionItem(Icons.folder_outlined, '分类管理'),
      _FunctionItem(Icons.label_outlined, '标签管理'),
      _FunctionItem(Icons.star_outline_rounded, '收藏夹'),
      _FunctionItem(Icons.search_rounded, '全局搜索'),
      _FunctionItem(Icons.file_download_outlined, '数据导出'),
      _FunctionItem(Icons.cloud_upload_outlined, '数据备份'),
      _FunctionItem(Icons.grid_view_rounded, '模块化设置'),
      _FunctionItem(Icons.palette_outlined, '个性化'),
      _FunctionItem(Icons.delete_outline_rounded, '最近删除'),
      _FunctionItem(Icons.chat_bubble_outline_rounded, '意见反馈'),
      _FunctionItem(Icons.info_outline_rounded, '关于我们'),
      _FunctionItem(Icons.settings_outlined, '设置'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 3;
          return Wrap(
            spacing: 0,
            runSpacing: 20,
            children: items.map((item) {
              return SizedBox(
                width: itemWidth,
                child: _buildFunctionItem(item),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildFunctionItem(_FunctionItem item) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(item.icon, size: 22, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FunctionItem {
  final IconData icon;
  final String label;
  const _FunctionItem(this.icon, this.label);
}
