import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../home/home_shell.dart';
import '../profile/profile_form_screen.dart';

/// Intro splash: waits briefly, then routes to [HomeShell]. If no
/// institution profile exists yet, the profile form opens on top so the
/// first-run user lands directly in setup.
final class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1200), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeShell()),
    );
    if (!context.read<ProfileProvider>().hasAnyProfile) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ProfileFormScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_library_rounded,
              size: 72,
              color: AppColors.onPrimary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Collage Generator',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Poster Laporan Atensi Kemenkum',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
