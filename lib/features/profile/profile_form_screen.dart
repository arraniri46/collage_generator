import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/brand_profile.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/profile_provider.dart';

/// Create / edit an institution profile: poster branding + caption config.
final class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key, this.existing});

  /// Null = create a new profile.
  final BrandProfile? existing;

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  late final TextEditingController _instansi =
      TextEditingController(text: widget.existing?.namaInstansi ?? '');
  late final TextEditingController _unit =
      TextEditingController(text: widget.existing?.namaUnit ?? '');
  late final TextEditingController _website =
      TextEditingController(text: widget.existing?.websiteUrl ?? '');
  late final TextEditingController _judulCaption = TextEditingController(
    text: widget.existing?.judulCaption ?? 'LAPORAN ATENSI PIMPINAN',
  );
  late final TextEditingController _kepada =
      TextEditingController(text: widget.existing?.kepadaYth ?? '');
  late final TextEditingController _dari =
      TextEditingController(text: widget.existing?.dariLabel ?? '');
  late final TextEditingController _pembuka =
      TextEditingController(text: widget.existing?.pembuka ?? '');
  late final TextEditingController _penutup =
      TextEditingController(text: widget.existing?.penutup ?? '');
  late final TextEditingController _kota =
      TextEditingController(text: widget.existing?.kotaTtd ?? 'Medan');
  late final TextEditingController _jabatan =
      TextEditingController(text: widget.existing?.jabatanTtd ?? '');
  late final TextEditingController _namaTtd =
      TextEditingController(text: widget.existing?.namaTtd ?? '');

  late Color _warnaBrand = widget.existing?.warnaBrand ?? AppColors.primary;
  late final List<TextEditingController> _tembusanControllers = [
    for (final line in (widget.existing?.tembusan ?? const <String>[]))
      TextEditingController(text: line),
  ];

  final _formKey = GlobalKey<FormState>();
  bool _showAllSections = false;

  @override
  void dispose() {
    for (final c in [
      _instansi,
      _unit,
      _website,
      _judulCaption,
      _kepada,
      _dari,
      _pembuka,
      _penutup,
      _kota,
      _jabatan,
      _namaTtd,
    ]) {
      c.dispose();
    }
    for (final c in _tembusanControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addTembusan() {
    setState(() {
      _tembusanControllers.add(TextEditingController());
    });
  }

  void _removeTembusan(int index) {
    setState(() {
      _tembusanControllers.removeAt(index).dispose();
    });
  }

  Future<void> _pickColor() async {
    final colors = <String, Color>{
      'Navy (Pengayoman)': const Color(0xFF1B2C5D),
      'Emas': const Color(0xFFC99B00),
      'Merah': const Color(0xFFB3261E),
      'Hijau': const Color(0xFF1E8E3E),
      'Teal': const Color(0xFF00796B),
      'Ungu': const Color(0xFF6750A4),
    };
    final selected = await showDialog<Color>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Pilih Warna Brand'),
        children: [
          for (final entry in colors.entries)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(entry.value),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(entry.key),
                ],
              ),
            ),
        ],
      ),
    );
    if (selected != null) setState(() => _warnaBrand = selected);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final now = DateTime.now().microsecondsSinceEpoch.toString();
    final profile = BrandProfile(
      id: widget.existing?.id ?? 'p-$now',
      namaInstansi: _instansi.text.trim(),
      namaUnit: _unit.text.trim(),
      websiteUrl: _website.text.trim(),
      warnaBrand: _warnaBrand,
      judulCaption: _judulCaption.text.trim(),
      kepadaYth: _kepada.text.trim(),
      dariLabel: _dari.text.trim(),
      tembusan: _tembusanControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      pembuka: _pembuka.text.trim(),
      penutup: _penutup.text.trim(),
      kotaTtd: _kota.text.trim(),
      jabatanTtd: _jabatan.text.trim(),
      namaTtd: _namaTtd.text.trim(),
    );

    context.read<ProfileProvider>().upsert(profile);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Profile' : 'Profile Baru')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            const SectionHeader('Identitas Poster'),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _instansi,
              decoration: const InputDecoration(
                labelText: 'Nama Instansi *',
                hintText: 'Kementerian Hukum',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _unit,
              decoration: const InputDecoration(
                labelText: 'Nama Unit *',
                hintText: 'Kantor Wilayah Sumatera Utara',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _website,
              decoration: const InputDecoration(
                labelText: 'Website (footer poster)',
                hintText: 'sumut.kemenkum.go.id',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _pickColor,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Warna Brand'),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _warnaBrand,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Text('Tap untuk memilih'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader('Konfigurasi Caption'),
            const SizedBox(height: AppSpacing.md),
            _buildCaptionFields(context),
            const SizedBox(height: AppSpacing.lg),
            _buildTembusanSection(context),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader('Penandatangan'),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _kota,
              decoration: const InputDecoration(labelText: 'Kota'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _jabatan,
              decoration: const InputDecoration(
                labelText: 'Jabatan',
                hintText: 'Kepala Kantor Wilayah',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _namaTtd,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: AppSpacing.xl),
            ..._buildOptionalParagraphs(context),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Simpan Profile'),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptionFields(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _judulCaption,
          decoration: const InputDecoration(labelText: 'Judul Caption'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _kepada,
          decoration: const InputDecoration(
            labelText: 'Kepada (Yth.)',
            hintText: 'Bapak Sekretaris Jenderal Kementerian Hukum RI',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _dari,
          decoration: const InputDecoration(
            labelText: 'Dari',
            hintText: 'Kepala Kantor Wilayah Kementerian Hukum Sumut',
          ),
        ),
      ],
    );
  }

  Widget _buildTembusanSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tembusan', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < _tembusanControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: TextFormField(
              controller: _tembusanControllers[i],
              decoration: InputDecoration(
                hintText: 'Tembusan ${i + 1}',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => _removeTembusan(i),
                ),
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: _addTembusan,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Tambah Tembusan'),
        ),
      ],
    );
  }

  List<Widget> _buildOptionalParagraphs(BuildContext context) {
    return [
      TextButton(
        onPressed: () =>
            setState(() => _showAllSections = !_showAllSections),
        child: Text(
          _showAllSections
              ? 'Sembunyikan paragraf pembuka/penutup'
              : 'Edit paragraf pembuka & penutup (opsional)',
        ),
      ),
      if (_showAllSections) ...[
        TextFormField(
          controller: _pembuka,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Paragraf Pembuka'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _penutup,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Paragraf Penutup (BAB V)',
          ),
        ),
      ],
    ];
  }
}
