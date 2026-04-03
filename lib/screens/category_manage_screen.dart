import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

class CategoryManageScreen extends StatefulWidget {
  final String module;

  const CategoryManageScreen({super.key, required this.module});

  @override
  State<CategoryManageScreen> createState() => _CategoryManageScreenState();
}

class _CategoryManageScreenState extends State<CategoryManageScreen> {
  final _ds = DataService.instance;

  String get _title {
    switch (widget.module) {
      case 'material':
        return '素材分类管理';
      case 'vocabulary':
        return '词汇分类管理';
      case 'plot':
        return '剧情分类管理';
      default:
        return '分类管理';
    }
  }

  int _countItemsInCategory(String category) {
    switch (widget.module) {
      case 'material':
        return _ds.materials.where((m) => m.category == category).length;
      case 'vocabulary':
        return _ds.vocabulary.where((v) => v.category == category).length;
      case 'plot':
        return _ds.plots.where((p) => p.category == category).length;
      default:
        return 0;
    }
  }

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

  Future<void> _showAddDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加分类'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入分类名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      _ds.addCategory(widget.module, result);
    }
  }

  Future<void> _showRenameDialog(String oldName) async {
    final controller = TextEditingController(text: oldName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名分类'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入新名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != oldName) {
      _ds.renameCategory(widget.module, oldName, result);
    }
  }

  Future<void> _showDeleteDialog(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除分类'),
        content: Text('确定要删除分类"$name"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _ds.deleteCategory(widget.module, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _ds.getCategories(widget.module);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(_title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            )),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.materialColor,
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text('暂无分类',
                  style: TextStyle(
                      color: AppTheme.textTertiary, fontSize: 12)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final count = _countItemsInCategory(cat);
                final color = AppTheme.getCategoryColor(cat);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: AppTheme.smallCardDecoration,
                  child: ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 2),
                    leading: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(cat,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        )),
                    subtitle: Text('$count 个条目',
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 10,
                        )),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppTheme.textSecondary, size: 18),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          onPressed: () => _showRenameDialog(cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent, size: 18),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          onPressed: () => _showDeleteDialog(cat),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
