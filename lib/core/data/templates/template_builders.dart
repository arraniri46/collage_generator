import 'package:flutter/material.dart' show Rect;

import '../../models/collage_template.dart';

/// Shared helpers to build template slot layouts in relative coordinates.
///
/// All coordinates are relative (0..1). [gap] is applied between slots;
/// helper functions take care of subtracting gaps when splitting regions.
final class Tpl {
  Tpl._();

  /// A single slot filling the whole grid area.
  static List<TemplateSlot> single() => [
        TemplateSlot(rect: Rect.fromLTWH(0, 0, 1, 1)),
      ];

  /// Split horizontally into [n] equal rows (full-width strips).
  static List<TemplateSlot> rows(int n, {double gap = 0.008}) {
    final rowH = (1 - gap * (n - 1)) / n;
    return List.generate(n, (i) {
      final top = i * (rowH + gap);
      return TemplateSlot(
        rect: Rect.fromLTWH(0, top, 1, rowH),
        orientation: SlotOrientation.landscape,
      );
    });
  }

  /// Split vertically into [n] equal columns.
  static List<TemplateSlot> columns(int n, {double gap = 0.008}) {
    final colW = (1 - gap * (n - 1)) / n;
    return List.generate(n, (i) {
      final left = i * (colW + gap);
      return TemplateSlot(
        rect: Rect.fromLTWH(left, 0, colW, 1),
        orientation: SlotOrientation.portrait,
      );
    });
  }

  /// Uniform grid [rows] x [cols] (row-major order).
  static List<TemplateSlot> grid(int rows, int cols, {double gap = 0.008}) {
    final rowH = (1 - gap * (rows - 1)) / rows;
    final colW = (1 - gap * (cols - 1)) / cols;
    return [
      for (var r = 0; r < rows; r++)
        for (var c = 0; c < cols; c++)
          TemplateSlot(
            rect: Rect.fromLTWH(
              c * (colW + gap),
              r * (rowH + gap),
              colW,
              rowH,
            ),
          ),
    ];
  }

  /// 2 x 2 grid of squares.
  static List<TemplateSlot> grid2x2({double gap = 0.008}) =>
      grid(2, 2, gap: gap);

  /// One big landscape slot on top, [smallCount] small slots below.
  static List<TemplateSlot> bigTop({
    int smallCount = 2,
    double gap = 0.008,
    double bigHeight = 0.55,
  }) {
    final smallH = 1 - bigHeight - gap;
    final smallW = (1 - gap * (smallCount - 1)) / smallCount;
    return [
      TemplateSlot(
        rect: Rect.fromLTWH(0, 0, 1, bigHeight),
        orientation: SlotOrientation.landscape,
      ),
      for (var i = 0; i < smallCount; i++)
        TemplateSlot(
          rect: Rect.fromLTWH(i * (smallW + gap), bigHeight + gap, smallW, smallH),
        ),
    ];
  }

  /// One big slot on the left, a column of [smallCount] slots on the right.
  static List<TemplateSlot> bigLeft({
    int smallCount = 2,
    double gap = 0.008,
    double bigWidth = 0.6,
  }) {
    final smallW = 1 - bigWidth - gap;
    final smallH = (1 - gap * (smallCount - 1)) / smallCount;
    return [
      TemplateSlot(
        rect: Rect.fromLTWH(0, 0, bigWidth, 1),
        orientation: SlotOrientation.landscape,
      ),
      for (var i = 0; i < smallCount; i++)
        TemplateSlot(
          rect: Rect.fromLTWH(bigWidth + gap, i * (smallH + gap), smallW, smallH),
        ),
    ];
  }

  /// Two half-width slots stacked in one row (side by side).
  static List<TemplateSlot> pairRow({
    double gap = 0.008,
    double top = 0,
    double height = 1,
  }) {
    final w = (1 - gap) / 2;
    return [
      TemplateSlot(rect: Rect.fromLTWH(0, top, w, height)),
      TemplateSlot(rect: Rect.fromLTWH(w + gap, top, w, height)),
    ];
  }

  /// Reference template layout (8 photos, two asymmetric columns 4|4).
  ///
  /// Left column: landscape, two small squares side by side, landscape.
  /// Right column: four full-height landscape strips.
  static List<TemplateSlot> reference8({double gap = 0.012}) {
    final colW = (1 - gap) / 2;
    final rightW = colW;

    // Left column internals (relative to full grid for simplicity).
    final leftTopH = 0.30;
    final midH = 0.30;
    final leftBottomTop = leftTopH + gap + midH + gap;
    final leftBottomH = 1 - leftBottomTop;
    final smallW = (colW - gap) / 2;

    // Right column: 4 equal strips.
    final stripH = (1 - gap * 3) / 4;

    return [
      // Left column
      TemplateSlot(
        rect: Rect.fromLTWH(0, 0, colW, leftTopH),
        orientation: SlotOrientation.landscape,
      ),
      TemplateSlot(
        rect: Rect.fromLTWH(0, leftTopH + gap, smallW, midH),
        orientation: SlotOrientation.square,
      ),
      TemplateSlot(
        rect: Rect.fromLTWH(smallW + gap, leftTopH + gap, smallW, midH),
        orientation: SlotOrientation.square,
      ),
      TemplateSlot(
        rect: Rect.fromLTWH(0, leftBottomTop, colW, leftBottomH),
        orientation: SlotOrientation.landscape,
      ),
      // Right column: 4 landscape strips
      for (var i = 0; i < 4; i++)
        TemplateSlot(
          rect: Rect.fromLTWH(
            colW + gap,
            i * (stripH + gap),
            rightW,
            stripH,
          ),
          orientation: SlotOrientation.landscape,
        ),
    ];
  }
}
