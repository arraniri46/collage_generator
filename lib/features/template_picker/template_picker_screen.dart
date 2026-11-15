import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/templates/template_registry.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../providers/report_provider.dart';
import '../editor/poster_preview_screen.dart' as editor;
import 'widgets/template_wireframe.dart';

/// Step 2 of the flow: pick a layout template, filtered by photo count.
final class TemplatePickerScreen extends StatelessWidget {
  const TemplatePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>().report;
    final templates =
        TemplateRegistry.bySlotCount(report.slots.length);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const BrandLogo(size: 32),
            const SizedBox(width: AppSpacing.sm),
            Text('Pilih Template (${report.slots.length} foto)'),
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.82,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          final selected = report.templateId == template.id;
          return _TemplateCard(
            templateName: template.name,
            selected: selected,
            onTap: () {
              context.read<ReportProvider>().selectTemplate(template);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => const editor.PosterPreviewScreen(),
                ),
              );
            },
            child: TemplateWireframe(
              template: template,
              selected: selected,
            ),
          );
        },
      ),
    );
  }
}

final class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.templateName,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String templateName;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            Expanded(child: ClipRRect(child: child)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              templateName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
