import 'package:flutter/material.dart';

class AppTheme {
  // Main colors
  static const Color background = Color(0xFFF7F8FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  // Module theme colors (matching HTML prototypes)
  static const Color materialColor = Color(0xFF5B8A5A);
  static const Color materialBg = Color(0xFFD5E8D4);
  static const Color vocabularyColor = Color(0xFFA94442);
  static const Color vocabularyBg = Color(0xFFF8D7DA);
  static const Color inspirationColor = Color(0xFF4A8B9F);
  static const Color inspirationBg = Color(0xFFD0E8F2);
  static const Color plotColor = Color(0xFFD4A017);
  static const Color plotBg = Color(0xFFFCEFC7);
  
  // Category tag colors
  static const Map<String, Color> categoryColors = {
    '对话': Color(0xFF7C3AED),
    '动作描写': Color(0xFFEA580C),
    '心理描写': Color(0xFF2563EB),
    '人物描写': Color(0xFFDB2777),
    '环境描写': Color(0xFF16A34A),
    '情绪描写': Color(0xFFD97706),
    '颜色词汇': Color(0xFF7C3AED),
    '打脸剧情': Color(0xFFD4A017),
    '总裁剧情': Color(0xFF2563EB),
    '宫斗剧情': Color(0xFF7C3AED),
    '甜宠剧情': Color(0xFFDB2777),
    '校园剧情': Color(0xFF16A34A),
    '装逼剧情': Color(0xFFEA580C),
    '憋屈剧情': Color(0xFF6B7280),
    '未婚先孕': Color(0xFFA94442),
  };
  
  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? textSecondary;
  }
  
  static Color getCategoryBgColor(String category) {
    final color = getCategoryColor(category);
    return color.withValues(alpha: 0.1);
  }

  // Card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration smallCardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ThemeData
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      fontFamily: '.SF Pro Text',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textSecondary),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1F2937),
        surface: background,
      ),
    );
  }
}
