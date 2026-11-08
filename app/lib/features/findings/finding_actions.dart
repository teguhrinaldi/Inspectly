import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers/inspection_providers.dart';
import '../../app/providers/repository_providers.dart';
import '../../data/models/finding.dart';
import '../../data/models/inspection.dart';
import '../../data/repositories/evidence_repository.dart';
import '../checklist/widgets/finding_form_sheet.dart';
import 'widgets/photo_capture.dart';

const _uuid = Uuid();

/// Opens the finding form and persists the finding plus its photos.
/// Returns false when the user cancelled or saving failed.
Future<bool> addFindingFlow(
  BuildContext context,
  WidgetRef ref,
  Inspection inspection, {
  String? itemId,
  String? itemLabel,
}) async {
  final draft = await FindingFormSheet.show(
    context,
    itemLabel: itemLabel,
    siteName: inspection.siteName,
    inspectorName: inspection.inspectorName,
  );
  if (draft == null) return false;

  final result = await ref
      .read(inspectionRepositoryProvider)
      .addFinding(
        Finding(
          id: 'find-${_uuid.v4()}',
          inspectionId: inspection.id,
          inspectionItemId: itemId,
          title: draft.title,
          description: draft.description,
          severity: draft.severity,
          recommendation: draft.recommendation,
          location: draft.location,
        ),
      );
  final saved = result.dataOrNull;
  if (saved == null) {
    if (context.mounted) _showError(context, 'Could not save the finding.');
    return false;
  }
  final failed = await attachPhotos(
    ref.read(evidenceRepositoryProvider),
    inspectionId: inspection.id,
    findingId: saved.id,
    photos: draft.photos,
  );
  ref.invalidateInspection(inspection.id);
  if (failed > 0 && context.mounted) {
    _showError(
      context,
      'Finding saved, but $failed of ${draft.photos.length} photos could not '
      'be uploaded. Add them again from the finding.',
    );
  }
  return true;
}

/// Uploads [photos] one by one and returns how many failed, so callers can
/// tell the inspector instead of silently dropping evidence (QC-012).
Future<int> attachPhotos(
  EvidenceRepository repo, {
  required String inspectionId,
  String? findingId,
  String? itemId,
  required List<CapturedPhoto> photos,
}) async {
  var failed = 0;
  for (final photo in photos) {
    final result = await repo.attach(
      inspectionId: inspectionId,
      inspectionItemId: itemId,
      findingId: findingId,
      localFilePath: photo.path,
      latitude: photo.latitude,
      longitude: photo.longitude,
    );
    if (!result.isSuccess) failed++;
  }
  return failed;
}

Future<void> addItemPhotoFlow(
  BuildContext context,
  WidgetRef ref,
  Inspection inspection,
  String itemId,
) async {
  final photo = await capturePhoto(
    context,
    siteName: inspection.siteName,
    inspectorName: inspection.inspectorName,
  );
  if (photo == null) return;
  final result = await ref
      .read(evidenceRepositoryProvider)
      .attach(
        inspectionId: inspection.id,
        inspectionItemId: itemId,
        localFilePath: photo.path,
        latitude: photo.latitude,
        longitude: photo.longitude,
      );
  if (result.dataOrNull == null && context.mounted) {
    _showError(context, 'Could not save the photo.');
  }
  ref.invalidateInspection(inspection.id);
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
