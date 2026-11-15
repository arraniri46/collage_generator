import 'package:flutter/material.dart' show Rect;

/// Slots for the poster layout, in relative coordinates (0..1).
enum SlotOrientation {
  any,
  landscape,
  portrait,
  square,
}

/// A single photo slot inside a collage template.
///
/// [rect] is expressed in relative units (0..1) relative to the photo grid
/// area, so the same template works on any canvas aspect ratio.
final class TemplateSlot {
  const TemplateSlot({
    required this.rect,
    this.orientation = SlotOrientation.any,
  });

  /// Relative rectangle: left, top, width, height (each 0..1).
  final Rect rect;

  /// Preferred photo orientation for this slot (used as a hint only).
  final SlotOrientation orientation;

  TemplateSlot copyWith({Rect? rect, SlotOrientation? orientation}) =>
      TemplateSlot(
        rect: rect ?? this.rect,
        orientation: orientation ?? this.orientation,
      );

  Map<String, dynamic> toJson() => {
        'left': rect.left,
        'top': rect.top,
        'width': rect.width,
        'height': rect.height,
        'orientation': orientation.name,
      };

  static TemplateSlot fromJson(Map<String, dynamic> json) => TemplateSlot(
        rect: Rect.fromLTWH(
          (json['left'] as num).toDouble(),
          (json['top'] as num).toDouble(),
          (json['width'] as num).toDouble(),
          (json['height'] as num).toDouble(),
        ),
        orientation:
            SlotOrientation.values.byName(json['orientation'] as String? ??
                SlotOrientation.any.name),
      );
}

/// A collage layout template.
///
/// Layout is composed of three zones stacked vertically:
/// header (branding + title + date), photo grid (the slots), and footer
/// (badge with website URL). All sizes are relative (0..1) so the template
/// scales to any canvas aspect ratio.
final class CollageTemplate {
  const CollageTemplate({
    required this.id,
    required this.name,
    required this.slotCount,
    required this.slots,
    this.headerHeight = 0.0,
    this.footerHeight = 0.0,
    this.gap = 0.008,
    this.margin = 0.0,
  }) : assert(slotCount == slots.length || slotCount >= 0);

  final String id;
  final String name;
  final int slotCount;

  /// Height of header zone, relative to canvas height (0 = no header).
  final double headerHeight;

  /// Height of footer zone, relative to canvas height (0 = no footer).
  final double footerHeight;

  /// Gap between slots, relative to canvas width.
  final double gap;

  /// Outer margin of the photo grid, relative to canvas width.
  final double margin;

  final List<TemplateSlot> slots;

  CollageTemplate copyWith({
    String? id,
    String? name,
    int? slotCount,
    List<TemplateSlot>? slots,
    double? headerHeight,
    double? footerHeight,
    double? gap,
    double? margin,
  }) =>
      CollageTemplate(
        id: id ?? this.id,
        name: name ?? this.name,
        slotCount: slotCount ?? this.slotCount,
        slots: slots ?? this.slots,
        headerHeight: headerHeight ?? this.headerHeight,
        footerHeight: footerHeight ?? this.footerHeight,
        gap: gap ?? this.gap,
        margin: margin ?? this.margin,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slotCount': slotCount,
        'headerHeight': headerHeight,
        'footerHeight': footerHeight,
        'gap': gap,
        'margin': margin,
        'slots': slots.map((s) => s.toJson()).toList(),
      };

  static CollageTemplate fromJson(Map<String, dynamic> json) =>
      CollageTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        slotCount: json['slotCount'] as int,
        headerHeight: (json['headerHeight'] as num?)?.toDouble() ?? 0.0,
        footerHeight: (json['footerHeight'] as num?)?.toDouble() ?? 0.0,
        gap: (json['gap'] as num?)?.toDouble() ?? 0.008,
        margin: (json['margin'] as num?)?.toDouble() ?? 0.0,
        slots: (json['slots'] as List)
            .map((s) => TemplateSlot.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}
