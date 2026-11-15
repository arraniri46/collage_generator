# 📱 Rencana Eksekusi — Collage Generator (Laporan Atensi)

> Aplikasi Flutter untuk membuat poster kolase foto (collage) bergaya poster resmi instansi
> dengan caption laporan terstruktur untuk di-share ke WhatsApp.
>
> Referensi: poster "LAPORAN ATENSI — Kantor Wilayah Sumatera Utara" (canvas 1:1, 8 foto,
> layout 2 kolom asimetris, header logo + judul + tanggal, footer badge URL).

---

## 🎯 Ringkasan Konsep

| Aspek | Keputusan |
|---|---|
| Output utama | Poster PNG 1080×1080 (opsi 4:5) |
| Jumlah foto | Dinamis (1–9+), template terfilter otomatis |
| Template | Data-driven, koordinat slot relatif (0–1) + zona header/photoGrid/footer |
| Branding | Profile Instansi (logo, nama, website, warna) tersimpan lokal, multi-profile |
| Caption | Teks laporan terstruktur (BAB I–V), header/footer auto dari Profile, body diisi user |
| Share | Share gambar via `share_plus` + caption auto-copy ke clipboard (paste manual di WA) |
| Penyimpanan | Lokal (Hive / SharedPreferences), 1 draft = `CollageReport` (poster + caption) |

---

## 🗺️ Fase Eksekusi

### Fase 1 — Scaffold & Model Data
- [ ] Inisialisasi project Flutter (`flutter create`), struktur folder:
  `models/`, `data/templates/`, `screens/`, `widgets/`, `providers/`, `utils/`
- [ ] Setup packages:
  `image_picker`, `screenshot`, `image_gallery_saver_plus`/`gal`, `share_plus`,
  `permission_handler`, `hive` (atau `shared_preferences`), `intl`
- [ ] Model data final:
  - `BrandProfile` — branding poster (logo, nama instansi/unit, website, warna brand)
    **+ config caption** (judul, kepada Yth, dari, tembusan[], pembuka, penutup BAB V,
    kota Ttd, jabatan Ttd, nama Ttd)
  - `CollageTemplate` — id, nama, slotCount, zona (header/photoGrid/footer),
    slot: `Rect` relatif 0–1 + orientasi preferensi
  - `ReportCaption` — bagian auto (dari profile) + input user:
    `kegiatan`, `peserta[]`, `waktu`, `tempat`, `uraianRaw`
  - `SlotData` — foto path + transform (offset, scale, fit mode)
  - `CollageReport` — tanggalLaporan (satu sumber data) + template + slots + caption + profile
- [ ] Setup state management (Provider/Riverpod) + navigasi (named routes / go_router)

### Fase 2 — Sistem Template & Renderer Poster
- [ ] Renderer poster: `Stack` + `Positioned` + `FractionallySizedBox` per slot (koordinat relatif)
- [ ] Widget: `PosterCanvas`, `HeaderView` (logo + judul + tanggal),
      `FooterBadge` (pill URL + warna brand), `SlotView`
- [ ] Daftar template awal (10–15 buah, koordinat relatif):
  - 1 foto: full area
  - 2 foto: split H, split V, besar-kecil
  - 3 foto: 1 besar + 2 bawah, 1 kiri + 2 kanan, 3 strip
  - 4 foto: grid 2×2, 1 besar + 3 kecil
  - 5–6 foto: grid seragam + variasi
  - **8 foto: 2 kolom asimetris (4|4) — persis template referensi** ⭐
- [ ] Halaman Pilih Template: grid wireframe preview 2 kolom, terfilter per jumlah foto
- [ ] Halaman Setup Laporan: pilih profile, judul, tanggal (date picker, auto hari:
  "Rabu, 11 November 2026" via `intl`), rasio (1:1 / 4:5), jumlah foto (chips)

### Fase 2b — Home & Bottom Navigation (2026-11-15)
- [x] `HomeShell` (Material 3 `NavigationBar`) dengan 3 tab: Beranda / Riwayat / Profile via `IndexedStack`
- [x] Beranda: hero header navy (logo + nama unit aktif), CTA "Buat Laporan Baru" → SetupScreen, kartu statistik, kartu tips
- [x] Riwayat: empty state placeholder (terisi di fase persistence)
- [x] Profile: daftar `ProfileProvider` (list-only; CRUD di fase berikutnya)
- [x] FAB "Lanjut Draft" muncul bila `report.templateId != null` → langsung ke PosterPreviewScreen
- [x] `main.dart`: home menjadi `HomeShell`; `flutter analyze` bersih, 10/10 test lulus

### Fase 3 — Editor Foto
- [x] Tap slot kosong → bottom sheet "Galeri / Kamera" (`image_picker`)
- [x] Foto terisi: pan & zoom per slot (`InteractiveViewer`, cover fit, `ClipRRect`)
- [x] Swap foto antar slot (mode tukar)
- [x] Toolbar editor: Ganti Template, Swap, Reset, Preview
- [ ] (Opsional) atur gap & outer margin

