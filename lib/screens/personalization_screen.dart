import 'package:flutter/material.dart';

import '../services/data_service.dart';
import '../theme/app_theme.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  final _data = DataService.instance;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _data.profileName);
    _data.addListener(_handleChange);
  }

  @override
  void dispose() {
    _data.removeListener(_handleChange);
    _nameController.dispose();
    super.dispose();
  }

  void _handleChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _saveName() {
    _data.updateProfileName(_nameController.text);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          '个性化',
          style: AppTheme.headingStyleWith(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _saveName();
              Navigator.pop(context);
            },
            child: const Text(
              '完成',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '昵称',
                  style: AppTheme.headingStyleWith(fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  onSubmitted: (_) => _saveName(),
                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: '输入你的昵称',
                    hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
                    filled: true,
                    fillColor: AppTheme.softBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppTheme.border, width: 1.5),
                      borderRadius: AppTheme.wobblySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('主题风格', style: AppTheme.headingStyleWith(fontSize: 14)),
                const SizedBox(height: 8),
                const Text(
                  '当前使用「手绘草稿纸」风格',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
