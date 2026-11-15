import 'package:flutter/foundation.dart';

import '../core/models/brand_profile.dart';
import '../core/services/local_storage_service.dart';

/// Global registry of institution profiles, persisted locally.
///
/// On first launch (empty storage) it seeds two sample profiles so the UI
/// has sensible content; afterwards everything is loaded from storage.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._storage);

  final LocalStorageService _storage;

  final List<BrandProfile> _profiles = [];
  String? _activeProfileId;
  bool _loaded = false;

  List<BrandProfile> get profiles => List.unmodifiable(_profiles);

  bool get isLoaded => _loaded;

  BrandProfile? get activeProfile {
    for (final p in _profiles) {
      if (p.id == _activeProfileId) return p;
    }
    return _profiles.isEmpty ? null : _profiles.first;
  }

  BrandProfile? byId(String? id) {
    if (id == null) return null;
    for (final p in _profiles) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Loads profiles from storage; seeds samples on first launch.
  Future<void> load() async {
    final stored = _storage.loadProfiles();
    if (stored.isEmpty) {
      _profiles
        ..clear()
        ..add(_sampleProfileKemenkum())
        ..add(_sampleProfileDinas());
      await _storage.saveProfiles(_profiles);
    } else {
      _profiles
        ..clear()
        ..addAll(stored);
    }
    _activeProfileId = _storage.loadActiveProfileId();
    _loaded = true;
    notifyListeners();
  }

  void setActive(String id) {
    _activeProfileId = id;
    _storage.saveActiveProfileId(id);
    notifyListeners();
  }

  void upsert(BrandProfile profile) {
    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) {
      _profiles[index] = profile;
    } else {
      _profiles.add(profile);
    }
    _storage.saveProfiles(_profiles);
    notifyListeners();
  }

  void remove(String id) {
    _profiles.removeWhere((p) => p.id == id);
    if (_activeProfileId == id) {
      _activeProfileId = _profiles.isEmpty ? null : _profiles.first.id;
      _storage.saveActiveProfileId(_activeProfileId);
    }
    _storage.saveProfiles(_profiles);
    notifyListeners();
  }

  static BrandProfile _sampleProfileKemenkum() => const BrandProfile(
        id: 'sample-kemenkum',
        namaInstansi: 'Kementerian Hukum',
        namaUnit: 'Kantor Wilayah Sumatera Utara',
        websiteUrl: 'sumut.kemenkum.go.id',
        kepadaYth:
            'Bapak Sekretaris Jenderal Kementerian Hukum Republik Indonesia',
        dariLabel:
            'Kepala Kantor Wilayah Kementerian Hukum Sumatera Utara',
        tembusan: [
          'Menteri Hukum RI;',
          'Wakil Menteri Hukum RI;',
          'Bapak Inspektur Jenderal Kementerian Hukum Republik Indonesia;',
          'Bapak/Ibu Pimti Madya Kementerian Hukum RI.',
        ],
        jabatanTtd: 'Kepala Kantor Wilayah',
        namaTtd: 'Rudy Hendra Pakpahan',
      );

  static BrandProfile _sampleProfileDinas() => const BrandProfile(
        id: 'sample-dinas',
        namaInstansi: 'Pemerintah Provinsi Sumatera Utara',
        namaUnit: 'Dinas Komunikasi dan Informatika',
        websiteUrl: 'kominfo.sumutprov.go.id',
        jabatanTtd: 'Kepala Dinas',
        namaTtd: 'Contoh Nama Penandatangan',
      );
}

