import 'dart:math' as math;
import 'dart:ui';

import '../../data/models/inspection.dart';
import '../../data/models/inspection_template.dart';

/// Labels of checklist items whose template asks for photo evidence but
/// that have no photo yet — on the item itself or on a finding raised for
/// it. Same rule as POST /inspections/{id}/complete (QC-036).
List<String> itemsMissingEvidence(
  Inspection inspection,
  InspectionTemplate? template,
) {
  if (template == null) return const [];
  final required = {
    for (final s in template.sections)
      for (final i in s.items)
        if (i.requiresEvidence) i.id,
  };
  return [
    for (final item in inspection.items)
      if (required.contains(item.templateChecklistItemId) &&
          item.evidence.isEmpty &&
          !inspection.findings.any(
            (f) => f.inspectionItemId == item.id && f.evidence.isNotEmpty,
          ))
        item.label,
  ];
}

/// Minimum ink for a signature (logical pixels): a tap, a dot or a short
/// dash is rejected. A real signature on the ~330 px wide pad easily draws
/// more than [minInk] of line and spans at least [minWidth] horizontally.
const minInk = 150.0;
const minWidth = 60.0;

/// [points] in drawing order; `null` marks a pen-up between strokes.
bool signatureIsLongEnough(List<Offset?> points) {
  var ink = 0.0;
  Offset? prev;
  var minX = double.infinity, maxX = -double.infinity;
  for (final p in points) {
    if (p == null) {
      prev = null;
      continue;
    }
    if (prev != null) ink += (p - prev).distance;
    prev = p;
    minX = math.min(minX, p.dx);
    maxX = math.max(maxX, p.dx);
  }
  return ink >= minInk && (maxX - minX) >= minWidth;
}
