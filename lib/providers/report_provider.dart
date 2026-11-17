import 'dart:io';

import 'package:flutter/foundation.dart';
import 'dart:ui' show Offset;

import '../core/data/templates/template_registry.dart';
import '../core/models/collage_report.dart';
import '../core/models/collage_template.dart';
import '../core/models/report_caption.dart';
import '../core/models/slot_data.dart';
import '../core/services/local_storage_service.dart';

/// Global state of the report being composed (setup → template → editor),
/// with the in-progress draft persisted locally.
class ReportProvider extends ChangeNotifier {
  ReportProvider(this._storage);

  final LocalStorageService _storage;

  CollageReport _report = _freshReport();

  /// Reports saved to history (JSON list in local storage).
  final List<CollageReport> _history = [];

  CollageReport get report => _report;

  List<CollageReport> get history => List.unmodifiable(_history);

  /// Currently selected template (resolved from [CollageReport.templateId]).
  CollageTemplate? get template => TemplateRegistry.byId(_report.templateId);

  static CollageReport _freshReport() => CollageReport(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        judul: 'LAPORAN ATENSI',
        tanggalLaporan: DateTime.now(),
      );

  /// Restores the persisted draft and history (if any); called once at app
  /// startup. Slots whose photo file no longer exists on disk (e.g. cleared
  /// cache) are reset to empty so the editor doesn't show ghost photos.
  Future<void> load() async {
    final draft = _storage.loadDraftReport();
    if (draft != null) {
      _report = _validateSlots(draft);
    }
    _history
      ..clear()
      ..addAll(
        _storage.loadHistory().map(_validateSlots),
      );
    notifyListeners();
  }

  /// Drops slot photos whose file is missing from disk.
  CollageReport _validateSlots(CollageReport report) {
    var changed = false;
    final slots = report.slots.map((s) {
      final path = s.fotoPath;
      if (path != null && !File(path).existsSync()) {
        changed = true;
        return s.copyWith(clearFoto: true, offset: Offset.zero, scale: 1.0);
      }
      return s;
    }).toList();
    return changed ? report.copyWith(slots: slots) : report;
  }

  /// Moves the current draft into history (saved list) and starts fresh.
  void saveToHistory() {
    final saved = _report.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      savedAt: DateTime.now(),
    );
    _history.insert(0, saved);
    _storage.saveHistory(_history);
    _report = _freshReport();
    _storage.clearDraftReport();
    notifyListeners();
  }

  /// Removes a saved report from history.
  void removeFromHistory(String id) {
    _history.removeWhere((r) => r.id == id);
    _storage.saveHistory(_history);
    notifyListeners();
  }

  /// Loads a saved report as the working draft (continue editing).
  void continueReport(CollageReport saved) {
    _report = saved.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      savedAt: null,
    );
    _storage.clearDraftReport();
    notifyListeners();
  }

  void _persist() {
    _storage.saveDraftReport(_report);
  }

  /// Drops the persisted draft and starts a fresh report.
  /// [base] can be a duplicated previous report.
  void startNewReport({CollageReport? base}) {
    _report = base ?? _freshReport();
    _storage.clearDraftReport();
    notifyListeners();
  }

  // --- Setup screen ---

  void setJudul(String judul) {
    _report = _report.copyWith(judul: judul);
    _persist();
    notifyListeners();
  }

  void setTanggal(DateTime date) {
    _report = _report.copyWith(tanggalLaporan: date);
    _persist();
    notifyListeners();
  }

  void setCanvasRatio(CanvasRatio ratio) {
    _report = _report.copyWith(canvasRatio: ratio);
    _persist();
    notifyListeners();
  }

  void setProfile(String? profileId) {
    _report = _report.copyWith(profileId: profileId);
    _persist();
    notifyListeners();
  }

  /// Sets the photo count: resets the template and resizes slots, keeping
  /// already-picked photos where possible.
  ///
  /// - Same count → no-op (tapping the current chip must not wipe photos).
  /// - Shrink → keeps the first [count] slots (with their photos).
  /// - Grow → keeps existing slots, appends empty ones.
  void setSlotCount(int count) {
    if (count == _report.slots.length) return;
    final oldSlots = _report.slots;
    final kept = oldSlots.length > count
        ? oldSlots.sublist(0, count)
        : [
            ...oldSlots,
            ...List.generate(
              count - oldSlots.length,
              (_) => const SlotData(),
            ),
          ];
    _report = _report.copyWith(templateId: null, slots: kept);
    _persist();
    notifyListeners();
  }

  int get slotCount => _report.slots.length;

  // --- Template picking ---

  void selectTemplate(CollageTemplate template) {
    assert(template.slotCount == _report.slots.length);
    _report = _report.copyWith(templateId: template.id);
    _persist();
    notifyListeners();
  }

  // --- Caption ---

  void updateCaption(ReportCaption caption) {
    _report = _report.copyWith(caption: caption);
    _persist();
    notifyListeners();
  }

  /// Copies the dynamic caption fields (kegiatan, peserta, waktu, tempat,
  /// uraian) from the most recent history entry into the current draft.
  /// Static parts (header/footer) stay driven by the active profile.
  void duplicateFromLastReport() {
    if (_history.isEmpty) return;
    _report = _report.copyWith(
      caption: _history.first.caption,
    );
    _persist();
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
    _persist();
    notifyListeners();
  }

  /// Persists pan/zoom transform of a slot's photo.
  void updateSlotTransform(int index, Offset offset, double scale) {
    final slots = [..._report.slots];
    if (index < 0 || index >= slots.length) return;
    slots[index] = slots[index].copyWith(offset: offset, scale: scale);
    _report = _report.copyWith(slots: slots);
    _persist();
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
    _persist();
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
    _persist();
    notifyListeners();
  }

  /// Clears all slot photos (keeps template & caption).
  void resetSlots() {
    _report = _report.copyWith(
      slots: List.generate(_report.slots.length, (_) => const SlotData()),
    );
    _persist();
    notifyListeners();
  }

  /// Number of slots that already contain a photo.
  int get filledSlotCount =>
      _report.slots.where((s) => !s.isEmpty).length;
}
