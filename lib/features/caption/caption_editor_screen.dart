import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/report_caption.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter_id.dart';
import '../../providers/profile_provider.dart';
import '../../providers/report_provider.dart';
import 'widgets/caption_editor_widgets.dart';

/// Form accordion for editing the report caption. Locked sections (header,
/// tembusan, penutup & Ttd) are auto-filled from the active profile; only
/// the dynamic parts are editable.
final class CaptionEditorScreen extends StatefulWidget {
  const CaptionEditorScreen({super.key});

  @override
  State<CaptionEditorScreen> createState() => _CaptionEditorScreenState();
}

class _CaptionEditorScreenState extends State<CaptionEditorScreen> {
  late final TextEditingController _kegiatan;
  late final TextEditingController _waktu;
  late final TextEditingController _tempat;
  late final TextEditingController _uraian;
  late List<String> _peserta;

  @override
  void initState() {
    super.initState();
    final caption = context.read<ReportProvider>().report.caption;
    _kegiatan = TextEditingController(text: caption.kegiatan);
    _waktu = TextEditingController(text: caption.waktu);
    _tempat = TextEditingController(text: caption.tempat);
    _uraian = TextEditingController(text: caption.uraianRaw);
    _peserta = [...caption.peserta];
  }

  @override
  void dispose() {
    _kegiatan.dispose();
    _waktu.dispose();
    _tempat.dispose();
    _uraian.dispose();
    super.dispose();
  }

  ReportCaption get _currentCaption => ReportCaption(
        kegiatan: _kegiatan.text,
        peserta: _peserta,
        waktu: _waktu.text,
        tempat: _tempat.text,
        uraianRaw: _uraian.text,
      );

  void _save() {
    context.read<ReportProvider>().updateCaption(_currentCaption);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ Caption tersimpan')),
    );
    Navigator.of(context).pop();
  }

  void _duplicateFromLast() {
    final provider = context.read<ReportProvider>();
    if (provider.history.isEmpty) return;
    provider.duplicateFromLastReport();
    final caption = provider.report.caption;
    setState(() {
      _kegiatan.text = caption.kegiatan;
      _peserta = [...caption.peserta];
      _waktu.text = caption.waktu;
      _tempat.text = caption.tempat;
      _uraian.text = caption.uraianRaw;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Field dinamis diduplikasi dari laporan terakhir'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>().report;
    // Defensive: fall back to the active profile if the stored profile id
    // no longer resolves, so locked caption sections are never blank.
    final profileProvider = context.watch<ProfileProvider>();
    final profile =
        profileProvider.byId(report.profileId) ?? profileProvider.activeProfile;
    final dateText = DateFormatterId.full(report.tanggalLaporan);

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(title: const Text('Editor Caption')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            LockedSection(
              title: 'Header & Tembusan (otomatis dari profile)',
              children: [
                LockedLine(
                  label: 'Judul',
                  value: profile?.judulCaption ?? 'LAPORAN ATENSI PIMPINAN',
                ),
                LockedLine(label: 'Kepada Yth:', value: profile?.kepadaYth ?? '-'),
                LockedLine(label: 'Dari:', value: profile?.dariLabel ?? '-'),
                for (final t in profile?.tembusan ?? const <String>[])
                  LockedLine(label: 'Tembusan', value: t),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AccordionSection(
              title: 'I. Kegiatan',
              initiallyExpanded: true,
              children: [
                TextField(
                  controller: _kegiatan,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi kegiatan',
                    hintText: 'Contoh: Pemeriksaan berkala gudang bukti',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSectionTwo(),
            const SizedBox(height: AppSpacing.md),
            _buildSectionThree(dateText),
            const SizedBox(height: AppSpacing.md),
            _buildSectionFour(),
            const SizedBox(height: AppSpacing.md),
            LockedSection(
              title: 'V. Penutup & Ttd (otomatis dari profile)',
              children: [
                LockedLine(label: 'Penutup', value: profile?.penutup ?? '-'),
                LockedLine(
                  label: 'Ttd',
                  value:
                      '${profile?.kotaTtd ?? ''}, '
                      '${DateFormatterId.short(report.tanggalLaporan)}\n'
                      '${profile?.jabatanTtd ?? ''}\n\n'
                      '${profile?.namaTtd ?? ''}',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            CaptionPreviewCard(caption: _currentCaption),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed:
                  context.watch<ReportProvider>().history.isEmpty
                      ? null
                      : _duplicateFromLast,
              icon: const Icon(Icons.copy_all_rounded),
              label: const Text('Duplikat dari Laporan Terakhir'),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Simpan Caption'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTwo() {
    return AccordionSection(
      title: 'II. Peserta',
      initiallyExpanded: true,
      children: [
        for (var i = 0; i < _peserta.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _peserta[i],
                    decoration: InputDecoration(labelText: 'Peserta ${i + 1}'),
                    onChanged: (v) => _peserta[i] = v,
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus',
                  icon: const Icon(
                    Icons.remove_circle_outline_rounded,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _peserta.removeAt(i)),
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _peserta.add('')),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Tambah Peserta'),
        ),
      ],
    );
  }

  Widget _buildSectionThree(String dateText) {
    return AccordionSection(
      title: 'III. Waktu & Tempat',
      initiallyExpanded: true,
      children: [
        LockedLine(label: 'Hari/Tanggal (otomatis)', value: dateText),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _waktu,
          decoration: const InputDecoration(
            labelText: 'Waktu',
            hintText: 'Contoh: Pukul 09.30 WIB s.d. selesai',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _tempat,
          decoration: const InputDecoration(
            labelText: 'Tempat',
            hintText: 'Contoh: Ruang Kerja Kepala Kantor Wilayah',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionFour() {
    return AccordionSection(
      title: 'IV. Uraian Kegiatan',
      initiallyExpanded: true,
      children: [
        TextField(
          controller: _uraian,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Tempel uraian (satu poin per baris)',
            hintText:
                'Boleh tempel dari dokumen lama — penomoran 1. / 2) / - / • '
                'dibuang dan penomoran baru dibuat otomatis',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        UraianPreview(uraianRaw: _uraian.text),
      ],
    );
  }
}
