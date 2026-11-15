import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../core/services/export_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/caption_builder.dart';
import '../../providers/profile_provider.dart';
import '../../providers/report_provider.dart';
import '../caption/caption_editor_screen.dart';
import 'widgets/poster_canvas.dart';

/// Final screen of the flow: renders the finished poster, previews the
/// composed caption and offers share/copy actions.
final class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _captionExpanded = false;
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final report = reportProvider.report;
    final template = reportProvider.template!;
    final profile = context.watch<ProfileProvider>().byId(report.profileId);
    final caption = CaptionBuilder.build(profile: profile, report: report);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Export & Share'),
        actions: [
          IconButton(
            tooltip: 'Edit Caption',
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CaptionEditorScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Poster render target ---
              Center(
                child: Screenshot(
                  controller: _screenshotController,
                  child: SizedBox(
                    width: 400,
                    child: PosterCanvas(
                      report: report,
                      template: template,
                      profile: profile,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // --- Caption preview (collapsible) ---
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  side: const BorderSide(color: AppColors.outline),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.text_snippet_outlined),
                      title: const Text('Caption Lengkap'),
                      subtitle: const Text('Ketuk untuk lihat/sembunyikan'),
                      trailing: Icon(
                        _captionExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                      ),
                      onTap: () =>
                          setState(() => _captionExpanded = !_captionExpanded),
                    ),
                    if (_captionExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppSpacing.md),
                          ),
                          child: SelectableText(
                            caption,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ExportActions(onShare: () => _showShareSheet(caption)),
              if (_exporting)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showShareSheet(String caption) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.ios_share_rounded),
              title: const Text('Share Poster + Caption'),
              subtitle: const Text('Caption auto-copy, langsung paste di WA'),
              onTap: () => Navigator.of(context).pop('poster_caption'),
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Salin Caption saja'),
              onTap: () => Navigator.of(context).pop('caption'),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Share Poster saja'),
              onTap: () => Navigator.of(context).pop('poster'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;

    setState(() => _exporting = true);
    try {
      switch (action) {
        case 'poster_caption':
          await ExportService.copyCaption(caption);
          final bytes = await ExportService.capture(_screenshotController);
          if (bytes != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Caption tersalin, poster siap dibagikan'),
              ),
            );
            await ExportService.sharePoster(bytes: bytes, text: caption);
          }
          break;
        case 'caption':
          await ExportService.copyCaption(caption);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✓ Caption tersalin ke clipboard')),
            );
          }
          break;
        case 'poster':
          final bytes = await ExportService.capture(_screenshotController);
          if (bytes != null && mounted) {
            await ExportService.sharePoster(bytes: bytes);
          }
          break;
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}

/// Share + copy buttons shown below the poster.
class _ExportActions extends StatelessWidget {
  const _ExportActions({required this.onShare});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.ios_share_rounded),
          label: const Text('Bagikan / Simpan'),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () async {
            final provider = context.read<ReportProvider>();
            final profile = context.read<ProfileProvider>();
            final caption = CaptionBuilder.build(
              profile: profile.byId(provider.report.profileId),
              report: provider.report,
            );
            await ExportService.copyCaption(caption);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Caption tersalin ke clipboard'),
                ),
              );
            }
          },
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Salin Caption Saja'),
        ),
      ],
    );
  }
}