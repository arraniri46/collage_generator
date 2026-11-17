import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collage_generator/core/models/brand_profile.dart';
import 'package:collage_generator/core/models/collage_report.dart';
import 'package:collage_generator/core/models/report_caption.dart';
import 'package:collage_generator/core/utils/caption_builder.dart';

void main() {
  final profile = BrandProfile(
    id: 'p1',
    namaInstansi: 'Kementerian Hukum',
    namaUnit: 'Kantor Wilayah Sumatera Utara',
    websiteUrl: 'sumut.kemenkum.go.id',
    judulCaption: 'LAPORAN ATENSI PIMPINAN',
    kepadaYth: 'Bapak Sekretaris Jenderal',
    dariLabel: 'Kepala Kantor Wilayah',
    tembusan: ['Inspektur Jenderal', 'Arsip'],
    pembuka: 'Dengan hormat.',
    penutup: 'Demikian laporan ini disampaikan.',
    kotaTtd: 'Medan',
    jabatanTtd: 'Kepala Kantor Wilayah',
    namaTtd: 'Rudy Hendra Pakpahan',
  );

  final report = CollageReport(
    id: 'r1',
    judul: 'LAPORAN ATENSI',
    tanggalLaporan: DateTime(2026, 11, 11),
    caption: const ReportCaption(
      kegiatan: 'Pemeriksaan berkala',
      peserta: ['Tim A', 'Tim B'],
      waktu: 'Pukul 09.30 WIB s.d. selesai',
      tempat: 'Ruang Kerja Kepala Kantor Wilayah',
      uraianRaw: '1. Poin pertama\n2. Poin kedua\nbaris lanjutan\n- Poin ketiga',
    ),
  );

  group('CaptionBuilder.uraianPoints', () {
    test('strips old numbering and re-numbers', () {
      final points = CaptionBuilder.uraianPoints(
        '1. Pertama\n2) Kedua\n- Ketiga\n• Keempat',
      );
      expect(points, [
        '1. Pertama',
        '2. Kedua',
        '3. Ketiga',
        '4. Keempat',
      ]);
    });

    test('merges wrapped lines into the previous point', () {
      final points = CaptionBuilder.uraianPoints(
        '1. Pertama\nlanjutan baris\n2. Kedua',
      );
      expect(points, ['1. Pertama lanjutan baris', '2. Kedua']);
    });

    test('drops empty lines', () {
      final points = CaptionBuilder.uraianPoints('1. Satu\n\n\n2. Dua');
      expect(points, ['1. Satu', '2. Dua']);
    });

    test('returns empty for empty input', () {
      expect(CaptionBuilder.uraianPoints(''), isEmpty);
    });
  });

  group('CaptionBuilder.build', () {
    test('composes header, sections I-V and signature', () {
      final text = CaptionBuilder.build(profile: profile, report: report);

      expect(text, contains('*LAPORAN ATENSI PIMPINAN*'));
      expect(text, contains('Kepada Yth:\nBapak Sekretaris Jenderal'));
      expect(text, contains('Dari:\nKepala Kantor Wilayah'));
      expect(text, contains('Tembusan:\n1. Inspektur Jenderal;\n2. Arsip;'));
      expect(text, contains('Dengan hormat.'));
      expect(text, contains('*I. KEGIATAN*'));
      expect(text, contains('Pemeriksaan berkala'));
      expect(text, contains('*II. PESERTA KEGIATAN*'));
      expect(text, contains('1. Tim A;\n2. Tim B;'));
      expect(text, contains('*III. WAKTU DAN TEMPAT*'));
      expect(text, contains('📌 Hari/Tanggal: Rabu, 11 November 2026'));
      expect(text, contains('⏰ Waktu: Pukul 09.30 WIB s.d. selesai'));
      expect(text, contains('📍 Tempat: Ruang Kerja Kepala Kantor Wilayah'));
      expect(text, contains('*IV. URAIAN KEGIATAN*'));
      expect(text, contains('1. Poin pertama'));
      expect(text, contains('3. Poin ketiga'));
      expect(text, contains('*V. PENUTUP*'));
      expect(text, contains('Demikian laporan ini disampaikan.'));
      expect(text, contains('Medan, 11 November 2026'));
      expect(text, contains('Kepala Kantor Wilayah'));
      expect(text, contains('Rudy Hendra Pakpahan'));
    });

    test('falls back to placeholders when profile is null', () {
      final text = CaptionBuilder.build(profile: null, report: report);
      expect(text, contains('*LAPORAN ATENSI PIMPINAN*'));
      expect(text, contains('Kepada Yth:'));
    });
  });

  test('report date formats in Indonesian', () {
    // Sanity check that DateFormatterId works inside tests.
    final text = CaptionBuilder.build(profile: profile, report: report);
    expect(text, contains('11 November 2026'));
  });

  test('Color import sanity (brand color parsing)', () {
    // Ensures flutter material binding is available for Color usage in
    // BrandProfile used above.
    expect(profile.warnaBrand, isA<Color>());
  });
}
