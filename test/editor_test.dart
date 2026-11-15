import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collage_generator/core/models/collage_report.dart';
import 'package:collage_generator/core/models/slot_data.dart';
import 'package:collage_generator/features/editor/editor_screen.dart';
import 'package:collage_generator/features/editor/photo_picker_service.dart';
import 'package:collage_generator/providers/report_provider.dart';
import 'package:provider/provider.dart';

/// Fake picker returning a fixed path without touching platform channels.
final class _FakePickerService implements PhotoPickerService {
  @override
  Future<String?> pickFromGallery({int? imageQuality}) async =>
      '/tmp/fake-photo.jpg';

  @override
  Future<String?> takeWithCamera({int? imageQuality}) async =>
      '/tmp/fake-photo.jpg';
}


CollageReport _reportWith8Slots() => CollageReport(
      id: 'r-test',
      judul: 'LAPORAN ATENSI',
      tanggalLaporan: DateTime(2026, 11, 15),
      templateId: 't8_reference',
      slots: List.generate(8, (_) => const SlotData()),
    );

void main() {
  group('ReportProvider photo editor', () {
    test('setSlotPhoto fills the slot and resets transform', () {
      final provider = ReportProvider()..startNewReport(base: _reportWith8Slots());
      provider.setSlotPhoto(2, '/tmp/photo.jpg');

      final slot = provider.report.slots[2];
      expect(slot.fotoPath, '/tmp/photo.jpg');
      expect(slot.isEmpty, isFalse);
      expect(slot.offset, Offset.zero);
      expect(slot.scale, 1.0);
      expect(provider.filledSlotCount, 1);
    });

    test('updateSlotTransform persists pan and zoom', () {
      final provider = ReportProvider()..startNewReport(base: _reportWith8Slots());
      provider.setSlotPhoto(0, '/tmp/a.jpg');
      provider.updateSlotTransform(0, const Offset(12, -4), 1.8);

      final slot = provider.report.slots[0];
      expect(slot.offset, const Offset(12, -4));
      expect(slot.scale, 1.8);
    });

    test('swapSlots exchanges photos between slots', () {
      final provider = ReportProvider()..startNewReport(base: _reportWith8Slots());
      provider.setSlotPhoto(0, '/tmp/a.jpg');
      provider.setSlotPhoto(3, '/tmp/b.jpg');
      provider.updateSlotTransform(3, const Offset(5, 5), 2.0);

      provider.swapSlots(0, 3);

      expect(provider.report.slots[0].fotoPath, '/tmp/b.jpg');
      expect(provider.report.slots[0].scale, 2.0);
      expect(provider.report.slots[3].fotoPath, '/tmp/a.jpg');
    });

    test('swapSlots ignores invalid indices', () {
      final provider = ReportProvider()..startNewReport(base: _reportWith8Slots());
      provider.setSlotPhoto(0, '/tmp/a.jpg');
      provider.swapSlots(0, 99);
      expect(provider.report.slots[0].fotoPath, '/tmp/a.jpg');
    });

    test('clearSlot empties a single slot', () {
      final provider = ReportProvider()..startNewReport(base: _reportWith8Slots());
      provider.setSlotPhoto(1, '/tmp/a.jpg');
      provider.clearSlot(1);

      expect(provider.report.slots[1].isEmpty, isTrue);
      expect(provider.filledSlotCount, 0);
    });

    test('resetSlots clears all slots but keeps the template', () {
      final provider = ReportProvider()..startNewReport(base: _reportWith8Slots());
      provider.setSlotPhoto(0, '/tmp/a.jpg');
      provider.setSlotPhoto(7, '/tmp/b.jpg');
      provider.resetSlots();

      expect(provider.filledSlotCount, 0);
      expect(provider.report.slots.length, 8);
      expect(provider.report.templateId, 't8_reference');
    });
  });

  group('EditorScreen', () {
    Future<void> pumpEditor(WidgetTester tester) async {
      final provider = ReportProvider()
        ..startNewReport(base: _reportWith8Slots());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ReportProvider>.value(value: provider),
          ],
          child: MaterialApp(home: EditorScreen(pickerService: _FakePickerService())),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders all slots with empty placeholders', (tester) async {
      await pumpEditor(tester);

      expect(find.text('Isi Foto (0/8)'), findsOneWidget);
      expect(find.byIcon(Icons.photo_camera_rounded), findsNWidgets(8));
    });

    testWidgets('tapping an empty slot opens the source bottom sheet',
        (tester) async {
      await pumpEditor(tester);

      await tester.tap(find.byKey(const ValueKey('editor-slot-0')));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Sumber Foto'), findsOneWidget);
      expect(find.text('Galeri'), findsOneWidget);
      expect(find.text('Kamera'), findsOneWidget);
    });

    testWidgets('picking from gallery fills the slot', (tester) async {
      await pumpEditor(tester);

      await tester.tap(find.byKey(const ValueKey('editor-slot-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Galeri'));
      await tester.pumpAndSettle();

      // Slot counter updates and the interactive viewer appears.
      expect(find.text('Isi Foto (1/8)'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('tapping a filled slot shows photo options', (tester) async {
      final provider = ReportProvider()
        ..startNewReport(base: _reportWith8Slots())
        ..setSlotPhoto(0, '/tmp/fake-photo.jpg');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ReportProvider>.value(value: provider),
          ],
          child: MaterialApp(home: EditorScreen(pickerService: _FakePickerService())),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('editor-slot-0')));
      await tester.pumpAndSettle();

      expect(find.text('Foto Slot 1'), findsOneWidget);
      expect(find.text('Tukar Posisi (Mode Tukar)'), findsOneWidget);
      expect(find.text('Ganti Foto'), findsOneWidget);
      expect(find.text('Hapus Foto'), findsOneWidget);
    });
  });
}
