import 'package:flutter/material.dart';

import '../../../core/models/collage_template.dart';
import '../../../core/theme/app_theme.dart';

/// Renders a wireframe preview of a [CollageTemplate] — used in the
/// template picker. Selected state adds golden accent borders on slots.
final class TemplateWireframe extends StatelessWidget {
  const TemplateWireframe({
    super.key,
    required this.template,
    required this.selected,
    this.color = AppColors.outline,
    this.backgroundColor = AppColors.surfaceVariant,
    this.showHeaderFooter = true,
  });

  final CollageTemplate template;

  /// Whether this template is currently selected (golden accent).
  final bool selected;
  final Color color;
  final Color backgroundColor;

  /// Whether to draw the header/footer zones of the template.
  final bool showHeaderFooter;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final gap = template.gap * w;
          final margin = template.margin * w;
          final headerH = template.headerHeight * h;
          final footerH = template.footerHeight * h;
          final gridTop = headerH + gap;
          final gridH = h - headerH - footerH - gap * 2;

          return Container(
            color: backgroundColor,
            padding: EdgeInsets.all(margin),
            child: CustomPaint(
              painter: _WireframePainter(
                slots: template.slots,
                color: color,
                accentColor: AppColors.accent,
                selected: selected,
                gap: gap,
                headerH: showHeaderFooter ? headerH : 0,
                footerH: showHeaderFooter ? footerH : 0,
                gridTop: showHeaderFooter ? gridTop : 0,
                gridH: showHeaderFooter ? gridH : h,
              ),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }
}

class _WireframePainter extends CustomPainter {
  _WireframePainter({
    required this.slots,
    required this.color,
    required this.accentColor,
    required this.selected,
    required this.gap,
    required this.headerH,
    required this.footerH,
    required this.gridTop,
    required this.gridH,
  });

  final List<TemplateSlot> slots;
  final Color color;
  final Color accentColor;
  final bool selected;
  final double gap;
  final double headerH;
  final double footerH;
  final double gridTop;
  final double gridH;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = selected ? color.withValues(alpha: 0.55) : color
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.012;

    final radius = Radius.circular(size.width * 0.012);

    // Header zone bar.
    if (headerH > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, headerH),
          radius,
        ),
        Paint()..color = color.withValues(alpha: 0.45),
      );
    }

    // Photo slots inside the grid area.
    for (final slot in slots) {
      final r = slot.rect;
      final rect = Rect.fromLTWH(
        r.left * size.width,
        gridTop + r.top * gridH,
        r.width * size.width,
        r.height * gridH,
      );
      final deflated = Rect.fromLTRB(
        rect.left + gap / 2,
        rect.top + gap / 2,
        rect.right - gap / 2,
        rect.bottom - gap / 2,
      );
      final rrect = RRect.fromRectAndRadius(deflated, radius);
      canvas.drawRRect(rrect, fillPaint);
      if (selected) {
        canvas.drawRRect(rrect, accentPaint);
      }
    }

    // Footer zone bar.
    if (footerH > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.45,
            size.height - footerH,
            size.width * 0.55,
            footerH,
          ),
          Radius.circular(footerH / 2),
        ),
        Paint()..color = color.withValues(alpha: 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WireframePainter oldDelegate) =>
      oldDelegate.slots != slots ||
      oldDelegate.color != color ||
      oldDelegate.selected != selected ||
      oldDelegate.gap != gap;
}

