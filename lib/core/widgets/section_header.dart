import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Section title with a golden accent bar on the left —
/// "minimalis tapi tidak monoton" touch used across forms.
final class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ],
    );
  }
}
