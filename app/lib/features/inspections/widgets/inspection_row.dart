import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/status_style.dart';
import '../../../core/widgets/surfaces.dart';
import '../../../data/models/inspection.dart';

enum InspectionRowLeading { sitePhoto, inspectorAvatar }

class InspectionRow extends StatelessWidget {
  const InspectionRow({
    super.key,
    required this.inspection,
    required this.onTap,
    this.leading = InspectionRowLeading.sitePhoto,
    this.showChevron = false,
  });

  final Inspection inspection;
  final VoidCallback onTap;
  final InspectionRowLeading leading;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final date = displayDate(inspection);
    final avatar = leading == InspectionRowLeading.sitePhoto
        ? ClipOval(
            child: SizedBox.square(
              dimension: 50,
              child: AppImage(
                inspection.siteCoverImageUrl,
                placeholderIcon: LucideIcons.building2,
              ),
            ),
          )
        : AppAvatar(
            url: inspection.inspectorAvatarUrl,
            name: inspection.inspectorName,
            size: 50,
          );

    return Semantics(
      button: true,
      label:
          '${inspection.siteName}, ${inspection.templateName}, ${inspection.status.label}',
      excludeSemantics: true,
      child: SurfaceCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          inspection.siteName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: p.textPrimary,
                          ),
                        ),
                      ),
                      if (showChevron)
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: p.textMuted,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inspection.templateName,
                              style: TextStyle(
                                fontSize: 13,
                                color: p.textSecondary,
                              ),
                            ),
                            if (date != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                relativeDateTime(date),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: p.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        style: StatusStyle.forInspectionStatus(
                          inspection.status,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
