import 'dart:ui';

/// Runtime data of a single photo slot in a report (photo + transform).
enum SlotFitMode { cover, contain }

final class SlotData {
  const SlotData({
    this.fotoPath,
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.fitMode = SlotFitMode.cover,
  });

  /// Local file path of the picked photo (null = empty slot).
  final String? fotoPath;

  /// Pan offset of the photo inside the slot.
  final Offset offset;

  /// Zoom scale of the photo inside the slot.
  final double scale;

  final SlotFitMode fitMode;

  bool get isEmpty => fotoPath == null || fotoPath!.isEmpty;

  SlotData copyWith({
    String? fotoPath,
    bool clearFoto = false,
    Offset? offset,
    double? scale,
    SlotFitMode? fitMode,
  }) =>
      SlotData(
        fotoPath: clearFoto ? null : (fotoPath ?? this.fotoPath),
        offset: offset ?? this.offset,
        scale: scale ?? this.scale,
        fitMode: fitMode ?? this.fitMode,
      );

  Map<String, dynamic> toJson() => {
        'fotoPath': fotoPath,
        'dx': offset.dx,
        'dy': offset.dy,
        'scale': scale,
        'fitMode': fitMode.name,
      };

  static SlotData fromJson(Map<String, dynamic> json) => SlotData(
        fotoPath: json['fotoPath'] as String?,
        offset: Offset(
          (json['dx'] as num?)?.toDouble() ?? 0,
          (json['dy'] as num?)?.toDouble() ?? 0,
        ),
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        fitMode:
            SlotFitMode.values.byName(json['fitMode'] as String? ??
                SlotFitMode.cover.name),
      );
}
