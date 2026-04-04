import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_theme.dart';

class ShareCardUtil {
  static Future<void> shareAsImage(
    BuildContext context, {
    required String typeLabel,
    required String content,
    String? title,
    String? meta,
    List<String> tags = const [],
    Color accentColor = AppTheme.accent,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    try {
      final imageBytes = await _buildImageBytes(
        typeLabel: typeLabel,
        title: title,
        content: content,
        meta: meta,
        tags: tags,
        accentColor: accentColor,
      );
      await SharePlus.instance.share(
        ShareParams(
          title: '分享$typeLabel',
          text: title ?? content,
          files: [
            XFile.fromData(
              imageBytes,
              mimeType: 'image/png',
              name: 'xiaolinggan-$typeLabel.png',
            ),
          ],
          fileNameOverrides: [
            '小灵感-$typeLabel-${DateTime.now().millisecondsSinceEpoch}.png',
          ],
          sharePositionOrigin: renderBox == null
              ? null
              : renderBox.localToGlobal(Offset.zero) & renderBox.size,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('分享失败，请稍后重试'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<Uint8List> _buildImageBytes({
    required String typeLabel,
    String? title,
    required String content,
    String? meta,
    required List<String> tags,
    required Color accentColor,
  }) async {
    const double width = 1080;
    const double height = 1600;
    const double outerPadding = 56;
    const double cardPadding = 52;
    const double cardTop = 120;
    final double cardWidth = width - outerPadding * 2;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Warm paper background
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, height),
      Paint()..color = AppTheme.background,
    );

    // Dot grid paper texture
    final dotPaint = Paint()..color = AppTheme.muted;
    for (double dx = 0; dx < width; dx += 48) {
      for (double dy = 0; dy < height; dy += 48) {
        canvas.drawCircle(Offset(dx, dy), 1.5, dotPaint);
      }
    }

    // Hand-drawn card with hard offset shadow
    final cardRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(outerPadding, cardTop, cardWidth, 1200),
      topLeft: const Radius.elliptical(80, 12),
      topRight: const Radius.elliptical(12, 80),
      bottomRight: const Radius.elliptical(80, 12),
      bottomLeft: const Radius.elliptical(12, 80),
    );
    // Hard shadow (offset, no blur)
    final shadowRect = cardRect.shift(const Offset(8, 8));
    canvas.drawRRect(shadowRect, Paint()..color = AppTheme.textPrimary);
    // Card fill
    canvas.drawRRect(cardRect, Paint()..color = Colors.white);
    // Thick pencil border
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = AppTheme.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    double y = cardTop + cardPadding;
    final double left = outerPadding + cardPadding;
    final double contentWidth = cardWidth - cardPadding * 2;

    // Tape decoration at top center of card
    final tapeRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(width / 2, cardTop),
        width: 140,
        height: 36,
      ),
      topLeft: const Radius.elliptical(8, 4),
      topRight: const Radius.elliptical(4, 8),
      bottomRight: const Radius.elliptical(8, 4),
      bottomLeft: const Radius.elliptical(4, 8),
    );
    canvas.drawRRect(tapeRect, Paint()..color = AppTheme.muted.withAlpha(180));

    // Wobbly accent circle
    canvas.drawCircle(
      Offset(left + 14, y + 14),
      14,
      Paint()..color = accentColor,
    );
    // Pencil border around accent circle
    canvas.drawCircle(
      Offset(left + 14, y + 14),
      14,
      Paint()
        ..color = AppTheme.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final typePainter = _textPainter(
      typeLabel,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: contentWidth - 44,
    );
    typePainter.paint(canvas, Offset(left + 44, y));
    y += 52;

    if ((meta ?? '').isNotEmpty) {
      final metaPainter = _textPainter(
        meta!,
        style: const TextStyle(
          color: AppTheme.textTertiary,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        maxWidth: contentWidth,
      );
      metaPainter.paint(canvas, Offset(left, y));
      y += metaPainter.height + 28;
    }

    if ((title ?? '').isNotEmpty) {
      final titlePainter = _textPainter(
        title!,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 42,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
        maxWidth: contentWidth,
        maxLines: 2,
      );
      titlePainter.paint(canvas, Offset(left, y));
      y += titlePainter.height + 26;
    }

    final contentPainter = _textPainter(
      content,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w500,
        height: 1.7,
      ),
      maxWidth: contentWidth,
      maxLines: 14,
      ellipsis: '...',
    );
    contentPainter.paint(canvas, Offset(left, y));
    y += contentPainter.height + 40;

    if (tags.isNotEmpty) {
      final tagLine = tags.take(6).map((tag) => '#$tag').join('   ');
      final tagsPainter = _textPainter(
        tagLine,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
        maxWidth: contentWidth,
        maxLines: 2,
      );
      tagsPainter.paint(canvas, Offset(left, y));
    }

    final footerTop = cardTop + 1200 - 110;

    // Dashed line separator above footer
    final dashPaint = Paint()
      ..color = AppTheme.muted
      ..strokeWidth = 2;
    for (double dx = left; dx < left + contentWidth; dx += 16) {
      canvas.drawLine(
        Offset(dx, footerTop - 24),
        Offset(dx + 8, footerTop - 24),
        dashPaint,
      );
    }

    final appPainter = _textPainter(
      '来自小灵感',
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: contentWidth,
    );
    appPainter.paint(canvas, Offset(left, footerTop));

    final subPainter = _textPainter(
      '记录你的灵感、词汇、素材与剧情',
      style: const TextStyle(
        color: AppTheme.textTertiary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      maxWidth: contentWidth,
    );
    subPainter.paint(canvas, Offset(left, footerTop + 34));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static TextPainter _textPainter(
    String text, {
    required TextStyle style,
    required double maxWidth,
    int? maxLines,
    String? ellipsis,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: ellipsis,
    )..layout(maxWidth: maxWidth);
    return painter;
  }
}
