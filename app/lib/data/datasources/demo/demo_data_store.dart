import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/activity_entry.dart';
import '../../models/customer.dart';
import '../../models/enums.dart';
import '../../models/evidence.dart';
import '../../models/finding.dart';
import '../../models/inspection.dart';
import '../../models/inspection_item.dart';
import '../../models/inspection_template.dart';
import '../../models/inspector.dart';
import '../../models/signature.dart';
import '../../models/site.dart';
import '../../models/site_history.dart';
import 'demo_inspections_seed.dart';
import 'demo_reference_data.dart';

/// In-memory, mutable store backing every Mock*Repository. A singleton so
/// state (e.g. starting a scheduled inspection, ticking a checklist item)
/// persists across screens for the lifetime of the demo session.
///
/// Every mutation is also written through to a JSON snapshot on disk
/// (spec §9.22/§9.23 — offline edits and autosave must survive the app being
/// closed unexpectedly). `syncState` is deliberately excluded from that JSON
/// (see the `@JsonKey` on `Inspection.syncState`): there is no real backend
/// in Demo Mode to be "pending sync" against, so a restored inspection is
/// simply treated as at rest — the indicator matters once Mode B (a real
/// API) is wired up, where an actual pending-sync queue would be persisted
/// alongside it.
class DemoDataStore {
  DemoDataStore._internal() {
    _inspections = buildDemoInspections();
    final riversideSep27 = _inspections.firstWhere(
      (i) => i.id == 'insp-riverside-sep27',
    );
    _activities = buildDemoActivities(riversideSep27.startedAt!);
  }

  static final DemoDataStore instance = DemoDataStore._internal();

  /// Signed-in demo user (set by MockAuthRepository). Writes to another
  /// inspector's inspection are refused, like the API does (QC-001).
  String? currentUserId;

  /// Whether the signed-in demo user may change [inspectionId].
  bool mayWrite(String inspectionId) {
    final user = currentUserId;
    if (user == null) return true;
    final inspection = findInspection(inspectionId);
    return inspection == null || inspection.inspectorId == user;
  }

  late List<Inspection> _inspections;
  late List<ActivityEntry> _activities;
  bool _restored = false;

