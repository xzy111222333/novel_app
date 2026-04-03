import 'package:flutter/material.dart';

/// 小日常-inspired minimal theme: mostly white, small fonts, subtle accents
class AppTheme {
  // Core palette — predominantly white, very subtle
  static const Color background = Color(0xFFF5F6F8);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFFB0B6BF);
  static const Color divider = Color(0xFFF0F0F0);
  static const Color accent = Color(0xFFF7B500); // 小日常 amber/yellow

  // Module colors — very subtle, muted
  static const Color materialColor = Color(0xFF6B9F6B);
  static const Color materialBg = Color(0xFFEDF5ED);
  static const Color vocabularyColor = Color(0xFFC47A7A);
  static const Color vocabularyBg = Color(0xFFFAF0F0);
  static const Color inspirationColor = Color(0xFF6B9FB5);
  static const Color inspirationBg = Color(0xFFEDF4F7);
  static const Color plotColor = Color(0xFFCCA945);
  static const Color plotBg = Color(0xFFFAF6EC);

  // Category colors — muted tones, not saturated
  static const Map<String, Color> categoryColors = {
    '对话': Color(0xFF8B7EC8),
    '动作描写': Color(0xFFC4845A),
    '心理描写': Color(0xFF6B8FC4),
    '人物描写': Color(0xFFC46B8A),
    '环境描写': Color(0xFF6BAF6B),
    '情绪描写': Color(0xFFC49F45),
    '颜色词汇': Color(0xFF8B7EC8),
    '打脸剧情': Color(0xFFC49F45),
    '总裁剧情': Color(0xFF6B8FC4),
    '宫斗剧情': Color(0xFF8B7EC8),
    '甜宠剧情': Color(0xFFC46B8A),
    '校园剧情': Color(0xFF6BAF6B),
    '装逼剧情': Color(0xFFC4845A),
    '憋屈剧情': Color(0xFF8B9BAF),
    '未婚先孕': Color(0xFFC47A7A),
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? textSecondary;
  }

  static Color getCategoryBgColor(String category) {
    final color = getCategoryColor(category);
    return color.withValues(alpha: 0.08);
  }

  // Card decorations — minimal shadow, like 小日常
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02),
        blurRadius: 8,
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

  // ThemeData — compact fonts
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textSecondary, size: 20),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        surface: background,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 13, color: textPrimary),
        bodySmall: TextStyle(fontSize: 11, color: textSecondary),
        labelSmall: TextStyle(fontSize: 10, color: textTertiary),
      ),
    );
  }
}