### Fase 4 — Profile Instansi & Penyimpanan
- [ ] Halaman Daftar Profile (card list, set default, hapus)
- [ ] Halaman Form Profile:
  - Section poster: logo (image picker, disimpan lokal), nama instansi/unit, website, warna brand
  - Section config caption: judul, kepada Yth, dari, **tembusan list dinamis**
    (add/remove/reorder), pembuka, penutup BAB V, kota, jabatan & nama Ttd
- [ ] Persistensi Hive/SharedPreferences: profile + draft laporan
- [ ] Halaman Home: "+ Buat Laporan", Riwayat Laporan (thumbnail draft), akses Profile
- [ ] Splash: cek profile ada → redirect Home / setup profile pertama

### Fase 5 — Export & Share
- [ ] Halaman Preview & Export: poster full-screen
- [ ] Render PNG via `screenshot` (1080px+, bisa 2160p)
- [ ] Simpan ke galeri (`image_gallery_saver_plus`/`gal`) + `permission_handler`
- [ ] Share Sheet (bottom sheet):
  - 📤 **Share Poster + Caption** → caption auto-copy ke clipboard + share gambar
    → snackbar "✓ Caption tersalin, paste di chat WA"
  - 📋 Salin Caption saja
  - 🖼️ Share Poster saja
- [ ] Renderer caption: compose string otomatis —
  penomoran romawi I–V, penomoran item, emoji 📌⏰📍, hari/tanggal auto dari `tanggalLaporan`

### Fase 6 — Editor Caption
- [ ] Halaman Editor Caption (form accordion):
  - 🔒 Header & Tembusan (auto dari profile, readonly)
  - I. Kegiatan → 1 text field
  - II. Peserta → list dinamis (add/remove/reorder)
  - III. Waktu & Tempat → 2 field pendek; hari/tanggal auto 🔒
  - IV. Uraian Kegiatan → **1 text area, paste sekali → auto-split per poin:
    buang penomoran lama (1. / 2) / - / •), gabung baris terwrap, re-number otomatis**
  - 🔒 V. Penutup & Ttd (auto dari profile)
- [ ] Live preview caption + tombol "Salin Caption Lengkap"
- [ ] Tombol "Duplikat dari Laporan Terakhir" (copy draft, ubah field dinamis saja)

### Fase 7 (Opsional / Lanjutan)
- [ ] Pengaturan: default rasio, kualitas export, hapus riwayat
- [ ] Onboarding 2–3 slide
- [ ] Preset caption per jenis laporan (Atensi / Kegiatan Harian / dll)
- [ ] Custom aspect ratio (slider), filter foto sederhana, rotate 90°, flip
- [ ] Mode "pecah list" opsional untuk BAB IV (textarea → list editable)

---

## 📄 Daftar Halaman (10 halaman inti)

| # | Halaman | Fase |
|---|---|---|
| 1 | Splash | 4 |
| 2 | Home (Buat Laporan + Riwayat) | 4 |
| 3 | Daftar Profile Instansi | 4 |
| 4 | Form Profile Instansi (+ config caption) | 4 |
| 5 | Setup Laporan (profile, judul, tanggal, rasio, jumlah foto) | 2 |
| 6 | Pilih Template (terfilter per jumlah foto) | 2 |
| 7 | Editor Foto | 3 |
| 8 | Preview & Export | 5 |
| 9 | Editor Caption | 6 |
| 10 | Share Sheet (bottom sheet) | 5 |

---

## 🧭 Peta Navigasi

```
Splash ──► Home ──┬──► Profile List ──► Profile Form
                  │
                  └──► Setup Laporan ──► Pilih Template ──► Editor ──► Preview/Export ──► Share Sheet
                                        ▲                                              │
                                        └─────── "Duplikat dari Riwayat" ──────────────┘
```

---

## ⚠️ Catatan Teknis & Risiko

1. **Share gambar + teks sekaligus tidak konsisten** di WA (Android/iOS sering mengabaikan
   `EXTRA_TEXT` saat ada attachment) → strategi: **caption ke clipboard + share gambar**,
   user paste manual. UX standar, 100% andal.
2. **Panjang caption** ~2.500 karakter << limit WA (~65k) → aman.
3. **Tanggal = satu sumber data** (`CollageReport.tanggalLaporan`) untuk header poster,
   BAB III caption, dan tanda tangan → tidak mungkin tidak sinkron.
4. **Koordinat slot relatif (0–1)** → template sama dipakai lintas rasio canvas tanpa duplikasi.
5. **Uraian (BAB IV) disimpan sebagai teks mentah** (`uraianRaw`), parsing on-the-fly →
   edit ulang draft tetap menampilkan teks asli yang di-paste.

---

## ✅ Definisi Selesai (MVP)

- User bisa membuat poster 8 foto persis seperti referensi (header branding, footer badge)
- Template dinamis 1–9 foto dengan picker terfilter
- Foto per slot: ambil dari galeri/kamera, pan & zoom, swap
- Profile instansi tersimpan & reusable (poster + config caption)
- Caption laporan I–V ter-compose otomatis, tinggal isi 5 field dinamis
- Export PNG 1080px ke galeri + share ke WA dengan strategi clipboard

