import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collage_generator/core/data/templates/template_registry.dart';
import 'package:collage_generator/core/models/collage_report.dart';
import 'package:collage_generator/core/models/brand_profile.dart';
import 'package:collage_generator/core/models/report_caption.dart';
import 'package:collage_generator/core/models/slot_data.dart';
import 'package:collage_generator/core/utils/date_formatter_id.dart';
import 'package:collage_generator/features/editor/widgets/poster_canvas.dart';
import 'package:collage_generator/main.dart';
import 'package:provider/provider.dart';
import 'package:collage_generator/providers/profile_provider.dart';
import 'package:collage_generator/providers/report_provider.dart';

void main() {
  group('TemplateRegistry', () {
    test('has templates for photo counts 1..9', () {
      for (var i = 1; i <= 9; i++) {
        expect(
          TemplateRegistry.bySlotCount(i),
          isNotEmpty,
          reason: 'No template for $i photos',
        );
      }
    });

    test('reference 8-photo template has 8 valid slots', () {
      final t = TemplateRegistry.byId('t8_reference');
      expect(t, isNotNull);
      expect(t!.slotCount, 8);
      expect(t.slots.length, 8);
      for (final slot in t.slots) {
        expect(slot.rect.left, greaterThanOrEqualTo(0));
        expect(slot.rect.top, greaterThanOrEqualTo(0));
        expect(slot.rect.right, lessThanOrEqualTo(1.0001));
        expect(slot.rect.bottom, lessThanOrEqualTo(1.0001));
        expect(slot.rect.width, greaterThan(0));
        expect(slot.rect.height, greaterThan(0));
      }
    });

    test('byId returns null for unknown id', () {
      expect(TemplateRegistry.byId('nope'), isNull);
      expect(TemplateRegistry.byId(null), isNull);
    });
  });

  group('Model serialization', () {
    test('BrandProfile json round-trip', () {
      const profile = BrandProfile(
        id: 'p1',
        namaInstansi: 'Instansi',
        namaUnit: 'Unit',
        websiteUrl: 'example.go.id',
        tembusan: ['A;', 'B;'],
      );
      final restored = BrandProfile.fromJson(profile.toJson());
      expect(restored.id, profile.id);
      expect(restored.tembusan, profile.tembusan);
      expect(restored.warnaBrand, profile.warnaBrand);
    });

    test('CollageReport json round-trip', () {
      final report = CollageReport(
        id: 'r1',
        judul: 'LAPORAN ATENSI',
        tanggalLaporan: DateTime(2026, 11, 11),
        templateId: 't8_reference',
        slots: List.generate(8, (_) => const SlotData()),
      );
      final restored = CollageReport.fromJson(report.toJson());
      expect(restored.id, report.id);
      expect(restored.templateId, report.templateId);
      expect(restored.slots.length, 8);
      expect(restored.tanggalLaporan, report.tanggalLaporan);
    });

    test('ReportCaption json round-trip', () {
      const caption = ReportCaption(
        kegiatan: 'Kegiatan X',
        peserta: ['Peserta 1'],
        waktu: 'Pukul 09.30 WIB s.d. selesai',
        tempat: 'Ruang Kerja',
        uraianRaw: '1. Poin pertama\n2. Poin kedua',
      );
      final restored = ReportCaption.fromJson(caption.toJson());
      expect(restored.uraianRaw, caption.uraianRaw);
      expect(restored.peserta, caption.peserta);
    });
  });

  group('DateFormatterId', () {
    test('formats full Indonesian date', () {
      final text = DateFormatterId.full(DateTime(2026, 11, 11));
      expect(text, contains('11 November 2026'));
      expect(text, startsWith('Rabu'));
    });
  });

  testWidgets('PosterCanvas renders header, slots and footer', (tester) async {
    final template = TemplateRegistry.byId('t8_reference')!;
    final report = CollageReport(
      id: 'r1',
      judul: 'LAPORAN ATENSI',
      tanggalLaporan: DateTime(2026, 11, 11),
      templateId: template.id,
      slots: List.generate(8, (_) => const SlotData()),
    );
    const profile = BrandProfile(
      id: 'p1',
      namaInstansi: 'Kementerian Hukum',
      namaUnit: 'Kantor Wilayah Sumatera Utara',
      websiteUrl: 'sumut.kemenkum.go.id',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: PosterCanvas(
                report: report,
                template: template,
                profile: profile,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Title and date render.
    expect(find.text('LAPORAN ATENSI'), findsOneWidget);
    expect(find.text('Rabu, 11 November 2026'), findsOneWidget);
    // Website badge renders.
    expect(find.text('sumut.kemenkum.go.id'), findsOneWidget);
    // 8 slot placeholders render.
    expect(
      find.byIcon(Icons.photo_camera_rounded),
      findsNWidgets(8),
    );
  });

  testWidgets('Full flow: setup -> template picker -> poster preview',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => ReportProvider()),
        ],
        child: const CollageGeneratorApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Pick 8 photos.
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();

    // Continue to template picker.
    await tester.tap(find.text('Lanjut Pilih Template'));
    await tester.pumpAndSettle();

    // Pick the reference template.
    await tester.tap(find.text('Laporan Atensi (Referensi)'));
    await tester.pumpAndSettle();

    // Poster preview shows with the title.
    expect(find.text('Preview Poster'), findsOneWidget);
    expect(find.text('LAPORAN ATENSI'), findsOneWidget);
  });

  testWidgets('App builds and shows setup screen', (tester) async {
    await tester.pumpWidget(const CollageGeneratorApp());
    await tester.pumpAndSettle();

    expect(find.text('Buat Laporan'), findsOneWidget);
  });
}
