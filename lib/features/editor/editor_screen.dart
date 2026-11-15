import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/data/templates/template_registry.dart';
import '../../core/models/collage_report.dart';
import '../../core/models/collage_template.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/report_provider.dart';
import 'photo_picker_service.dart';
import 'poster_preview_screen.dart';
import 'widgets/editor_slot.dart';
import '../template_picker/template_picker_screen.dart';

/// Step 3 of the flow: fill photo slots, pan & zoom each photo, swap photos
/// between slots, change template, or reset everything.
final class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, this.pickerService});

  /// Overridable for widget tests.
  final PhotoPickerService? pickerService;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final PhotoPickerService _picker =
      widget.pickerService ?? ImagePickerService();

  /// Index of the source slot in swap mode (null = swap mode off).
  int? _swapSource;

  Future<void> _pickPhoto(int index) async {
    final source = await _showSourceSheet();
    if (source == null || !mounted) return;

    final path = source == ImageSource.camera
        ? await _picker.takeWithCamera()
        : await _picker.pickFromGallery();
    if (path == null || !mounted) return;

    if (_swapSource != null) _swapSource = null;
    context.read<ReportProvider>().setSlotPhoto(index, path);
  }

  Future<ImageSource?> _showSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius + 4),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Pilih Sumber Foto',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Galeri'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Kamera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _handleSlotTap(int index) {
    final slots = context.read<ReportProvider>().report.slots;

    // Swap mode: second tap performs the exchange.
    if (_swapSource != null) {
      final source = _swapSource!;
      setState(() => _swapSource = null);
      if (source != index) {
        context.read<ReportProvider>().swapSlots(source, index);
      }
      return;
    }

    if (slots[index].isEmpty) {
      _pickPhoto(index);
    } else {
      _showPhotoOptions(index);
    }
  }

  Future<void> _showPhotoOptions(int index) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius + 4),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Foto Slot ${index + 1}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded),
              title: const Text('Tukar Posisi (Mode Tukar)'),
              onTap: () => Navigator.of(context).pop('swap'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Ganti Foto'),
              onTap: () => Navigator.of(context).pop('replace'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Hapus Foto'),
              onTap: () => Navigator.of(context).pop('remove'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;

    switch (action) {
      case 'swap':
        setState(() => _swapSource = index);
        break;
      case 'replace':
        await _pickPhoto(index);
        break;
      case 'remove':
        context.read<ReportProvider>().clearSlot(index);
        break;
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Semua Foto?'),
        content: const Text(
          'Semua foto pada slot akan dihapus. Template dan tanggal laporan '
          'tetap dipertahankan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _swapSource = null);
      context.read<ReportProvider>().resetSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final report = reportProvider.report;
    final template = reportProvider.template ??
        // Safety net: editor opened without a picked template gets the
        // first one matching the current slot count.
        TemplateRegistry.bySlotCount(report.slots.length).first;

    return PopScope(
      canPop: _swapSource == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _swapSource != null) {
          setState(() => _swapSource = null);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        appBar: AppBar(
          title: Text(
            _swapSource != null
                ? 'Pilih slot tujuan tukar…'
                : 'Isi Foto (${reportProvider.filledSlotCount}/${report.slots.length})',
          ),
          actions: [
            IconButton(
              tooltip: 'Ganti Template',
              icon: const Icon(Icons.dashboard_customize_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TemplatePickerScreen(),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Reset Semua Foto',
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: _confirmReset,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: _EditorGrid(
                    template: template,
                    report: report,
                    swapSource: _swapSource,
                    onSlotTap: _handleSlotTap,
                    onSlotLongPress: (index) {
                      if (report.slots[index].isEmpty) return;
                      setState(() => _swapSource = index);
                    },
                    onSlotTransformEnd: (index, offset, scale) {
                      reportProvider.updateSlotTransform(index, offset, scale);
                    },
                    onSlotRemove: reportProvider.clearSlot,
                  ),
                ),
              ),
              _EditorBottomBar(
                swapActive: _swapSource != null,
                allFilled:
                    reportProvider.filledSlotCount == report.slots.length,
                onPreview: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PosterPreviewScreen(),
                  ),
                ),
                onContinue: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Semua foto terisi — lanjut ke caption & share '
                        'di fase berikutnya',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// LayoutBuilder that maps template slots into tappable [EditorSlot]s.
final class _EditorGrid extends StatelessWidget {
  const _EditorGrid({
    required this.template,
    required this.report,
    required this.swapSource,
    required this.onSlotTap,
    required this.onSlotLongPress,
    required this.onSlotTransformEnd,
    required this.onSlotRemove,
  });

  final CollageTemplate template;
  final CollageReport report;
  final int? swapSource;
  final void Function(int index) onSlotTap;
  final void Function(int index) onSlotLongPress;
  final void Function(int index, Offset offset, double scale)
      onSlotTransformEnd;
  final void Function(int index) onSlotRemove;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: report.canvasRatio.value,
      child: LayoutBuilder(
        builder: (context, outer) {
          final gap = template.gap * outer.maxWidth;
          final margin = template.margin * outer.maxWidth;

          return Padding(
            padding: EdgeInsets.all(margin),
            child: LayoutBuilder(
              builder: (context, inner) {
                final gw = inner.maxWidth;
                final gh = inner.maxHeight;
                return Stack(
                  children: [
                    for (var i = 0; i < template.slots.length; i++)
                      _slotAt(i, gw, gh, gap),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _slotAt(int index, double gw, double gh, double gap) {
    final rect = template.slots[index].rect;
    return Positioned(
      left: rect.left * gw + gap / 2,
      top: rect.top * gh + gap / 2,
      width: rect.width * gw - gap,
      height: rect.height * gh - gap,
      child: EditorSlot(
        key: ValueKey('editor-slot-$index'),
        data: report.slots[index],
        onTap: () => onSlotTap(index),
        onLongPress: () => onSlotLongPress(index),
        onRemove: swapSource == index ? null : () => onSlotRemove(index),
        onTransformEnd: (offset, scale) =>
            onSlotTransformEnd(index, offset, scale),
      ),
    );
  }
}

/// Bottom action bar: swap-mode hint, Preview button and Continue button.
final class _EditorBottomBar extends StatelessWidget {
  const _EditorBottomBar({
    required this.swapActive,
    required this.allFilled,
    required this.onPreview,
    required this.onContinue,
  });

  final bool swapActive;
  final bool allFilled;
  final VoidCallback onPreview;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (swapActive)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                'Mode tukar aktif — tap slot lain untuk menukar foto.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.primary),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('Preview'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: allFilled ? onContinue : null,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Lanjut'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

