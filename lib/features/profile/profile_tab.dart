import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/brand_profile.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import 'profile_form_screen.dart';

/// Third tab: institution profiles management — list, set active, edit,
/// delete. Editing opens [ProfileFormScreen].
final class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final profiles = provider.profiles;
    final activeId = provider.activeProfile?.id;

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Instansi',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Dipakai untuk branding poster & caption laporan',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: FilledButton.icon(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Baru'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (profiles.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Text(
                    'Belum ada profile. Buat satu untuk memulai.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                  ),
                ),
              ),
            ),
          for (final profile in profiles)
            _ProfileCard(
              profile: profile,
              isActive: profile.id == activeId,
              onSetActive: () => provider.setActive(profile.id),
              onEdit: () => _openForm(context, existing: profile),
              onDelete: () => _confirmDelete(context, provider, profile),
            ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, {BrandProfile? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileFormScreen(existing: existing),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProfileProvider provider,
    BrandProfile profile,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Profile?'),
        content: Text(
          '"${profile.namaUnit}" akan dihapus secara permanen. Laporan yang '
          'sudah dibuat tidak terpengaruh.',
        ),
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
    if (confirmed == true) provider.remove(profile.id);
  }
}

final class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.isActive,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
  });

  final BrandProfile profile;
  final bool isActive;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.outline,
          width: isActive ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: onSetActive,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: profile.warnaBrand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Icon(
                  Icons.business_rounded,
                  color: profile.warnaBrand,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.namaUnit,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Aktif',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.onAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.websiteUrl.isEmpty
                          ? profile.namaInstansi
                          : profile.websiteUrl,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

