import 'package:flutter/material.dart';

/// The Pengayoman (Kementerian Hukum) logo asset.
///
/// Renders the logo from assets/branding/pengayoman_logo.png. While the
/// real logo file has not been dropped in yet (the placeholder is a 1px
/// transparent PNG), a drawn fallback mark is shown instead so the UI
/// never looks broken.
final class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 32, this.showFallbackText = false});

  /// Square size of the logo in logical pixels.
  final double size;

  /// Whether to show the "PENGAYOMAN" wordmark next to the logo.
  final bool showFallbackText;

  static const String assetPath = 'assets/branding/pengayoman_logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _FallbackMark(
        size: size,
        showText: showFallbackText,
      ),
    );
  }
}

/// Temporary drawn mark (navy rounded square + golden arches silhouette)
/// used until the real logo file is provided.
class _FallbackMark extends StatelessWidget {
  const _FallbackMark({required this.size, required this.showText});

  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2C5D),
        borderRadius: BorderRadius.circular(size * 0.18),
      ),
      child: CustomPaint(
        painter: _ArchesPainter(color: const Color(0xFFFFCB05)),
      ),
    );
    if (!showText) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'PENGAYOMAN',
            style: TextStyle(
              color: const Color(0xFF1B2C5D),
              fontSize: size * 0.38,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArchesPainter extends CustomPainter {
  _ArchesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07;

    // Three arches (like the Pengayoman tree silhouette).
    final w = size.width;
    final h = size.height;
    final bigArch = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.42),
      width: w * 0.34,
      height: w * 0.34,
    );
    final leftArch = Rect.fromCenter(
      center: Offset(w * 0.32, h * 0.52),
      width: w * 0.28,
      height: w * 0.28,
    );
    final rightArch = Rect.fromCenter(
      center: Offset(w * 0.68, h * 0.52),
      width: w * 0.28,
      height: w * 0.28,
    );

    canvas.drawArc(bigArch, 3.14159, 3.14159, false, paint);
    canvas.drawArc(leftArch, 3.14159, 3.14159, false, paint);
    canvas.drawArc(rightArch, 3.14159, 3.14159, false, paint);

    // Trunk lines.
    canvas.drawLine(
      Offset(w * 0.46, h * 0.5),
      Offset(w * 0.46, h * 0.78),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.5, h * 0.56),
      Offset(w * 0.5, h * 0.78),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.54, h * 0.5),
      Offset(w * 0.54, h * 0.78),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArchesPainter oldDelegate) =>
      oldDelegate.color != color;
}
