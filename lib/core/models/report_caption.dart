/// Caption of the report (the text shared alongside the poster to WhatsApp).
///
/// Header/footer sections are auto-composed from [BrandProfile]; the user
/// only fills the dynamic parts: kegiatan (I), peserta (II), waktu & tempat
/// (III), and uraian (IV, raw text that gets auto-split into numbered points).
final class ReportCaption {
  const ReportCaption({
    this.kegiatan = '',
    this.peserta = const [],
    this.waktu = '',
    this.tempat = '',
    this.uraianRaw = '',
  });

  /// Section I — short description of the activity.
  final String kegiatan;

  /// Section II — list of participants (dynamic list).
  final List<String> peserta;

  /// Section III — time, e.g. "Pukul 09.30 WIB s.d. selesai".
  final String waktu;

  /// Section III — place, e.g. "Ruang Kerja Kepala Kantor Wilayah".
  final String tempat;

  /// Section IV — raw multi-line text; parsed on the fly into numbered
  /// points (old numbering like "1." / "-" / "•" is stripped).
  final String uraianRaw;

  ReportCaption copyWith({
    String? kegiatan,
    List<String>? peserta,
    String? waktu,
    String? tempat,
    String? uraianRaw,
  }) =>
      ReportCaption(
        kegiatan: kegiatan ?? this.kegiatan,
        peserta: peserta ?? this.peserta,
        waktu: waktu ?? this.waktu,
        tempat: tempat ?? this.tempat,
        uraianRaw: uraianRaw ?? this.uraianRaw,
      );

  Map<String, dynamic> toJson() => {
        'kegiatan': kegiatan,
        'peserta': peserta,
        'waktu': waktu,
        'tempat': tempat,
        'uraianRaw': uraianRaw,
      };

  static ReportCaption fromJson(Map<String, dynamic> json) => ReportCaption(
        kegiatan: json['kegiatan'] as String? ?? '',
        peserta: (json['peserta'] as List?)?.cast<String>() ?? const [],
        waktu: json['waktu'] as String? ?? '',
        tempat: json['tempat'] as String? ?? '',
        uraianRaw: json['uraianRaw'] as String? ?? '',
      );
}
