import 'package:flutter/foundation.dart';

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
