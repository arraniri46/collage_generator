import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/collage_report.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter_id.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/profile_provider.dart';
import '../../providers/report_provider.dart';
import '../template_picker/template_picker_screen.dart';

/// Step 1 of the flow: pick profile, title, date, ratio and photo count.
final class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late TextEditingController _judulController;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(
      text: context.read<ReportProvider>().report.judul,
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final provider = context.read<ReportProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.report.tanggalLaporan,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('id'),
    );
    if (picked != null && mounted) {
      provider.setTanggal(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>().report;
    final profiles = context.watch<ProfileProvider>().profiles;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const BrandLogo(size: 32),
            const SizedBox(width: AppSpacing.sm),
            const Text('Buat Laporan'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // Profile selection
          DropdownButtonFormField<String>(
            initialValue: report.profileId ?? profiles.first.id,
            decoration: const InputDecoration(
              labelText: 'Profile Instansi',
              prefixIcon: Icon(Icons.business),
            ),
            items: profiles
                .map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.namaUnit, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (v) => context.read<ReportProvider>().setProfile(v),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Title
          TextFormField(
            controller: _judulController,
            decoration: const InputDecoration(
              labelText: 'Judul Laporan',
              prefixIcon: Icon(Icons.title),
            ),
            onChanged: (v) => context.read<ReportProvider>().setJudul(v),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Date
          InkWell(
            onTap: _pickDate,
            borderRadius:
                BorderRadius.circular(AppSpacing.cardRadius),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Tanggal Laporan',
                prefixIcon: Icon(Icons.calendar_month),
                suffixIcon: Icon(Icons.expand_more),
              ),
              child: Text(DateFormatterId.full(report.tanggalLaporan)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Canvas ratio
          const SectionHeader('Rasio Poster'),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<CanvasRatio>(
            segments: CanvasRatio.values
                .map((r) => ButtonSegment(
                      value: r,
                      label: Text(r.label),
                    ))
                .toList(),
            selected: {report.canvasRatio},
            onSelectionChanged: (s) =>
                context.read<ReportProvider>().setCanvasRatio(s.first),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Photo count
          const SectionHeader('Jumlah Foto'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 1; i <= 9; i++)
                ChoiceChip(
                  label: Text('$i'),
                  selected: report.slots.length == i,
                  onSelected: (_) =>
                      context.read<ReportProvider>().setSlotCount(i),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: FilledButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Lanjut Pilih Template'),
            onPressed: report.slots.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TemplatePickerScreen(),
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