  Future<File> _snapshotFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docsDir.path, 'inspectly'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return File(p.join(dir.path, 'inspections_state_v2.json'));
  }

  /// Call once at app startup (before the first repository read) to resume
  /// any inspection progress left over from a previous session. Falls back
  /// silently to the seeded demo story if no snapshot exists yet or it fails
  /// to parse — never crashes the app over a corrupt local file.
  Future<void> restoreFromDisk() async {
    if (_restored) return;
    _restored = true;
    try {
      final file = await _snapshotFile();
      if (!await file.exists()) return;
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      _inspections = raw
          .map((e) => Inspection.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint(
        'DemoDataStore: could not restore local snapshot, keeping seeded demo data. $e\n$st',
      );
    }
  }

  void _persist() {
    // Fire-and-forget: the UI already has the authoritative in-memory state,
    // this just makes it durable. Errors are logged, never surfaced — a
    // failed autosave write must not block the inspector's workflow.
    unawaited(() async {
      try {
        final file = await _snapshotFile();
        final json = jsonEncode(_inspections.map((i) => i.toJson()).toList());
        await file.writeAsString(json);
      } catch (e, st) {
        debugPrint('DemoDataStore: failed to persist local snapshot. $e\n$st');
      }
    }());
  }

  List<Customer> get customers => DemoReferenceData.customers;
  List<Site> get sites => DemoReferenceData.sites;
  List<Inspector> get inspectors => DemoReferenceData.inspectors;
  List<InspectionTemplate> get templates => DemoReferenceData.templates;

  List<Inspection> get inspections => List.unmodifiable(_inspections);

  Inspection? findInspection(String id) {
    for (final i in _inspections) {
      if (i.id == id) return i;
    }
    return null;
  }

  void _replace(Inspection updated) {
    final index = _inspections.indexWhere((i) => i.id == updated.id);
    if (index == -1) {
      _inspections.add(updated);
    } else {
      _inspections[index] = updated;
    }
    _persist();
  }

  void _addActivity(ActivityEntry entry) => _activities.add(entry);

  List<ActivityEntry> activitiesFor(String inspectionId) =>
      _activities.where((a) => a.inspectionId == inspectionId).toList()
        ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

  /// [inspectorUserId] is the *User* id (not the Inspector table's own id) —
  /// matches the real API, where `inspections.inspector_id` is a foreign key
  /// straight to `users.id` (Inspector is a 1:1 profile row alongside it).
  Inspection createFromTemplate({
    required String templateId,
    required String siteId,
    required String inspectorUserId,
    required RecurrenceType recurrence,
    DateTime? scheduledAt,
  }) {
    final template = templates.firstWhere(
      (t) => t.id == templateId,
      orElse: () => throw StateError('Template $templateId not found'),
    );
    final site = sites.firstWhere(
      (s) => s.id == siteId,
      orElse: () => throw StateError('Site $siteId not found'),
    );
    final inspector = inspectors.firstWhere(
      (i) => i.userId == inspectorUserId,
      orElse: () =>
          throw StateError('Inspector for user $inspectorUserId not found'),
    );

    final now = DateTime.now();
    var sortOrder = 0;
    final items = <InspectionItem>[];
    for (final section in template.sections) {
      for (final templateItem in section.items) {
        items.add(
          InspectionItem(
            id: 'ii-${now.microsecondsSinceEpoch}-${sortOrder++}',
            inspectionId: '', // filled in below once the inspection id is known
            templateChecklistItemId: templateItem.id,
            label: templateItem.label,
            helpText: templateItem.helpText,
            sortOrder: sortOrder - 1,
          ),
        );
      }
    }

    final inspectionId = 'insp-${now.microsecondsSinceEpoch}';
    final inspection = Inspection(
      id: inspectionId,
      templateId: template.id,
      templateName: template.name,
      customerId: site.customerId,
      customerName: site.customerName ?? '',
      siteId: site.id,
      siteName: site.name,
      siteAddress: site.address,
      siteCoverImageUrl: site.coverImageUrl,
      inspectorId: inspector.userId,
      inspectorName: inspector.name,
      inspectorAvatarUrl: inspector.avatarUrl,
      status: scheduledAt == null
          ? InspectionStatus.draft
          : InspectionStatus.scheduled,
      scheduledAt: scheduledAt,
      recurrence: recurrence,
      items: items.map((i) => i.copyWith(inspectionId: inspectionId)).toList(),
      syncState: SyncState.local,
    );
    _inspections.add(inspection);
    _persist();
    return inspection;
  }

  Inspection start(String id, {double? lat, double? lng}) {
    final inspection = findInspection(id);
    if (inspection == null) throw StateError('Inspection $id not found');
    final now = DateTime.now();
    final updated = inspection.copyWith(
      status: InspectionStatus.inProgress,
      startedAt: now,
      locationLat: lat,
      locationLng: lng,
      locationCapturedAt: lat != null ? now : null,
      syncState: SyncState.local,
    );
    _replace(updated);
    _addActivity(
      ActivityEntry(
        id: 'act-${now.microsecondsSinceEpoch}',
        inspectionId: id,
        type: ActivityType.started,
        description: 'Inspection started',
        occurredAt: now,
      ),
    );
    return updated;
  }

  Inspection updateChecklistItem({
    required String inspectionId,
    required String itemId,
    ChecklistResult? result,
    String? note,
  }) {
    final inspection = findInspection(inspectionId);
    if (inspection == null) {
      throw StateError('Inspection $inspectionId not found');
    }
    final items = inspection.items.map((item) {
      if (item.id != itemId) return item;
      return item.copyWith(
        result: result ?? item.result,
        note: note ?? item.note,
      );
    }).toList();
    final updated = inspection.copyWith(
      items: items,
      syncState: SyncState.local,
    );
    _replace(updated);
    final label = items.firstWhere((i) => i.id == itemId).label;
    _addActivity(
      ActivityEntry(
        id: 'act-${DateTime.now().microsecondsSinceEpoch}',
        inspectionId: inspectionId,
        type: ActivityType.checklistUpdated,
        description: 'Checklist updated — $label',
        occurredAt: DateTime.now(),
      ),
    );
    return updated;
  }

  Inspection addFinding(Finding finding) {
    final inspection = findInspection(finding.inspectionId);
    if (inspection == null) {
      throw StateError('Inspection ${finding.inspectionId} not found');
    }
    final updated = inspection.copyWith(
      findings: [...inspection.findings, finding],
      syncState: SyncState.local,
    );
    _replace(updated);
    _addActivity(
      ActivityEntry(
        id: 'act-${DateTime.now().microsecondsSinceEpoch}',
        inspectionId: finding.inspectionId,
        type: ActivityType.findingAdded,
        description: 'Finding added — ${finding.title}',
        occurredAt: DateTime.now(),
      ),
    );
    return updated;
  }

  Inspection updateFinding(Finding finding) {
    final inspection = findInspection(finding.inspectionId);
    if (inspection == null) {
      throw StateError('Inspection ${finding.inspectionId} not found');
    }
    final findings = inspection.findings
        .map((f) => f.id == finding.id ? finding : f)
        .toList();
    final updated = inspection.copyWith(
      findings: findings,
      syncState: SyncState.local,
    );
    _replace(updated);
    return updated;
  }

  Inspection complete(String id) {
    final inspection = findInspection(id);
    if (inspection == null) throw StateError('Inspection $id not found');
    final now = DateTime.now();
    final updated = inspection.copyWith(
      status: InspectionStatus.completed,
      completedAt: now,
      passPercentage: inspection.computedPassPercentage,
      syncState: SyncState.pendingSync,
    );
    _replace(updated);
    _addActivity(
      ActivityEntry(
        id: 'act-${now.microsecondsSinceEpoch}',
        inspectionId: id,
        type: ActivityType.completed,
        description: 'Inspection completed',
        occurredAt: now,
      ),
    );
    _addActivity(
      ActivityEntry(
        id: 'act-${now.microsecondsSinceEpoch + 1}',
        inspectionId: id,
        type: ActivityType.reportGenerated,
        description: 'Report generated',
        occurredAt: now.add(const Duration(seconds: 1)),
      ),
    );
    return updated;
  }

  Evidence attachEvidence(Evidence evidence) {
    final inspection = findInspection(evidence.inspectionId);
    if (inspection == null) {
      throw StateError('Inspection ${evidence.inspectionId} not found');
    }

    Inspection updated;
    if (evidence.findingId != null) {
      final findings = inspection.findings.map((f) {
        if (f.id != evidence.findingId) return f;
        return f.copyWith(evidence: [...f.evidence, evidence]);
      }).toList();
      updated = inspection.copyWith(
        findings: findings,
        syncState: SyncState.local,
      );
    } else if (evidence.inspectionItemId != null) {
      final items = inspection.items.map((i) {
        if (i.id != evidence.inspectionItemId) return i;
        return i.copyWith(evidence: [...i.evidence, evidence]);
      }).toList();
      updated = inspection.copyWith(items: items, syncState: SyncState.local);
    } else {
      updated = inspection;
    }
    _replace(updated);
    _addActivity(
      ActivityEntry(
        id: 'act-${DateTime.now().microsecondsSinceEpoch}',
        inspectionId: evidence.inspectionId,
        type: ActivityType.photoAdded,
        description: 'Photo added',
        occurredAt: DateTime.now(),
      ),
    );
    return evidence;
  }

  /// Removes an evidence record (wherever it lives — inspection item or
  /// finding) across every inspection. Returns true if something was removed.
  bool removeEvidence(String evidenceId) {
    var anyRemoved = false;
    for (final inspection in List<Inspection>.from(_inspections)) {
      var removedHere = false;
      final items = inspection.items.map((item) {
        if (!item.evidence.any((e) => e.id == evidenceId)) return item;
        removedHere = true;
        return item.copyWith(
          evidence: item.evidence.where((e) => e.id != evidenceId).toList(),
        );
      }).toList();
      final findings = inspection.findings.map((finding) {
        if (!finding.evidence.any((e) => e.id == evidenceId)) return finding;
        removedHere = true;
        return finding.copyWith(
          evidence: finding.evidence.where((e) => e.id != evidenceId).toList(),
        );
      }).toList();
      if (removedHere) {
        _replace(
          inspection.copyWith(
            items: items,
            findings: findings,
            syncState: SyncState.local,
          ),
        );
        anyRemoved = true;
      }
    }
    return anyRemoved;
  }

  InspectionSignature addSignature(InspectionSignature signature) {
    final inspection = findInspection(signature.inspectionId);
    if (inspection == null) {
      throw StateError('Inspection ${signature.inspectionId} not found');
    }
    final updated = inspection.copyWith(
      signatures: [...inspection.signatures, signature],
      syncState: SyncState.local,
    );
    _replace(updated);
    _addActivity(
      ActivityEntry(
        id: 'act-${DateTime.now().microsecondsSinceEpoch}',
        inspectionId: signature.inspectionId,
        type: ActivityType.signatureCaptured,
        description: 'Signature captured — ${signature.signerName}',
        occurredAt: DateTime.now(),
      ),
    );
    return signature;
  }

  /// Every non-draft inspection at the site, newest first.
  List<SiteHistoryEntry> historyFor(String siteId) {
    DateTime when(Inspection i) =>
        i.completedAt ?? i.startedAt ?? i.scheduledAt ?? DateTime(0);
    final list =
        _inspections
            .where(
              (i) =>
                  i.siteId == siteId && i.status == InspectionStatus.completed,
            )
            .toList()
          ..sort((a, b) => when(b).compareTo(when(a)));
    return [
      for (final i in list)
        SiteHistoryEntry(
          inspectionId: i.id,
          templateName: i.templateName,
          status: i.status,
          completedAt: when(i),
          passPercentage: i.passPercentage,
        ),
    ];
  }

  /// Deterministic previous-vs-current comparison (architecture.md §7): no
  /// fuzzy/AI matching — findings are matched by the checklist item they
  /// belong to (plus title when one item carries several findings, or when a
  /// finding is not attached to any item).
  SiteComparisonResult? comparisonFor(
    String siteId,
    String currentInspectionId,
  ) {
    final current = findInspection(currentInspectionId);
    if (current == null) return null;
    final currentDate = current.completedAt ?? DateTime.now();

    final previous =
        _inspections
            .where(
              (i) =>
                  i.siteId == siteId &&
                  i.id != currentInspectionId &&
                  i.templateId == current.templateId &&
                  i.status == InspectionStatus.completed &&
                  i.completedAt != null &&
                  i.completedAt!.isBefore(currentDate),
            )
            .toList()
          ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    if (previous.isEmpty) return null;
    final prev = previous.first;

    Map<String, Finding> findingsByKey(Inspection inspection) {
      final map = <String, Finding>{};
      for (final finding in inspection.findings) {
        if (finding.status != FindingStatus.open) continue;
        String? templateItemId;
        for (final item in inspection.items) {
          if (item.id == finding.inspectionItemId) {
            templateItemId = item.templateChecklistItemId;
          }
        }
        final title = finding.title.trim().toLowerCase();
        final key = templateItemId == null
            ? 'finding:$title'
            : map.containsKey(templateItemId)
            ? '$templateItemId:$title'
            : templateItemId;
        map[key] = finding;
      }
      return map;
    }

    final prevByKey = findingsByKey(prev);
    final currentByKey = findingsByKey(current);
    // A finding logged without a checklist item still continues an earlier
    // finding with the same title.
    for (final key in currentByKey.keys.toList()) {
      if (!key.startsWith('finding:') || prevByKey.containsKey(key)) continue;
      final title = key.substring('finding:'.length);
      final match = prevByKey.entries
          .where(
            (e) =>
                !currentByKey.containsKey(e.key) &&
                e.value.title.trim().toLowerCase() == title,
          )
          .firstOrNull;
      if (match != null) currentByKey[match.key] = currentByKey.remove(key)!;
    }
    final keys = {...prevByKey.keys, ...currentByKey.keys};

    final entries = [
      for (final key in keys)
        () {
          final prevFinding = prevByKey[key];
          final currentFinding = currentByKey[key];
          return ComparisonEntry(
            templateChecklistItemId: key,
            label: (currentFinding ?? prevFinding)!.title,
            state: currentFinding != null
                ? (prevFinding != null
                      ? ComparisonState.stillOpen
                      : ComparisonState.newFinding)
                : ComparisonState.resolved,
            previousFindingId: prevFinding?.id,
            previousDescription: prevFinding?.description,
            previousDate: prevFinding != null ? prev.completedAt : null,
            currentFindingId: currentFinding?.id,
            currentDescription: currentFinding?.description,
            currentDate: currentFinding != null ? currentDate : null,
          );
        }(),
    ];

    return SiteComparisonResult(
      siteId: siteId,
      previousInspectionId: prev.id,
      previousDate: prev.completedAt!,
      currentInspectionId: current.id,
      currentDate: currentDate,
      entries: entries,
    );
  }
}
