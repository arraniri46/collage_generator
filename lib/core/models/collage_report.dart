import 'collage_template.dart';
import 'report_caption.dart';
import 'slot_data.dart';

/// Canvas aspect ratio options for the poster.
enum CanvasRatio {
  square(1, 1, '1:1'),
  portraitFourFive(4, 5, '4:5');

  const CanvasRatio(this.width, this.height, this.label);

  final int width;
  final int height;
  final String label;

  double get value => width / height;
}

/// One complete report draft = poster (template + slots) + caption + profile.
///
/// [tanggalLaporan] is the single source of truth for the date shown on the
/// poster header, caption section III, and the signature block.
final class CollageReport {
  const CollageReport({
    required this.id,
    required this.judul,
    required this.tanggalLaporan,
    this.canvasRatio = CanvasRatio.square,
    this.templateId,
    this.slots = const [],
    this.caption = const ReportCaption(),
    this.profileId,
    this.savedAt,
  });

  final String id;

  /// Poster title, e.g. "LAPORAN ATENSI".
  final String judul;

  final DateTime tanggalLaporan;
  final CanvasRatio canvasRatio;

  /// Selected [CollageTemplate.id], null until the user picks one.
  final String? templateId;

  /// Runtime slot data; length should match the template slotCount.
  final List<SlotData> slots;

  final ReportCaption caption;

  /// Reference to [BrandProfile.id].
  final String? profileId;

  /// When the report was saved to history; null while it's a draft.
  final DateTime? savedAt;

  CollageReport copyWith({
    String? id,
    String? judul,
    DateTime? tanggalLaporan,
    CanvasRatio? canvasRatio,
    String? templateId,
    List<SlotData>? slots,
    ReportCaption? caption,
    String? profileId,
    Object? savedAt = _unset,
  }) =>
      CollageReport(
        id: id ?? this.id,
        judul: judul ?? this.judul,
        tanggalLaporan: tanggalLaporan ?? this.tanggalLaporan,
        canvasRatio: canvasRatio ?? this.canvasRatio,
        templateId: templateId ?? this.templateId,
        slots: slots ?? this.slots,
        caption: caption ?? this.caption,
        profileId: profileId ?? this.profileId,
        savedAt: identical(savedAt, _unset) ? this.savedAt : savedAt as DateTime?,
      );

  static const _unset = Object();

  Map<String, dynamic> toJson() => {
        'id': id,
        'judul': judul,
        'tanggalLaporan': tanggalLaporan.toIso8601String(),
        'canvasRatio': canvasRatio.name,
        'templateId': templateId,
        'slots': slots.map((s) => s.toJson()).toList(),
        'caption': caption.toJson(),
        'profileId': profileId,
        'savedAt': savedAt?.toIso8601String(),
      };

  static CollageReport fromJson(Map<String, dynamic> json) => CollageReport(
        id: json['id'] as String,
        judul: json['judul'] as String? ?? 'LAPORAN ATENSI',
        tanggalLaporan: DateTime.parse(json['tanggalLaporan'] as String),
        canvasRatio: CanvasRatio.values.byName(
            json['canvasRatio'] as String? ?? CanvasRatio.square.name),
        templateId: json['templateId'] as String?,
        slots: (json['slots'] as List?)
                ?.map((s) => SlotData.fromJson(s as Map<String, dynamic>))
                .toList() ??
            const [],
        caption: json['caption'] != null
            ? ReportCaption.fromJson(json['caption'] as Map<String, dynamic>)
            : const ReportCaption(),
        profileId: json['profileId'] as String?,
        savedAt: json['savedAt'] != null
            ? DateTime.parse(json['savedAt'] as String)
            : null,
      );
}
