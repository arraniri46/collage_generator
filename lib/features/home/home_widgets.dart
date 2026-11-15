import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../setup/setup_screen.dart';

final class PrimaryCta extends StatelessWidget {
  const PrimaryCta({super.key, required this.onTap, required this.hasDraft});

  final VoidCallback onTap;
  final bool hasDraft;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const SetupScreen()),
      ),
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 4),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF2A4078)],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                color: AppColors.onAccent,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buat Laporan Baru',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDraft
                        ? 'Lanjutkan draft yang sedang berjalan'
                        : 'Pilih template, isi foto, dan bagikan',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onPrimary.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: AppColors.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

final class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: accent ? AppColors.primary : AppColors.onSurfaceMuted,
                ),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
