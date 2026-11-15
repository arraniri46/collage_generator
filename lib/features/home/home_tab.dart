import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_logo.dart';
import '../../providers/profile_provider.dart';
import '../../providers/report_provider.dart';
import '../setup/setup_screen.dart';
import 'home_widgets.dart';

/// First tab: welcome header, primary CTA and quick stats/tips.
final class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().activeProfile;
    final report = context.watch<ReportProvider>().report;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // --- Navy hero header ---
        Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            MediaQuery.paddingOf(context).top + AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.base,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const BrandLogo(size: 28),
                  ),
                  const Spacer(),
                  Text(
                    'Collage Generator',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Selamat datang 👋',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.85),
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                profile?.namaUnit ?? 'Belum ada profile aktif',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _HomeBody(hasDraft: report.templateId != null),
      ],
    );
  }
}

final class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.hasDraft});

  final bool hasDraft;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          PrimaryCta(
            hasDraft: hasDraft,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SetupScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              const Expanded(
                child: InfoCard(
                  icon: Icons.auto_awesome_mosaic_rounded,
                  label: 'Template',
                  value: '18',
                  accent: false,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Consumer<ProfileProvider>(
                  builder: (context, profiles, _) => InfoCard(
                    icon: Icons.business_rounded,
                    label: 'Profile',
                    value: profiles.profiles.length.toString(),
                    accent: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: AppColors.onAccent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Poster 8 foto gaya "Laporan Atensi" tersedia di '
                      'template — tinggal isi foto, tanggal, dan bagikan.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceMuted,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
