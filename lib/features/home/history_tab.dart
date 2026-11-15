import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/collage_report.dart';
import '../../providers/report_provider.dart';

/// Second tab: report history — reports saved from the editor. Each entry
/// can be continued (loaded back into the draft) or deleted.
final class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    final history = provider.history;

    return Scaffold(
      backgroundColor: AppColors.base,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.screenPadding + 8,
          AppSpacing.screenPadding,
          AppSpacing.screenPadding,
        ),
        children: [
          Text(
            'Riwayat Laporan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Laporan yang sudah disimpan dapat dilanjutkan kembali',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxl * 2),
                child: Column(
                  children: [
              Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    size: 40,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Belum ada laporan tersimpan',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Simpan laporan dari editor untuk melihatnya di sini',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                ),
              ],
            ),
          ),
          ),
          for (final report in history)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                side: const BorderSide(color: AppColors.outline),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  report.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  _subtitle(report),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: 'Hapus',
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: () => _confirmDelete(
                      context, provider, report.id, report.judul),
                ),
                onTap: () => _continueReport(context, provider, report),
              ),
            ),
        ],
      ),
    );
  }

  static String _subtitle(CollageReport report) {
    final filled = report.slots.where((s) => !s.isEmpty).length;
    final total = report.slots.length;
    final date = report.savedAt;
    final dateText =
        date != null ? '${date.day}/${date.month}/${date.year}' : 'draft';
    return '$dateText • $filled/$total foto terisi';
  }

  void _continueReport(
    BuildContext context,
    ReportProvider provider,
    CollageReport report,
  ) {
    provider.continueReport(report);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Melanjutkan "${report.judul}"')),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ReportProvider provider,
    String id,
    String judul,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Laporan?'),
        content: Text('"$judul" akan dihapus dari riwayat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) provider.removeFromHistory(id);
  }
}
