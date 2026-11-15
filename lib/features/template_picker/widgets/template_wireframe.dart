import 'package:flutter/material.dart';

import '../../../core/models/collage_template.dart';

/// Renders a grey wireframe preview of a [CollageTemplate] — used in the
/// template picker (and reusable for the poster canvas in the next phase).
final class TemplateWireframe extends StatelessWidget {
  const TemplateWireframe({
    super.key,
    required this.template,
    this.color = const Color(0xFFB9C4D0),
    this.backgroundColor = const Color(0xFFF3F5F8),
    this.showHeaderFooter = true,
  });

  final CollageTemplate template;
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
    required this.gap,
    required this.headerH,
    required this.footerH,
    required this.gridTop,
    required this.gridH,
  });

  final List<TemplateSlot> slots;
  final Color color;
  final double gap;
  final double headerH;
  final double footerH;
  final double gridTop;
  final double gridH;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

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
        r.width * size.width - gap * 0, // slots already include internal gaps
        r.height * gridH,
      );
      final deflated = Rect.fromLTRB(
        rect.left + gap / 2,
        rect.top + gap / 2,
        rect.right - gap / 2,
        rect.bottom - gap / 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(deflated, radius),
        paint,
      );
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
      oldDelegate.gap != gap;
}
