import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/models/slot_data.dart';
import '../../../core/theme/app_theme.dart';

/// Interactive photo slot for the editor.
///
/// Empty slot shows a camera placeholder (tappable to pick a photo).
/// Filled slot shows the photo inside an [InteractiveViewer] for pan & zoom
/// (cover fit), with a small remove badge in the corner.
/// [onTap] / [onLongPress] are wired by the editor screen.
final class EditorSlot extends StatefulWidget {
  const EditorSlot({
    super.key,
    required this.data,
    required this.onTap,
    this.onLongPress,
    this.onRemove,
    this.onTransformEnd,
  });

  final SlotData data;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onRemove;

  /// Called when the user finishes pan/zoom, with the new transform.
  final void Function(Offset offset, double scale)? onTransformEnd;

  @override
  State<EditorSlot> createState() => _EditorSlotState();
}

class _EditorSlotState extends State<EditorSlot> {
  TransformationController? _controller;
  SlotData? _lastData;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Reuses the controller but resets it whenever the photo or persisted
  /// transform changes (e.g. after picking a new photo or a swap).
  TransformationController _resolveController() {
    final changed = _lastData == null ||
        _lastData!.fotoPath != widget.data.fotoPath ||
        _lastData!.offset != widget.data.offset ||
        _lastData!.scale != widget.data.scale;
    final controller = _controller ??= TransformationController();
    if (changed) {
      controller.value = Matrix4.identity()
        ..translateByDouble(
          widget.data.offset.dx,
          widget.data.offset.dy,
          0,
          1,
        )
        ..scaleByDouble(widget.data.scale, widget.data.scale, 1, 1);
      _lastData = widget.data;
    }
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final filled = !widget.data.isEmpty;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.slotPlaceholder,
            border: Border.all(
              color: filled ? Colors.transparent : AppColors.outline,
              width: 1.4,
            ),
          ),
          child: filled ? _buildPhoto(context) : _buildPlaceholder(context),
        ),
      ),
    );
  }

  Widget _buildPhoto(BuildContext context) {
    final controller = _resolveController();

    return Stack(
      fit: StackFit.expand,
      children: [
        InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20),
          clipBehavior: Clip.hardEdge,
          transformationController: controller,
          onInteractionEnd: (_) {
            final m = controller.value;
            widget.onTransformEnd
                ?.call(Offset(m.getRow(3).x, m.getRow(3).y), m.getRow(0).x);
          },
          child: Image.file(
            File(widget.data.fotoPath!),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => _buildPlaceholder(context),
          ),
        ),
        if (widget.onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_camera_rounded,
            size: 28,
            color: AppColors.outline,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap untuk isi',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }
}
