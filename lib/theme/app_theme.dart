import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 手绘 / 草稿纸风格设计系统
class AppTheme {
  // ── 色彩 Token ────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFDFBF7);     // 暖纸色
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D2D2D);    // 铅笔黑
  static const Color textSecondary = Color(0xFF6B6B6B);  // 浅铅笔
  static const Color textTertiary = Color(0xFFADA89F);   // 淡墨
  static const Color muted = Color(0xFFE5E0D8);          // 旧纸 / 擦除痕迹
  static const Color divider = Color(0xFFE5E0D8);
  static const Color accent = Color(0xFFFF4D4D);         // 红色修正笔
  static const Color accentSoft = Color(0xFFFFE5E5);
  static const Color secondary = Color(0xFF2D5DA1);      // 蓝色圆珠笔
  static const Color danger = Color(0xFFFF4D4D);
  static const Color postIt = Color(0xFFFFF9C4);         // 便签黄
  static const Color border = Color(0xFF2D2D2D);         // 铅笔边框

  // 模块色 — 手绘风柔和色调
  static const Color materialColor = Color(0xFF2D5DA1);
  static const Color materialBg = Color(0xFFF0F4FA);
  static const Color vocabularyColor = Color(0xFFFF4D4D);
  static const Color vocabularyBg = Color(0xFFFFF0F0);
  static const Color inspirationColor = Color(0xFF2D2D2D);
  static const Color inspirationBg = Color(0xFFFDFBF7);
  static const Color plotColor = Color(0xFF6B8E5A);
  static const Color plotBg = Color(0xFFF5F8F2);

  // ── 不规则 Wobbly 圆角 ────────────────────────────────────────────────
  static const BorderRadius wobbly = BorderRadius.only(
    topLeft: Radius.elliptical(255, 15),
    topRight: Radius.elliptical(15, 225),
    bottomRight: Radius.elliptical(225, 15),
    bottomLeft: Radius.elliptical(15, 255),
  );

  static const BorderRadius wobblyMd = BorderRadius.only(
    topLeft: Radius.elliptical(80, 12),
    topRight: Radius.elliptical(12, 80),
    bottomRight: Radius.elliptical(80, 12),
    bottomLeft: Radius.elliptical(12, 80),
  );

  static const BorderRadius wobblySmall = BorderRadius.only(
    topLeft: Radius.elliptical(40, 8),
    topRight: Radius.elliptical(8, 40),
    bottomRight: Radius.elliptical(40, 8),
    bottomLeft: Radius.elliptical(8, 40),
  );

  static const BorderRadius wobblyPill = BorderRadius.only(
    topLeft: Radius.elliptical(20, 12),
    topRight: Radius.elliptical(12, 20),
    bottomRight: Radius.elliptical(20, 12),
    bottomLeft: Radius.elliptical(12, 20),
  );

  // ── 硬偏移阴影 (无模糊) ──────────────────────────────────────────────
  static const List<BoxShadow> hardShadow = [
    BoxShadow(
      color: Color(0xFF2D2D2D),
      offset: Offset(4, 4),
      blurRadius: 0,
    ),
  ];

  static const List<BoxShadow> hardShadowSmall = [
    BoxShadow(
      color: Color(0xFF2D2D2D),
      offset: Offset(3, 3),
      blurRadius: 0,
    ),
  ];

  static const List<BoxShadow> hardShadowSubtle = [
    BoxShadow(
      color: Color(0x1A2D2D2D),
      offset: Offset(3, 3),
      blurRadius: 0,
    ),
  ];

  static const List<BoxShadow> hardShadowHover = [
    BoxShadow(
      color: Color(0xFF2D2D2D),
      offset: Offset(2, 2),
      blurRadius: 0,
    ),
  ];

  // ── 统一背景色 ────────────────────────────────────────────────────────
  static Color get scaffoldBackground => background;
  static Color get softBackground => background;

  // ── 分类颜色 ──────────────────────────────────────────────────────────
  static Color getCategoryColor(String category) => textPrimary;
  static Color getCategoryBgColor(String category) => muted;

  // ── 卡片装饰 ──────────────────────────────────────────────────────────
  static BoxDecoration get cardDecoration => const BoxDecoration(
    color: cardBackground,
    borderRadius: wobblyMd,
    border: Border.fromBorderSide(BorderSide(color: border, width: 2)),
    boxShadow: hardShadowSubtle,
  );

  static BoxDecoration get smallCardDecoration => const BoxDecoration(
    color: cardBackground,
    borderRadius: wobblySmall,
    border: Border.fromBorderSide(BorderSide(color: border, width: 2)),
    boxShadow: hardShadowSubtle,
  );

  static BoxDecoration get postItDecoration => const BoxDecoration(
    color: postIt,
    borderRadius: wobblyMd,
    border: Border.fromBorderSide(BorderSide(color: border, width: 2)),
    boxShadow: hardShadowSubtle,
  );

  /// 手绘风圆形按钮
  static BoxDecoration outlinedCircleDecoration({double size = 36}) =>
      const BoxDecoration(
        color: cardBackground,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(BorderSide(color: border, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2D2D2D),
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      );

  // ── 纸张纹理背景装饰 ──────────────────────────────────────────────────
  static BoxDecoration get paperTextureDecoration => const BoxDecoration(
    color: background,
  );

  // ── 手绘风胶带装饰 Widget ─────────────────────────────────────────────
  static Widget tapeDecoration({double width = 60, double rotation = -0.05}) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFFD4D0C8).withAlpha(180),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: const Color(0xFFB8B4AC), width: 0.5),
        ),
      ),
    );
  }

  /// 手绘风图钉装饰 Widget
  static Widget tackDecoration({Color color = accent}) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFF2D2D2D), width: 1.5),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0xFF2D2D2D), offset: Offset(1, 1)),
        ],
      ),
    );
  }

  // ── 字体样式 ──────────────────────────────────────────────────────────
  static TextStyle get headingStyle => GoogleFonts.zcoolKuaiLe(
    color: textPrimary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle headingStyleWith({
    double fontSize = 20,
    Color? color,
    FontWeight? fontWeight,
  }) => GoogleFonts.zcoolKuaiLe(
    fontSize: fontSize,
    color: color ?? textPrimary,
    fontWeight: fontWeight ?? FontWeight.w400,
  );

  // ── ThemeData ─────────────────────────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.zcoolKuaiLe(
          color: textPrimary,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 22),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        surface: background,
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.zcoolKuaiLe(
          fontSize: 20,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.zcoolKuaiLe(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: const TextStyle(fontSize: 14, color: textPrimary),
        bodySmall: const TextStyle(fontSize: 12, color: textSecondary),
        labelSmall: const TextStyle(fontSize: 11, color: textTertiary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: wobblySmall,
          side: const BorderSide(color: border, width: 2),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: wobblyMd,
          side: const BorderSide(color: border, width: 2),
        ),
        titleTextStyle: GoogleFonts.zcoolKuaiLe(
          fontSize: 18,
          color: textPrimary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.elliptical(80, 16),
            topRight: Radius.elliptical(16, 80),
          ),
          side: BorderSide(color: border, width: 2),
        ),
      ),
    );
  }
}
