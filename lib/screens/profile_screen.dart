import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import 'category_manage_screen.dart';
import 'tag_manage_screen.dart';
import 'favorites_screen.dart';
import 'global_search_screen.dart';
import 'modular_settings_screen.dart';
import 'export_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DataService _data = DataService.instance;

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
        const SizedBox(width: 40),
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
        GestureDetector(
          onTap: () => _showComingSoon('设置'),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.settings_outlined, size: 20, color: Colors.white),
          ),
        ),
      ],
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
          Row(
            children: [
              // Amber avatar with "灵"
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFFFCEFC7),
                child: Text(
                  '灵',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A017),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '小灵感用户',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '创作灵感收集工具',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
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
                      '会员',
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
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 20),

          // Stats row — live from DataService
          IntrinsicHeight(
            child: Row(
              children: [
                _buildStatColumn('素材', '${_data.materials.length}'),
                _buildVerticalDivider(),
                _buildStatColumn('词汇', '${_data.vocabulary.length}'),
                _buildVerticalDivider(),
                _buildStatColumn('灵感', '${_data.inspirations.length}'),
                _buildVerticalDivider(),
                _buildStatColumn('剧情', '${_data.plots.length}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 14),

          // Bottom action strip
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showComingSoon('数据管理'),
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
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right, size: 14, color: AppTheme.textTertiary),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 16, color: const Color(0xFFF3F4F6)),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showComingSoon('使用指南'),
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
      _FunctionItem(Icons.folder_outlined, '分类管理', const Color(0xFFE8F0FE), const Color(0xFF4285F4)),
      _FunctionItem(Icons.label_outlined, '标签管理', const Color(0xFFFCE4EC), const Color(0xFFE91E63)),
      _FunctionItem(Icons.star_outline_rounded, '收藏夹', const Color(0xFFFFF8E1), const Color(0xFFFF8F00)),
      _FunctionItem(Icons.search_rounded, '全局搜索', const Color(0xFFE0F2F1), const Color(0xFF009688)),
      _FunctionItem(Icons.file_download_outlined, '数据导出', const Color(0xFFF3E5F5), const Color(0xFF9C27B0)),
      _FunctionItem(Icons.cloud_upload_outlined, '数据备份', const Color(0xFFE8EAF6), const Color(0xFF3F51B5)),
      _FunctionItem(Icons.grid_view_rounded, '模块化设置', const Color(0xFFE0F7FA), const Color(0xFF00BCD4)),
      _FunctionItem(Icons.palette_outlined, '个性化', const Color(0xFFFBE9E7), const Color(0xFFFF5722)),
      _FunctionItem(Icons.delete_outline_rounded, '最近删除', const Color(0xFFEFEBE9), const Color(0xFF795548)),
      _FunctionItem(Icons.chat_bubble_outline_rounded, '意见反馈', const Color(0xFFE8F5E9), const Color(0xFF4CAF50)),
      _FunctionItem(Icons.info_outline_rounded, '关于我们', const Color(0xFFF1F8E9), const Color(0xFF689F38)),
      _FunctionItem(Icons.settings_outlined, '设置', const Color(0xFFF5F5F5), const Color(0xFF757575)),
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
      onTap: () => _handleFunctionTap(item.label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: item.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 24, color: item.iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Navigation ──
  void _handleFunctionTap(String label) {
    switch (label) {
      case '分类管理':
        _showCategoryModulePicker();
      case '标签管理':
        _push(const TagManageScreen());
      case '收藏夹':
        _push(const FavoritesScreen());
      case '全局搜索':
        _push(const GlobalSearchScreen());
      case '数据导出':
        _push(const ExportScreen());
      case '模块化设置':
        _push(const ModularSettingsScreen());
      default:
        _showComingSoon(label);
    }
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showComingSoon(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name — 功能开发中'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCategoryModulePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final options = [
          {'label': '素材分类', 'module': 'material'},
          {'label': '词汇分类', 'module': 'vocabulary'},
          {'label': '剧情分类', 'module': 'plot'},
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '选择分类模块',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map((opt) => ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(opt['label']!),
                      onTap: () {
                        Navigator.pop(ctx);
                        _push(CategoryManageScreen(module: opt['module']!));
                      },
                    )),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FunctionItem {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  const _FunctionItem(this.icon, this.label, this.bgColor, this.iconColor);
}
