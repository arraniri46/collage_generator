import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Second tab: report history. Populated once persistence lands
/// (reports are currently kept in memory only).
final class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
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
          'Laporan yang pernah dibuat akan tersimpan di sini',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
        ),
        const SizedBox(height: AppSpacing.xxl * 2),
        Center(
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
                'Riwayat akan aktif setelah fitur penyimpanan hadir',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
