import 'package:flutter/foundation.dart';
import 'dart:ui' show Offset;

import '../core/data/templates/template_registry.dart';
import '../core/models/collage_report.dart';
import '../core/models/collage_template.dart';
import '../core/models/report_caption.dart';
import '../core/models/slot_data.dart';

/// Global state of the report being composed (setup → template → editor).
class ReportProvider extends ChangeNotifier {
  CollageReport _report = CollageReport(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    judul: 'LAPORAN ATENSI',
    tanggalLaporan: DateTime.now(),
  );

  CollageReport get report => _report;

  /// Currently selected template (resolved from [CollageReport.templateId]).
  CollageTemplate? get template => TemplateRegistry.byId(_report.templateId);

  // --- Setup screen ---

  void setJudul(String judul) {
    _report = _report.copyWith(judul: judul);
    notifyListeners();
  }

  void setTanggal(DateTime date) {
    _report = _report.copyWith(tanggalLaporan: date);
    notifyListeners();
  }

  void setCanvasRatio(CanvasRatio ratio) {
    _report = _report.copyWith(canvasRatio: ratio);
    notifyListeners();
  }

  void setProfile(String? profileId) {
    _report = _report.copyWith(profileId: profileId);
    notifyListeners();
  }

  /// Sets the photo count: resets the template and reinitializes slots.
  void setSlotCount(int count) {
    _report = _report.copyWith(
      templateId: null,
      slots: List.generate(count, (_) => const SlotData()),
    );
    notifyListeners();
  }

  int get slotCount => _report.slots.length;

  // --- Template picking ---

  void selectTemplate(CollageTemplate template) {
    assert(template.slotCount == _report.slots.length);
    _report = _report.copyWith(templateId: template.id);
    notifyListeners();
  }

  // --- Caption ---

  void updateCaption(ReportCaption caption) {
    _report = _report.copyWith(caption: caption);
    notifyListeners();
  }

  // --- Photo editor ---

  /// Sets the photo of a slot (resetting its transform) from the picker.
  void setSlotPhoto(int index, String path) {
    final slots = [..._report.slots];
    if (index < 0 || index >= slots.length) return;
    slots[index] = slots[index].copyWith(
      fotoPath: path,
      offset: Offset.zero,
      scale: 1.0,
    );
    _report = _report.copyWith(slots: slots);
    notifyListeners();
  }

  /// Persists pan/zoom transform of a slot's photo.
  void updateSlotTransform(int index, Offset offset, double scale) {
    final slots = [..._report.slots];
    if (index < 0 || index >= slots.length) return;
    slots[index] = slots[index].copyWith(offset: offset, scale: scale);
    _report = _report.copyWith(slots: slots);
    notifyListeners();
  }

  /// Removes the photo of a slot (back to empty placeholder).
  void clearSlot(int index) {
    final slots = [..._report.slots];
    if (index < 0 || index >= slots.length) return;
    slots[index] = slots[index].copyWith(
      clearFoto: true,
      offset: Offset.zero,
      scale: 1.0,
    );
    _report = _report.copyWith(slots: slots);
    notifyListeners();
  }

  /// Exchanges the photos (including transforms) of two slots.
  void swapSlots(int a, int b) {
    final slots = [..._report.slots];
    if (a < 0 || b < 0 || a >= slots.length || b >= slots.length || a == b) {
      return;
    }
    final tmp = slots[a];
    slots[a] = slots[b];
    slots[b] = tmp;
    _report = _report.copyWith(slots: slots);
    notifyListeners();
  }

  /// Clears all slot photos (keeps template & caption).
  void resetSlots() {
    _report = _report.copyWith(
      slots: List.generate(_report.slots.length, (_) => const SlotData()),
    );
    notifyListeners();
  }

  /// Number of slots that already contain a photo.
  int get filledSlotCount =>
      _report.slots.where((s) => !s.isEmpty).length;

  /// Starts a fresh report; [base] can be a duplicated previous report.
  void startNewReport({CollageReport? base}) {
    _report = (base ?? CollageReport(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      judul: 'LAPORAN ATENSI',
      tanggalLaporan: DateTime.now(),
    ));
    notifyListeners();
  }
}
