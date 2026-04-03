import 'package:flutter/material.dart';
import '../services/data_service.dart';

class ThemePreset {
  final String id;
  final String label;
  final Color background;
  final Color surface;

  const ThemePreset({
    required this.id,
    required this.label,
    required this.background,
    required this.surface,
  });
}

/// 极简白色系主题，对齐小日常App风格
class AppTheme {
  static const Color background = Color(0xFFF7F8FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFFCCCCCC);
  static const Color divider = Color(0xFFF0F1F3);
  static const Color accent = Color(0xFFF7B500);
  static const Color accentSoft = Color(0xFFFFF8E1);
  static const Color danger = Color(0xFFE85D5D);

  // 模块色 — 极淡柔和，仅用于卡片背景/标记点
  static const Color materialColor = Color(0xFF8CB58C);
  static const Color materialBg = Color(0xFFF2F7F2);
  static const Color vocabularyColor = Color(0xFFBB9A9A);
  static const Color vocabularyBg = Color(0xFFF9F3F3);
  static const Color inspirationColor = Color(0xFF9AB5C4);
  static const Color inspirationBg = Color(0xFFF3F7FA);
  static const Color plotColor = Color(0xFFC4B07A);
  static const Color plotBg = Color(0xFFFAF7F0);

  static const List<ThemePreset> presets = [
    ThemePreset(id: 'default', label: '基础白', background: Color(0xFFF7F8FA), surface: Colors.white),
    ThemePreset(id: 'rice', label: '米白', background: Color(0xFFF8F5EE), surface: Colors.white),
    ThemePreset(id: 'blue', label: '淡蓝', background: Color(0xFFF3F6FB), surface: Colors.white),
    ThemePreset(id: 'green', label: '淡绿', background: Color(0xFFF3F8F5), surface: Colors.white),
    ThemePreset(id: 'pink', label: '淡粉', background: Color(0xFFFBF4F6), surface: Colors.white),
    ThemePreset(id: 'gray', label: '浅灰', background: Color(0xFFF3F4F6), surface: Colors.white),
  ];

  static ThemePreset get currentPreset {
    final id = DataService.instance.themePresetId;
    return presets.firstWhere(
      (preset) => preset.id == id,
      orElse: () => presets.first,
    );
  }

  static Color get scaffoldBackground => currentPreset.background;
  static Color get softBackground => currentPreset.background;

  // 分类标签统一用灰色调，不按分类名区分颜色
  static Color getCategoryColor(String category) => textSecondary;

  static Color getCategoryBgColor(String category) {
    return const Color(0xFFF5F5F5);
  }

  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration smallCardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02),
        blurRadius: 6,
        offset: const Offset(0, 1),
      ),
    ],
  );

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textSecondary, size: 20),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        surface: background,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 13, color: textPrimary),
        bodySmall: TextStyle(fontSize: 11, color: textSecondary),
        labelSmall: TextStyle(fontSize: 10, color: textTertiary),
      ),
    );
  }
}
