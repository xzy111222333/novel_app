import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import 'category_manage_screen.dart';
import 'tag_manage_screen.dart';
import 'favorites_screen.dart';
import 'global_search_screen.dart';
import 'modular_settings_screen.dart';
import 'export_screen.dart';
import 'data_management_screen.dart';
import 'personalization_screen.dart';
import 'recent_deleted_screen.dart';
import 'guide_screen.dart';

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
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildUserInfoCard(),
              const SizedBox(height: 14),
              _buildFunctionGrid(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const SizedBox(width: 32),
        const Spacer(),
        const Text(
          '我的',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _push(const PersonalizationScreen()),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.settings_outlined, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFFCEFC7),
                child: Text(
                  '灵',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A017),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _data.profileName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '创作灵感收集工具',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _push(const FavoritesScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: Color(0xFFFF8F00)),
                      SizedBox(width: 4),
                      Text(
                        '收藏夹',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF8F00),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 14),
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
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _push(const DataManagementScreen()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.storage_outlined, size: 12, color: AppTheme.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '数据管理',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right, size: 12, color: AppTheme.textTertiary),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 14, color: const Color(0xFFF3F4F6)),
              Expanded(
                child: GestureDetector(
                  onTap: () => _push(const GuideScreen()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 12, color: AppTheme.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '使用指南',
                        style: TextStyle(
                          fontSize: 10,
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
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

  Widget _buildFunctionGrid() {
    final items = [
      _FunctionItem(Icons.folder_outlined, '分类管理', const Color(0xFFE8F0FE), const Color(0xFF4285F4)),
      _FunctionItem(Icons.label_outlined, '标签管理', const Color(0xFFFCE4EC), const Color(0xFFE91E63)),
      _FunctionItem(Icons.star_outline_rounded, '收藏夹', const Color(0xFFFFF8E1), const Color(0xFFFF8F00)),
      _FunctionItem(Icons.search_rounded, '全局搜索', const Color(0xFFE0F2F1), const Color(0xFF009688)),
      _FunctionItem(Icons.file_download_outlined, '数据导出', const Color(0xFFF3E5F5), const Color(0xFF9C27B0)),
      _FunctionItem(Icons.cloud_upload_outlined, '数据管理', const Color(0xFFE8EAF6), const Color(0xFF3F51B5)),
      _FunctionItem(Icons.grid_view_rounded, '模块化设置', const Color(0xFFE0F7FA), const Color(0xFF00BCD4)),
      _FunctionItem(Icons.palette_outlined, '个性化', const Color(0xFFFBE9E7), const Color(0xFFFF5722)),
      _FunctionItem(Icons.delete_outline_rounded, '最近删除', const Color(0xFFEFEBE9), const Color(0xFF795548)),
      _FunctionItem(Icons.menu_book_outlined, '使用指南', const Color(0xFFE8F5E9), const Color(0xFF4CAF50)),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 4;
          return Wrap(
            spacing: 0,
            runSpacing: 14,
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 18, color: item.iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleFunctionTap(String label) {
    switch (label) {
      case '分类管理':
        _showCategoryModulePicker();
        break;
      case '标签管理':
        _push(const TagManageScreen());
        break;
      case '收藏夹':
        _push(const FavoritesScreen());
        break;
      case '全局搜索':
        _push(const GlobalSearchScreen());
        break;
      case '数据导出':
        _push(const ExportScreen());
        break;
      case '模块化设置':
        _push(const ModularSettingsScreen());
        break;
      case '数据管理':
        _push(const DataManagementScreen());
        break;
      case '个性化':
        _push(const PersonalizationScreen());
        break;
      case '最近删除':
        _push(const RecentlyDeletedScreen());
        break;
      case '使用指南':
        _push(const GuideScreen());
        break;
    }
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
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
