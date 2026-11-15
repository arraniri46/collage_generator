import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/report_provider.dart';
import 'editor_screen.dart';
import 'widgets/poster_canvas.dart';

/// Shows the rendered poster (header + grid placeholders + footer) after
/// the user picks a template. Photo filling arrives in the editor phase.
final class PosterPreviewScreen extends StatelessWidget {
  const PosterPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final report = reportProvider.report;
    final template = reportProvider.template!;
    final profile = context.watch<ProfileProvider>().byId(report.profileId);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(title: const Text('Preview Poster')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: PosterCanvas(
              report: report,
              template: template,
              profile: profile,
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: FilledButton.icon(
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Lanjut Isi Foto (Editor)'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const EditorScreen()),
              );
            },
          ),
        ),
      ),
    );
  }
}
