import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/brand_profile.dart';
import '../../core/models/collage_report.dart';

/// Local persistence backed by [SharedPreferences].
///
/// Stores: profile registry (list of [BrandProfile] JSON), the active
/// profile id, and the in-progress report draft.
final class LocalStorageService {
  static const _kProfiles = 'profiles';
  static const _kActiveProfileId = 'active_profile_id';
  static const _kDraftReport = 'draft_report';
  static const _kHistory = 'report_history';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  /// Loads profiles saved locally. Returns an empty list on a fresh install.
  List<BrandProfile> loadProfiles() {
    final raw = _prefs.getString(_kProfiles);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => BrandProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProfiles(List<BrandProfile> profiles) async {
    final json = profiles.map((p) => p.toJson()).toList();
    await _prefs.setString(_kProfiles, jsonEncode(json));
  }

  String? loadActiveProfileId() => _prefs.getString(_kActiveProfileId);

  Future<void> saveActiveProfileId(String? id) async {
    if (id == null) {
      await _prefs.remove(_kActiveProfileId);
    } else {
      await _prefs.setString(_kActiveProfileId, id);
    }
  }

  /// Loads the saved draft report, or null when there is none.
  CollageReport? loadDraftReport() {
    final raw = _prefs.getString(_kDraftReport);
    if (raw == null) return null;
    return CollageReport.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveDraftReport(CollageReport report) async {
    await _prefs.setString(_kDraftReport, jsonEncode(report.toJson()));
  }

  Future<void> clearDraftReport() async {
    await _prefs.remove(_kDraftReport);
  }

  /// Loads saved (finished) reports, newest insertion first.
  List<CollageReport> loadHistory() {
    final raw = _prefs.getString(_kHistory);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => CollageReport.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHistory(List<CollageReport> reports) async {
    final json = reports.map((r) => r.toJson()).toList();
    await _prefs.setString(_kHistory, jsonEncode(json));
  }
}
