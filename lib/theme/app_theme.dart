import 'package:flutter/material.dart';
import '../services/data_service.dart';

const String _fontFamily = 'Outfit';

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

/// Flat Design 扁平设计系统
/// 零阴影 · 色块结构 · 大胆字体 · 几何装饰
class AppTheme {
  // ─── 基础色板 ───
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color muted = Color(0xFFF3F4F6);

  // ─── 功能色 ───
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFFD1FAE5);
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentSoft = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);

  // ─── 模块色 — 每个模块有鲜明的色彩标识 ───
  static const Color materialColor = Color(0xFF3B82F6);
  static const Color materialBg = Color(0xFFEFF6FF);
  static const Color vocabularyColor = Color(0xFF10B981);
  static const Color vocabularyBg = Color(0xFFECFDF5);
  static const Color inspirationColor = Color(0xFFF59E0B);
  static const Color inspirationBg = Color(0xFFFFFBEB);
  static const Color plotColor = Color(0xFF8B5CF6);
  static const Color plotBg = Color(0xFFF5F3FF);

  // ─── 圆角 ───
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;

  // ─── 主题预设 — Flat Design 配色变体 ───
  static const List<ThemePreset> presets = [
    ThemePreset(id: 'default', label: '纯白', background: Color(0xFFFFFFFF), surface: Color(0xFFF3F4F6)),
    ThemePreset(id: 'rice', label: '暖白', background: Color(0xFFFFFBF5), surface: Color(0xFFFEF3C7)),
    ThemePreset(id: 'blue', label: '冰蓝', background: Color(0xFFF0F7FF), surface: Color(0xFFDBEAFE)),
    ThemePreset(id: 'green', label: '薄荷', background: Color(0xFFF0FDF4), surface: Color(0xFFD1FAE5)),
    ThemePreset(id: 'pink', label: '樱粉', background: Color(0xFFFFF1F2), surface: Color(0xFFFFE4E6)),
    ThemePreset(id: 'gray', label: '石墨', background: Color(0xFFF9FAFB), surface: Color(0xFFF3F4F6)),
  ];

  static ThemePreset get currentPreset {
    final id = DataService.instance.themePresetId;
    return presets.firstWhere(
      (preset) => preset.id == id,
      orElse: () => presets.first,
    );
  }

  static Color get scaffoldBackground => currentPreset.background;
  static Color get softBackground => currentPreset.surface;

  static Color getCategoryColor(String category) => textSecondary;

  static Color getCategoryBgColor(String category) => muted;

  // ─── 卡片装饰 — 零阴影，纯色块 ───
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusLg),
  );

  static BoxDecoration smallCardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusLg),
  );

  /// 色块卡片 — 用于彩色背景区域
  static BoxDecoration colorBlockDecoration(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radiusLg),
  );

  /// 实心圆形图标容器
  static BoxDecoration iconCircleDecoration({Color? color}) => BoxDecoration(
    color: color ?? primary,
    shape: BoxShape.circle,
  );

  /// 兼容旧接口 — 圆形按钮，改为扁平色块风格
  static BoxDecoration outlinedCircleDecoration({double size = 36}) =>
      BoxDecoration(
        color: muted,
        shape: BoxShape.circle,
        border: Border.all(color: divider, width: 2),
      );

  // ─── Typography helpers ───
  static TextStyle get headingXL => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.02 * 28,
    height: 1.15,
  );

  static TextStyle get headingLG => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.02 * 22,
    height: 1.2,
  );

  static TextStyle get headingMD => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.02 * 17,
  );

  static TextStyle get bodyLG => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMD => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get labelLG => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );

  static TextStyle get labelMD => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle get labelSM => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textTertiary,
  );

  // ─── ThemeData ───
  static ThemeData get themeData {
    const baseTextStyle = TextStyle(fontFamily: _fontFamily);
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: scaffoldBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingMD,
        iconTheme: const IconThemeData(color: textPrimary, size: 22),
      ),
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        error: danger,
        surface: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        outline: divider,
      ),
      textTheme: TextTheme(
        titleLarge: baseTextStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.02 * 22),
        titleMedium: baseTextStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.02 * 17),
        bodyLarge: baseTextStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary),
        bodyMedium: baseTextStyle.copyWith(fontSize: 13, fontWeight: FontWeight.w400, color: textPrimary),
        bodySmall: baseTextStyle.copyWith(fontSize: 11, fontWeight: FontWeight.w400, color: textSecondary),
        labelLarge: baseTextStyle.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary),
        labelMedium: baseTextStyle.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary),
        labelSmall: baseTextStyle.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: textTertiary),
      ),
      dividerColor: divider,
      splashColor: primary.withValues(alpha: 0.08),
      highlightColor: primary.withValues(alpha: 0.05),
    );
  }
}
