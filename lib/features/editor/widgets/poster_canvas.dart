import 'package:flutter/material.dart';

import '../../../core/models/brand_profile.dart';
import '../../../core/models/collage_report.dart';
import '../../../core/models/collage_template.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter_id.dart';
import '../../../core/widgets/brand_logo.dart';

/// Renders the full report poster: header (logo + institution + title +
/// date), photo grid (from the template slots) and footer badge (URL).
///
/// All layout is computed from the template's relative coordinates so the
/// same template works on any [CanvasRatio].
final class PosterCanvas extends StatelessWidget {
  const PosterCanvas({
    super.key,
    required this.report,
    required this.template,
    this.profile,
  });

  final CollageReport report;
  final CollageTemplate template;
  final BrandProfile? profile;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: report.canvasRatio.value,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final gap = template.gap * w;
          final margin = template.margin * w;

          return Container(
            color: AppColors.base,
            padding: EdgeInsets.all(margin),
            child: Column(
              children: [
                // --- Header ---
                _PosterHeader(
                  report: report,
                  profile: profile,
                  logoSize: h * 0.085,
                ),
                SizedBox(height: gap * 2),

                // --- Photo grid ---
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, gridConstraints) {
                      final gw = gridConstraints.maxWidth;
                      final gh = gridConstraints.maxHeight;
                      return Stack(
                        children: [
                          for (var i = 0; i < template.slots.length; i++)
                            _positionedSlot(
                              context,
                              template.slots[i],
                              index: i,
                              gridWidth: gw,
                              gridHeight: gh,
                              gap: gap,
                            ),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(height: gap * 2),

                // --- Footer badge ---
                _PosterFooter(
                  websiteUrl: profile?.websiteUrl ?? '',
                  height: h * 0.055,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _positionedSlot(
    BuildContext context,
    TemplateSlot slot, {
    required int index,
    required double gridWidth,
    required double gridHeight,
    required double gap,
  }) {
    final r = slot.rect;
    return Positioned(
      left: r.left * gridWidth + gap / 2,
      top: r.top * gridHeight + gap / 2,
      width: r.width * gridWidth - gap,
      height: r.height * gridHeight - gap,
      child: _PosterSlot(index: index),
    );
  }
}

/// Header zone: logo + institution lines, then centered title block.
class _PosterHeader extends StatelessWidget {
  const _PosterHeader({
    required this.report,
    required this.profile,
    required this.logoSize,
  });

  final CollageReport report;
  final BrandProfile? profile;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final instansi = (profile?.namaInstansi ?? '').toUpperCase();
    final unit = (profile?.namaUnit ?? '').toUpperCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const BrandLogo(size: 44),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (instansi.isNotEmpty)
                    Text(
                      instansi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: logoSize * 0.42,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  if (unit.isNotEmpty)
                    Text(
                      unit,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: logoSize * 0.30,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: AppColors.onSurfaceMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          report.judul.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: logoSize * 0.52,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.6,
          ),
        ),
        if (unit.isNotEmpty)
          Text(
            unit,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: logoSize * 0.42,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 0.5,
              height: 1.3,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          DateFormatterId.full(report.tanggalLaporan),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: logoSize * 0.42,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Single photo slot placeholder (filled with a photo in the next phase).
class _PosterSlot extends StatelessWidget {
  const _PosterSlot({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slotPlaceholder,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          Icons.photo_camera_rounded,
          size: 28,
          color: AppColors.outline,
        ),
      ),
    );
  }
}

/// Footer zone: navy pill with website URL + golden globe circle.
class _PosterFooter extends StatelessWidget {
  const _PosterFooter({required this.websiteUrl, required this.height});

  final String websiteUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (websiteUrl.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        height: height,
        padding: EdgeInsets.only(left: height * 0.7, right: height * 0.18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              websiteUrl,
              style: TextStyle(
                color: AppColors.onPrimary,
                fontSize: height * 0.46,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(width: height * 0.4),
            Container(
              width: height * 0.78,
              height: height * 0.78,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.language_rounded,
                size: height * 0.5,
                color: AppColors.onAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

