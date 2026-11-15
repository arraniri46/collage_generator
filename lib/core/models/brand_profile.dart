import 'dart:ui';

/// Institutional profile: branding for the poster + caption configuration.
///
/// Everything that "almost never changes" per report lives here, so the
/// user only fills the dynamic parts (activity, participants, time, place,
/// description) when composing a new report.
final class BrandProfile {
  const BrandProfile({
    required this.id,
    required this.namaInstansi,
    required this.namaUnit,
    this.logoPath,
    this.websiteUrl = '',
    this.warnaBrand = const Color(0xFF1B3A6B),
    // Caption configuration (auto-filled sections of the report caption)
    this.judulCaption = 'LAPORAN ATENSI PIMPINAN',
    this.kepadaYth = '',
    this.dariLabel = '',
    this.tembusan = const [],
    this.pembuka =
        'Dengan hormat, bersama ini kami sampaikan laporan pelaksanaan '
        'kegiatan sebagai berikut:',
    this.penutup =
        'Demikian laporan atensi ini kami sampaikan untuk menjadi perhatian '
        'Pimpinan. Atas perkenan dan arahan Pimpinan, diucapkan terima kasih.',
    this.kotaTtd = 'Medan',
    this.jabatanTtd = '',
    this.namaTtd = '',
  });

  final String id;

  // --- Poster branding ---
  /// e.g. "Kementerian Hukum"
  final String namaInstansi;

  /// e.g. "Kantor Wilayah Sumatera Utara"
  final String namaUnit;

  /// Local file path of the institution logo (nullable until uploaded).
  final String? logoPath;

  /// Website shown in the footer badge, e.g. "sumut.kemenkum.go.id".
  final String websiteUrl;

  /// Brand color used for the footer badge and accents.
  final Color warnaBrand;

  // --- Caption configuration ---
  /// Caption document title, e.g. "LAPORAN ATENSI PIMPINAN".
  final String judulCaption;

  /// Recipient line, e.g. "Bapak Sekretaris Jenderal Kementerian Hukum RI".
  final String kepadaYth;

  /// Sender line, e.g. "Kepala Kantor Wilayah Kementerian Hukum Sumut".
  final String dariLabel;

  /// CC list (dynamic, editable per profile).
  final List<String> tembusan;

  /// Static opening paragraph before section I.
  final String pembuka;

  /// Static closing paragraph (section V).
  final String penutup;

  /// City used above the signature, e.g. "Medan".
  final String kotaTtd;

  /// Signer position, e.g. "Kepala Kantor Wilayah".
  final String jabatanTtd;

  /// Signer name, e.g. "Rudy Hendra Pakpahan".
  final String namaTtd;

  BrandProfile copyWith({
    String? id,
    String? namaInstansi,
    String? namaUnit,
    String? logoPath,
    bool clearLogo = false,
    String? websiteUrl,
    Color? warnaBrand,
    String? judulCaption,
    String? kepadaYth,
    String? dariLabel,
    List<String>? tembusan,
    String? pembuka,
    String? penutup,
    String? kotaTtd,
    String? jabatanTtd,
    String? namaTtd,
  }) =>
      BrandProfile(
        id: id ?? this.id,
        namaInstansi: namaInstansi ?? this.namaInstansi,
        namaUnit: namaUnit ?? this.namaUnit,
        logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
        websiteUrl: websiteUrl ?? this.websiteUrl,
        warnaBrand: warnaBrand ?? this.warnaBrand,
        judulCaption: judulCaption ?? this.judulCaption,
        kepadaYth: kepadaYth ?? this.kepadaYth,
        dariLabel: dariLabel ?? this.dariLabel,
        tembusan: tembusan ?? this.tembusan,
        pembuka: pembuka ?? this.pembuka,
        penutup: penutup ?? this.penutup,
        kotaTtd: kotaTtd ?? this.kotaTtd,
        jabatanTtd: jabatanTtd ?? this.jabatanTtd,
        namaTtd: namaTtd ?? this.namaTtd,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'namaInstansi': namaInstansi,
        'namaUnit': namaUnit,
        'logoPath': logoPath,
        'websiteUrl': websiteUrl,
        'warnaBrand': warnaBrand.toARGB32(),
        'judulCaption': judulCaption,
        'kepadaYth': kepadaYth,
        'dariLabel': dariLabel,
        'tembusan': tembusan,
        'pembuka': pembuka,
        'penutup': penutup,
        'kotaTtd': kotaTtd,
        'jabatanTtd': jabatanTtd,
        'namaTtd': namaTtd,
      };

  static BrandProfile fromJson(Map<String, dynamic> json) => BrandProfile(
        id: json['id'] as String,
        namaInstansi: json['namaInstansi'] as String,
        namaUnit: json['namaUnit'] as String,
        logoPath: json['logoPath'] as String?,
        websiteUrl: json['websiteUrl'] as String? ?? '',
        warnaBrand: Color(json['warnaBrand'] as int? ?? 0xFF1B3A6B),
        judulCaption:
            json['judulCaption'] as String? ?? 'LAPORAN ATENSI PIMPINAN',
        kepadaYth: json['kepadaYth'] as String? ?? '',
        dariLabel: json['dariLabel'] as String? ?? '',
        tembusan:
            (json['tembusan'] as List?)?.cast<String>() ?? const [],
        pembuka: json['pembuka'] as String? ?? '',
        penutup: json['penutup'] as String? ?? '',
        kotaTtd: json['kotaTtd'] as String? ?? 'Medan',
        jabatanTtd: json['jabatanTtd'] as String? ?? '',
        namaTtd: json['namaTtd'] as String? ?? '',
      );
}
