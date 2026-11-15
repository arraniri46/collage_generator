import 'package:flutter/foundation.dart';

import '../core/models/brand_profile.dart';

/// Global registry of institution profiles.
///
/// Phase 1: in-memory with a seeded sample profile so UI development can
/// proceed immediately. Persistence arrives in phase 4.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider() {
    _profiles
      ..add(_sampleProfileKemenkum())
      ..add(_sampleProfileDinas());
  }

  final List<BrandProfile> _profiles = [];
  String? _activeProfileId;

  List<BrandProfile> get profiles => List.unmodifiable(_profiles);

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

  void setActive(String id) {
    _activeProfileId = id;
    notifyListeners();
  }

  void upsert(BrandProfile profile) {
    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) {
      _profiles[index] = profile;
    } else {
      _profiles.add(profile);
    }
    notifyListeners();
  }

  void remove(String id) {
    _profiles.removeWhere((p) => p.id == id);
    if (_activeProfileId == id) {
      _activeProfileId = _profiles.isEmpty ? null : _profiles.first.id;
    }
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
