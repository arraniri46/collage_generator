import '../../core/models/brand_profile.dart';
import '../../core/models/collage_report.dart';
import '../../core/utils/date_formatter_id.dart';

/// Composes the full shareable caption text from [BrandProfile] (static
/// header/footer) and [CollageReport] (dynamic parts + poster date).
final class CaptionBuilder {
  CaptionBuilder._();

  /// Strips old numbering ("1.", "2)", "-", "•") from a raw line and
  /// collapses whitespace.
  static String _cleanLine(String line) =>
      line.replaceFirst(RegExp(r'^\s*(\d+[.)]\s*|[-•*]\s+)'), '').trim();

  /// Parses [ReportCaption.uraianRaw] into cleaned numbered points
  /// ("1. …", "2. …"). Empty lines and bullet artifacts are dropped;
  /// wrapped lines (no old numbering) are merged into the previous point.
  static List<String> uraianPoints(String uraianRaw) {
    final points = <String>[];
    for (final raw in uraianRaw.split('\n')) {
      final hadNumbering = RegExp(r'^\s*(\d+[.)]\s*|[-•*]\s+)').hasMatch(raw);
      final cleaned = _cleanLine(raw);
      if (cleaned.isEmpty) continue;
      if (hadNumbering || points.isEmpty) {
        points.add(cleaned);
      } else {
        points[points.length - 1] = '${points.last} $cleaned';
      }
    }
    return points
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .toList();
  }

  /// Builds the complete caption ready to share/copy.
  static String build({
    required BrandProfile? profile,
    required CollageReport report,
  }) {
    final p = profile;
    final buffer = StringBuffer();

    // --- Header ---
    buffer.writeln(p?.judulCaption ?? 'LAPORAN ATENSI PIMPINAN');
    if (p != null && p.tembusan.isNotEmpty) {
      for (final t in p.tembusan) {
        buffer.writeln('Tembusan:\n- $t');
      }
    }
    buffer
      ..writeln()
      ..writeln('Kepada Yth. ${p?.kepadaYth ?? ''}')
      ..writeln('Dari: ${p?.dariLabel ?? ''}');

    final dateText = DateFormatterId.full(report.tanggalLaporan);

    // --- Section I ---
    buffer
      ..writeln()
      ..writeln('I. KEGIATAN');
    if (report.caption.kegiatan.isNotEmpty) {
      buffer.writeln(report.caption.kegiatan);
    }

    // --- Section II ---
    buffer
      ..writeln()
      ..writeln('II. PESERTA');
    if (report.caption.peserta.isNotEmpty) {
      for (final member in report.caption.peserta) {
        buffer.writeln('- $member');
    }
    }
    else {
      buffer.writeln('-');
    }

    // --- Section III ---
    buffer
      ..writeln()
      ..writeln('III. WAKTU & TEMPAT');
    buffer.writeln('Hari/Tanggal: $dateText');
    if (report.caption.waktu.isNotEmpty) {
      buffer.writeln('Waktu: ${report.caption.waktu}');
    }
    if (report.caption.tempat.isNotEmpty) {
      buffer.writeln('Tempat: ${report.caption.tempat}');
    }

    // --- Section IV ---
    buffer
      ..writeln()
      ..writeln('IV. URAIAN KEGIATAN');
    final points = uraianPoints(report.caption.uraianRaw);
    if (points.isEmpty) {
      buffer.writeln('-');
    } else {
      for (final point in points) {
        buffer.writeln(point);
      }
    }

    // --- Section V + signature ---
    buffer
      ..writeln()
      ..writeln('V. PENUTUP');
    buffer.writeln(p?.penutup ?? '');
    buffer
      ..writeln()
      ..writeln('${p?.kotaTtd ?? ''}, ${DateFormatterId.short(report.tanggalLaporan)}')
      ..writeln(p?.jabatanTtd ?? '')
      ..writeln()
      ..writeln()
      ..writeln()
      ..writeln(p?.namaTtd ?? '');

    return buffer.toString().trimRight();
  }
}
