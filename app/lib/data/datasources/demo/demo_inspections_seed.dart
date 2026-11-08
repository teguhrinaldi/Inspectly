import '../../models/activity_entry.dart';
import '../../models/enums.dart';
import '../../models/evidence.dart';
import '../../models/finding.dart';
import '../../models/inspection.dart';
import '../../models/inspection_item.dart';
import '../../models/inspection_template.dart';
import '../../models/signature.dart';
import 'demo_reference_data.dart';

const _ev = 'assets/images/evidence';

/// The demo story from docs/demo-data.md, mirrored by
/// BE/database/seeders/DemoSeeder.php. It is sized so the app's real
/// calculations reproduce the numbers in the approved mockup.
List<Inspection> buildDemoInspections({DateTime? clock}) {
  final now = clock ?? DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime day(int offset, int hour, int minute) =>
      DateTime(today.year, today.month, today.day + offset, hour, minute);

  // Site history sits on fixed calendar days of the most recent year in
  // which Sep 27 has already passed.
  final y = DateTime(now.year, 9, 28).isAfter(now) ? now.year - 1 : now.year;
  DateTime hist(int month, int d, int hour, int minute) =>
      DateTime(y, month, d, hour, minute);

  final safety = DemoReferenceData.templateSafety;
  final equipment = DemoReferenceData.templateEquipment;
  final property = DemoReferenceData.templateProperty;

  Inspection base({
    required String id,
    required InspectionTemplate template,
    required String siteId,
    required String inspectorId,
    required InspectionStatus status,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    RecurrenceType recurrence = RecurrenceType.oneTime,
    DateTime? nextDueAt,
    List<InspectionItem> items = const [],
    List<Finding> findings = const [],
    List<InspectionSignature> signatures = const [],
    SyncState syncState = SyncState.synced,
  }) {
    final site = DemoReferenceData.sites.firstWhere((s) => s.id == siteId);
    final user = DemoReferenceData.users.firstWhere((u) => u.id == inspectorId);
    final located = startedAt != null && site.latitude != null;
    return Inspection(
      id: id,
      templateId: template.id,
      templateName: template.name,
      customerId: site.customerId,
      customerName: site.customerName ?? '',
      siteId: site.id,
      siteName: site.name,
      siteAddress: site.address,
      siteCoverImageUrl: site.coverImageUrl,
      inspectorId: user.id,
      inspectorName: user.name,
      inspectorAvatarUrl: user.avatarUrl,
      status: status,
      scheduledAt: scheduledAt,
      startedAt: startedAt,
      completedAt: completedAt,
      recurrence: recurrence,
      nextDueAt: nextDueAt,
      locationLat: located ? site.latitude : null,
      locationLng: located ? site.longitude : null,
      locationCapturedAt: located ? startedAt : null,
      passPercentage: status == InspectionStatus.completed
          ? _passRate(items)
          : null,
      items: items,
      findings: findings,
      signatures: signatures,
      syncState: syncState,
    );
  }

  Finding finding(
    String id,
    String inspectionId,
    String? itemId,
    String title,
    FindingSeverity severity,
    String location,
    String description,
    String recommendation,
    List<(String, DateTime)> photos, {
    FindingStatus status = FindingStatus.open,
  }) => Finding(
    id: id,
    inspectionId: inspectionId,
    inspectionItemId: itemId,
    title: title,
    description: description,
    severity: severity,
    location: location,
    recommendation: recommendation,
    status: status,
    evidence: [
      for (final (i, (path, at)) in photos.indexed)
        _evidence('$id-ev$i', inspectionId, '$_ev/$path', at, findingId: id),
    ],
  );

  // --- Riverside — Equipment — Jul 3, all pass -----------------------------
  final jul = hist(7, 3, 10, 15);
  const julId = 'insp-riverside-jul03';
  final riversideJul03 = base(
    id: julId,
    template: equipment,
    siteId: 'site-riverside',
    inspectorId: 'user-daniel',
    status: InspectionStatus.completed,
    scheduledAt: hist(7, 3, 9, 30),
    startedAt: hist(7, 3, 9, 35),
    completedAt: jul,
    items: _items(
      julId,
      'jul03',
      equipment,
      const {},
      fill: ChecklistResult.pass,
    ),
    signatures: _signatures(julId, 'Daniel Brooks', jul),
  );

  // --- Riverside — Safety — Aug 12 ------------------------------------------
  final aug = hist(8, 12, 11, 20);
  const augId = 'insp-riverside-aug12';
  final riversideAug12 = base(
    id: augId,
    template: safety,
    siteId: 'site-riverside',
    inspectorId: 'user-michael',
    status: InspectionStatus.completed,
    scheduledAt: hist(8, 12, 10, 30),
    startedAt: hist(8, 12, 10, 30),
    completedAt: aug,
    recurrence: RecurrenceType.quarterly,
    items: _items(augId, 'aug12', safety, {
      'item-safety-emergency-lighting': _r(
        ChecklistResult.fail,
        'Emergency light flickers in stairwell B.',
      ),
      'item-safety-elec-panels': _r(
        ChecklistResult.fail,
        'Level 2 panel cover dented and missing a screw.',
      ),
    }, fill: ChecklistResult.pass),
    findings: [
      finding(
        'find-aug12-panel',
        augId,
        _itemId('aug12', 'item-safety-elec-panels'),
        'Damaged Electrical Panel',
        FindingSeverity.high,
        'Building A · Floor 2',
        'Level 2 electrical panel cover is dented and missing a retaining screw.',
        'Replace panel cover and re-label circuits within 14 days.',
        [('electrical_panel_damage.jpg', aug)],
      ),
      finding(
        'find-aug12-lighting',
        augId,
        _itemId('aug12', 'item-safety-emergency-lighting'),
        'Flickering Emergency Light',
        FindingSeverity.medium,
        'Building A · Stairwell B',
        'Emergency lighting in stairwell B flickers during the test.',
        'Replace the ballast/fixture in stairwell B and retest.',
        const [],
      ),
    ],
    signatures: _signatures(augId, 'Michael Carter', aug),
  );

  // --- Riverside — Safety — Sep 27 (the risk-summary inspection) -------------
  // 7 pass · 3 needs attention · 2 failed; findings 1 critical · 3 high ·
  // 2 medium · 1 low → overall compliance 100 − 28 = 72%.
  final sepStart = hist(9, 27, 9, 0);
  final sep = hist(9, 27, 10, 5);
  DateTime sepAt(int m) => sepStart.add(Duration(minutes: m));
  const sepId = 'insp-riverside-sep27';
  String sepItem(String t) => _itemId('sep27', t);
  final riversideSep27 = base(
    id: sepId,
    template: safety,
    siteId: 'site-riverside',
    inspectorId: 'user-michael',
    status: InspectionStatus.completed,
    scheduledAt: sepStart,
    startedAt: sepStart,
    completedAt: sep,
    recurrence: RecurrenceType.quarterly,
    nextDueAt: DateTime(y, 12, 27, 9),
    items: _items(sepId, 'sep27', safety, {
      'item-safety-elec-panels': _r(
        ChecklistResult.fail,
        'Still not repaired since the last visit.',
      ),
      'item-safety-fire-exits': _r(
        ChecklistResult.fail,
        'Floor 3 east exit blocked; exit sign out.',
      ),
      'item-safety-gen-plumbing': _r(
        ChecklistResult.fail,
        'Active drip at the Building B riser joint.',
      ),
      'item-safety-gen-ceilings': _r(
        ChecklistResult.fail,
        'Stained tiles below the riser.',
      ),
      'item-safety-gen-roof': _r(
        ChecklistResult.fail,
        'Missing shingles on the Building C roof edge.',
      ),
    }, fill: ChecklistResult.pass),
    findings: [
      finding(
        'find-sep27-panel',
        sepId,
        sepItem('item-safety-elec-panels'),
        'Damaged Electrical Panel',
        FindingSeverity.high,
        'Building A · Floor 2',
        'Level 2 panel cover remains dented and loosely secured — not repaired since the previous inspection.',
        'Escalate: replace the panel cover and re-label circuits.',
        [
          ('electrical_panel_current.jpg', sepAt(10)),
          ('electrical_room.jpg', sepAt(11)),
        ],
      ),
      finding(
        'find-sep27-pipe',
        sepId,
        sepItem('item-safety-gen-plumbing'),
        'Leaking Pipe',
        FindingSeverity.medium,
        'Building B · Floor 1',
        'Active drip at the riser joint in the Building B plant room.',
        'Replace the joint seal and check for corrosion.',
        [
          ('leaking_pipe.jpg', sepAt(20)),
          ('leaking_pipe_2.jpg', sepAt(21)),
          ('leaking_pipe_3.jpg', sepAt(22)),
        ],
      ),
      finding(
        'find-sep27-exit',
        sepId,
        sepItem('item-safety-fire-exits'),
        'Blocked Emergency Exit',
        FindingSeverity.high,
        'Building A · Floor 3',
        'Stored pallets obstruct the Floor 3 east emergency exit door.',
        'Clear the exit route and mark a no-storage zone.',
        [('blocked_exit.jpg', sepAt(30))],
      ),
      finding(
        'find-sep27-roof',
        sepId,
        sepItem('item-safety-gen-roof'),
        'Roof Damage',
        FindingSeverity.low,
        'Building C · Roof',
        'Several shingles are missing along the roof edge.',
        'Schedule shingle replacement before winter.',
        [('roof_damage.jpg', sepAt(40)), ('roof_damage_2.jpg', sepAt(41))],
      ),
      finding(
        'find-sep27-wiring',
        sepId,
        sepItem('item-safety-elec-panels'),
        'Exposed Live Wiring',
        FindingSeverity.critical,
        'Building A · Floor 2',
        'Live conductors are exposed below the damaged panel enclosure.',
        'Isolate the circuit immediately and terminate the conductors.',
        [('exposed_wiring.jpg', sepAt(12))],
      ),
      finding(
        'find-sep27-exitsign',
        sepId,
        sepItem('item-safety-fire-exits'),
        'Exit Sign Not Illuminated',
        FindingSeverity.high,
        'Building A · Floor 3',
        'The illuminated exit sign above the Floor 3 east exit is out.',
        'Replace the lamp and battery pack.',
        [('exit_sign.jpg', sepAt(31))],
      ),
      finding(
        'find-sep27-ceiling',
        sepId,
        sepItem('item-safety-gen-ceilings'),
        'Water-Stained Ceiling',
        FindingSeverity.medium,
        'Building B · Floor 1',
        'Ceiling tiles below the leaking riser show water staining.',
        'Replace stained tiles once the leak is repaired.',
        [('water_stained_ceiling.jpg', sepAt(24))],
      ),
    ],
    signatures: _signatures(sepId, 'Michael Carter', sep),
  );

  // --- Riverside — Safety follow-up — IN PROGRESS today 09:30 --------------
  // 7 / 12 answered, 3 findings, 14 photos.
  final fuStart = day(0, 9, 30);
  DateTime fuAt(int m) => fuStart.add(Duration(minutes: m));
  const fuId = 'insp-riverside-followup';
  String fuItem(String t) => _itemId('today', t);
  Evidence photo(String t, String path, int m) =>
      _evidence('ev-fu-$m', fuId, '$_ev/$path', fuAt(m), itemId: fuItem(t));
  const ext = 'item-safety-fire-extinguishers';
  const exits = 'item-safety-fire-exits';
  const smoke = 'item-safety-smoke-detectors';
  const panel = 'item-safety-elec-panels';
  const wiring = 'item-safety-elec-wiring';
  const ceilings = 'item-safety-gen-ceilings';
  final riversideToday = base(
    id: fuId,
    template: safety,
    siteId: 'site-riverside',
    inspectorId: 'user-michael',
    status: InspectionStatus.inProgress,
    scheduledAt: fuStart,
    startedAt: fuStart,
    items: _items(
      fuId,
      'today',
      safety,
      {
        ext: _r(ChecklistResult.pass),
        exits: _r(ChecklistResult.fail, 'Pallets back in front of the exit.'),
        smoke: _r(ChecklistResult.pass),
        'item-safety-emergency-lighting': _r(ChecklistResult.pass),
        panel: _r(ChecklistResult.fail, 'Cover still not replaced.'),
        wiring: _r(ChecklistResult.pass),
        ceilings: _r(ChecklistResult.fail, 'New staining next to the riser.'),
      },
      evidence: {
        ext: [
          photo(ext, 'fire_extinguisher_expired.jpg', 4),
          photo(ext, 'electrical_room.jpg', 5),
        ],
        exits: [photo(exits, 'exit_sign.jpg', 9)],
        smoke: [photo(smoke, 'smoke_detector.jpg', 14)],
        'item-safety-emergency-lighting': [
          photo('item-safety-emergency-lighting', 'exit_sign.jpg', 17),
        ],
        panel: [
          photo(panel, 'electrical_panel_damage.jpg', 20),
          photo(panel, 'exposed_wiring.jpg', 21),
        ],
        wiring: [photo(wiring, 'electrical_room.jpg', 26)],
        ceilings: [
          photo(ceilings, 'water_stained_ceiling.jpg', 31),
          photo(ceilings, 'leaking_pipe_3.jpg', 32),
        ],
      },
    ),
    findings: [
      finding(
        'find-fu-ceiling',
        fuId,
        fuItem(ceilings),
        'Water-Stained Ceiling',
        FindingSeverity.medium,
        'Building B · Floor 1',
        'Fresh staining next to the riser — the leak has not been fixed.',
        'Chase the plumbing repair before replacing tiles.',
        [('water_stained_ceiling.jpg', fuAt(33))],
      ),
      finding(
        'find-fu-exit',
        fuId,
        fuItem(exits),
        'Blocked Emergency Exit',
        FindingSeverity.high,
        'Building A · Floor 3',
        'Pallets are stored in front of the Floor 3 east exit again.',
        'Remove the pallets today and brief the warehouse team.',
        [('blocked_exit.jpg', fuAt(10))],
      ),
      finding(
        'find-fu-panel',
        fuId,
        fuItem(panel),
        'Damaged Electrical Panel',
        FindingSeverity.high,
        'Building A · Floor 2',
        'Level 2 panel cover still dented; temporary tape applied by facilities.',
        'Replace the panel cover this week.',
        [
          ('electrical_panel_current.jpg', fuAt(22)),
          ('exposed_wiring.jpg', fuAt(23)),
        ],
      ),
    ],
    syncState: SyncState.local,
  );

  // --- Site records just before Sep 27 --------------------------------------
  const wlId = 'insp-westlake-sep26';
  final wlDone = hist(9, 26, 14, 10);
  final westlakeLast = base(
    id: wlId,
    template: property,
    siteId: 'site-westlake-apts',
    inspectorId: 'user-daniel',
    status: InspectionStatus.completed,
    scheduledAt: hist(9, 26, 13, 0),
    startedAt: hist(9, 26, 13, 0),
    completedAt: wlDone,
    recurrence: RecurrenceType.monthly,
    items: _items(wlId, 'wl26', property, {
      'item-property-doors': _r(
        ChecklistResult.fail,
        'Stairwell handrail loose.',
      ),
      'item-property-water-heater': _r(
        ChecklistResult.fail,
        'Drip under the heater inlet.',
      ),
    }, fill: ChecklistResult.pass),
    findings: [
      finding(
        'find-wl26-handrail',
        wlId,
        _itemId('wl26', 'item-property-doors'),
        'Loose Stair Handrail',
        FindingSeverity.low,
        'Block 2 · Stairwell',
        'The stairwell handrail moves when leaned on.',
        'Re-anchor the handrail brackets.',
        const [],
      ),
      finding(
        'find-wl26-pipe',
        wlId,
        _itemId('wl26', 'item-property-water-heater'),
        'Leaking Pipe',
        FindingSeverity.medium,
        'Block 1 · Plant Room',
        'The water heater inlet pipe drips at the fitting.',
        'Replace the fitting and check the pressure valve.',
        [('leaking_pipe_2.jpg', hist(9, 26, 13, 40))],
      ),
    ],
    signatures: _signatures(wlId, 'Daniel Brooks', wlDone),
  );

  const mapleId = 'insp-maple-completed';
  final mapleDone = hist(9, 25, 16, 0);
  final maple = base(
    id: mapleId,
    template: safety,
    siteId: 'site-maple',
    inspectorId: 'user-daniel',
    status: InspectionStatus.completed,
    scheduledAt: day(1, 10, 30),
    startedAt: hist(9, 25, 15, 0),
    completedAt: mapleDone,
    recurrence: RecurrenceType.quarterly,
    items: _items(mapleId, 'maple', safety, {
      exits: _r(ChecklistResult.fail, 'Loading bay exit blocked.'),
    }, fill: ChecklistResult.pass),
    findings: [
      finding(
        'find-maple-exit',
        mapleId,
        _itemId('maple', exits),
        'Blocked Emergency Exit',
        FindingSeverity.high,
        'Unit 4 · Loading Bay',
        'A forklift is parked across the loading-bay emergency exit.',
        'Mark a no-parking zone in front of the exit.',
        [('blocked_exit.jpg', hist(9, 25, 15, 30))],
      ),
    ],
    signatures: _signatures(mapleId, 'Daniel Brooks', mapleDone),
  );

  const centralId = 'insp-centralwh-review';
  final central = base(
    id: centralId,
    template: equipment,
    siteId: 'site-centralwh',
    inspectorId: 'user-michael',
    status: InspectionStatus.review,
    scheduledAt: day(1, 9, 0),
    startedAt: hist(9, 24, 7, 0),
    recurrence: RecurrenceType.monthly,
    items: _items(centralId, 'central', equipment, {
      'item-equipment-forklift': _r(
        ChecklistResult.fail,
        'Forklift horn inoperative.',
      ),
    }, fill: ChecklistResult.pass),
    findings: [
      finding(
        'find-central-forklift',
        centralId,
        _itemId('central', 'item-equipment-forklift'),
        'Forklift Horn Inoperative',
        FindingSeverity.medium,
        'Loading Dock 2',
        'The warning horn on forklift FL-02 does not sound.',
        'Tag out FL-02 until the horn is repaired.',
        const [],
      ),
    ],
  );

  // --- Upcoming / open work (Michael) ---------------------------------------
  final westlake = base(
    id: 'insp-westlake-scheduled',
    template: property,
    siteId: 'site-westlake-apts',
    inspectorId: 'user-michael',
    status: InspectionStatus.scheduled,
    scheduledAt: day(0, 14, 0),
    recurrence: RecurrenceType.monthly,
    items: _items('insp-westlake-scheduled', 'westlake', property, const {}),
  );

  final oakwood = base(
    id: 'insp-oakwood-scheduled',
    template: property,
    siteId: 'site-oakwood',
    inspectorId: 'user-michael',
    status: InspectionStatus.scheduled,
    scheduledAt: DateTime(y, 12, 5, 8),
    recurrence: RecurrenceType.quarterly,
    items: _items('insp-oakwood-scheduled', 'oakwood', property, const {}),
  );

  final january = base(
    id: 'insp-centralwh-january',
    template: safety,
    siteId: 'site-centralwh',
    inspectorId: 'user-michael',
    status: InspectionStatus.scheduled,
    scheduledAt: DateTime(y + 1, 1, 14, 9),
    recurrence: RecurrenceType.quarterly,
    items: _items('insp-centralwh-january', 'jan', safety, const {}),
  );

  const oakIpId = 'insp-oakwood-inprogress';
  final oakwoodInProgress = base(
    id: oakIpId,
    template: property,
    siteId: 'site-oakwood',
    inspectorId: 'user-michael',
    status: InspectionStatus.inProgress,
    scheduledAt: day(-1, 8, 0),
    startedAt: day(-1, 8, 10),
    items: _items(oakIpId, 'oakip', property, {
      'item-property-roof': _r(ChecklistResult.pass),
      'item-property-facade': _r(ChecklistResult.pass),
      'item-property-parking': _r(ChecklistResult.pass),
      'item-property-signage': _r(ChecklistResult.pass),
    }),
  );

  final anchors = [
    riversideToday,
    westlake,
    central,
    maple,
    oakwood,
    january,
    oakwoodInProgress,
    riversideSep27,
    westlakeLast,
    riversideAug12,
    riversideJul03,
  ];

  // --- Earlier routine inspections at the other sites -----------------------
  final latestAllowed = hist(9, 23, 17, 0);
  final fillerSites = [
    ('site-westlake-apts', property),
    ('site-centralwh', equipment),
    ('site-maple', safety),
    ('site-oakwood', property),
  ];
  const completers = ['user-sarah', 'user-daniel', 'user-michael'];
  const starters = ['user-sarah', 'user-daniel'];
  final fillers = <Inspection>[];
  for (final (n, slot) in planFillers(
    anchors: anchors,
    today: today,
    latestAllowed: latestAllowed,
  ).indexed) {
    final (siteId, template) = fillerSites[n % fillerSites.length];
    final id = 'insp-filler-${n.toString().padLeft(2, '0')}';
    final prefix = 'f$n';
    final done = slot.status == InspectionStatus.completed;
    final itemIds = [
      for (final s in template.sections)
        for (final i in s.items) i.id,
    ];
    final failing = itemIds.take(slot.findings).toList();
    final end = slot.date.add(const Duration(minutes: 70));
    fillers.add(
      base(
        id: id,
        template: template,
        siteId: siteId,
        inspectorId: done
            ? completers[n % completers.length]
            : starters[n % starters.length],
        status: slot.status,
        scheduledAt: slot.date,
        startedAt: slot.date,
        completedAt: done ? end : null,
        items: _items(id, prefix, template, {
          for (final t in failing) t: _r(ChecklistResult.fail),
          if (!done)
            for (final t in itemIds.skip(failing.length).take(2))
              t: _r(ChecklistResult.pass),
        }, fill: done ? ChecklistResult.pass : null),
        findings: [
          for (final (k, t) in failing.indexed)
            Finding(
              id: '$id-find$k',
              inspectionId: id,
              inspectionItemId: _itemId(prefix, t),
              title: _fillerIssues[(n + k) % _fillerIssues.length].$1,
              description: 'Recorded during a routine inspection.',
              severity: _fillerIssues[(n + k) % _fillerIssues.length].$2,
              location: 'Main building',
              recommendation: 'Repair and verify at the next visit.',
              status: FindingStatus.resolved,
            ),
        ],
        signatures: done ? _signatures(id, 'Inspector', end) : const [],
      ),
    );
  }

  return [...anchors, ...fillers];
}

const _fillerIssues = [
  ('Worn Floor Marking', FindingSeverity.low),
  ('Missing Inspection Tag', FindingSeverity.medium),
  ('Loose Cable Tray', FindingSeverity.medium),
  ('Obstructed Walkway', FindingSeverity.high),
  ('Faded Safety Sign', FindingSeverity.low),
  ('Dripping Valve', FindingSeverity.medium),
];

/// Mockup targets for the admin dashboard, reproduced by real counting:
/// 48 inspections (12 in progress, 32 completed); last 30 days vs the 30
/// before — scheduled 19 vs 17 (+12%), completed 14 vs 13 (+8%), findings
/// raised 40 vs 41 (−2%).
const fillerTargets = (
  completed: 32,
  inProgress: 12,
  scheduledLast: 19,
  scheduledPrev: 17,
  completedLast: 14,
  completedPrev: 13,
  findingsLast: 40,
  findingsPrev: 41,
);

class FillerSlot {
  const FillerSlot(this.status, this.date, this.findings);
  final InspectionStatus status;
  final DateTime date;
  final int findings;
}

enum TrendWindow { last, prev, other }

/// Day-based windows: last = today and the 29 days before; prev = the 30
/// days before that. Future dates fall in neither.
TrendWindow windowOf(DateTime at, DateTime today) {
  final age = today.difference(DateTime(at.year, at.month, at.day)).inDays;
  if (age >= 0 && age <= 29) return TrendWindow.last;
  if (age >= 30 && age <= 59) return TrendWindow.prev;
  return TrendWindow.other;
}

DateTime? activityDate(Inspection i) =>
    i.completedAt ?? i.startedAt ?? i.scheduledAt;

List<FillerSlot> planFillers({
  required List<Inspection> anchors,
  required DateTime today,
  required DateTime latestAllowed,
}) {
  int count(
    bool Function(Inspection) f,
    TrendWindow w,
    DateTime? Function(Inspection) at,
  ) => anchors.where((i) {
    final d = at(i);
    return f(i) && d != null && windowOf(d, today) == w;
  }).length;
  int findingsIn(TrendWindow w) => anchors
      .where((i) {
        final d = activityDate(i);
        return d != null && windowOf(d, today) == w;
      })
      .fold(0, (s, i) => s + i.findings.length);
  bool completed(Inspection i) => i.status == InspectionStatus.completed;
  bool nonDraft(Inspection i) => i.status != InspectionStatus.draft;
  int atLeast0(int v) => v < 0 ? 0 : v;

  const t = fillerTargets;
  final compLast = atLeast0(
    t.completedLast - count(completed, TrendWindow.last, (i) => i.completedAt),
  );
  final compPrev = atLeast0(
    t.completedPrev - count(completed, TrendWindow.prev, (i) => i.completedAt),
  );
  final compOld = atLeast0(
    t.completed - anchors.where(completed).length - compLast - compPrev,
  );
  final ipTotal = atLeast0(
    t.inProgress -
        anchors.where((i) => i.status == InspectionStatus.inProgress).length,
  );
  final ipLast = atLeast0(
    t.scheduledLast -
        count(nonDraft, TrendWindow.last, (i) => i.scheduledAt) -
        compLast,
  ).clamp(0, ipTotal);
  final ipPrev = atLeast0(
    t.scheduledPrev -
        count(nonDraft, TrendWindow.prev, (i) => i.scheduledAt) -
        compPrev,
  ).clamp(0, ipTotal - ipLast);
  final ipOld = ipTotal - ipLast - ipPrev;

  List<int> spread(int total, int slots) => [
    for (var k = 0; k < slots; k++)
      total ~/ slots + (k < total % slots ? 1 : 0),
  ];

  final slots = <FillerSlot>[];
  void window(int comp, int ip, List<int> findings, int youngest, int oldest) {
    final total = comp + ip;
    for (var k = 0; k < total; k++) {
      final age = total == 1
          ? youngest
          : youngest + ((oldest - youngest) * k) ~/ (total - 1);
      slots.add(
        FillerSlot(
          k < comp ? InspectionStatus.completed : InspectionStatus.inProgress,
          DateTime(today.year, today.month, today.day - age, 9 + k % 6),
          findings.isEmpty ? 0 : findings[k],
        ),
      );
    }
  }

  // Keep last-window fillers older than the key site records.
  final cap = DateTime(
    latestAllowed.year,
    latestAllowed.month,
    latestAllowed.day,
  );
  final youngestLast = today.difference(cap).inDays.clamp(0, 29);
  window(
    compLast,
    ipLast,
    spread(
      atLeast0(t.findingsLast - findingsIn(TrendWindow.last)),
      compLast + ipLast,
    ),
    youngestLast,
    29,
  );
  window(
    compPrev,
    ipPrev,
    spread(
      atLeast0(t.findingsPrev - findingsIn(TrendWindow.prev)),
      compPrev + ipPrev,
    ),
    30,
    59,
  );
  window(compOld, ipOld, const [], 62, 120);
  return slots;
}

(ChecklistResult, String?) _r(ChecklistResult result, [String? note]) =>
    (result, note);

String _itemId(String prefix, String templateItemId) =>
    'ii-$prefix-${templateItemId.replaceFirst('item-', '')}';

List<InspectionItem> _items(
  String inspectionId,
  String prefix,
  InspectionTemplate template,
  Map<String, (ChecklistResult, String?)> results, {
  ChecklistResult? fill,
  Map<String, List<Evidence>> evidence = const {},
}) {
  var order = 0;
  return [
    for (final section in template.sections)
      for (final item in section.items)
        InspectionItem(
          id: _itemId(prefix, item.id),
          inspectionId: inspectionId,
          templateChecklistItemId: item.id,
          label: item.label,
          helpText: item.helpText,
          result: results[item.id]?.$1 ?? fill,
          note: results[item.id]?.$2,
          sortOrder: order++,
          evidence: evidence[item.id] ?? const [],
        ),
  ];
}

Evidence _evidence(
  String id,
  String inspectionId,
  String path,
  DateTime at, {
  String? itemId,
  String? findingId,
}) => Evidence(
  id: id,
  inspectionId: inspectionId,
  inspectionItemId: itemId,
  findingId: findingId,
  filePath: path,
  capturedAt: at,
);

List<InspectionSignature> _signatures(
  String inspectionId,
  String inspector,
  DateTime at,
) => [
  InspectionSignature(
    id: 'sig-$inspectionId-inspector',
    inspectionId: inspectionId,
    type: SignatureType.inspector,
    signerName: inspector,
    filePath: 'assets/images/demo/signature_inspector.png',
    signedAt: at,
  ),
  InspectionSignature(
    id: 'sig-$inspectionId-customer',
    inspectionId: inspectionId,
    type: SignatureType.customer,
    signerName: 'Rachel Kim',
    filePath: 'assets/images/demo/signature_customer.png',
    signedAt: at,
  ),
];

double _passRate(List<InspectionItem> items) {
  final pass = items.where((i) => i.result == ChecklistResult.pass).length;
  final fail = items.where((i) => i.result == ChecklistResult.fail).length;
  return pass + fail == 0 ? 0 : pass / (pass + fail) * 100;
}

/// Activity timeline for the Sep 27 inspection — see docs/demo-data.md.
List<ActivityEntry> buildDemoActivities(DateTime started) {
  DateTime at(int minutes) => started.add(Duration(minutes: minutes));
  const id = 'insp-riverside-sep27';
  ActivityEntry a(String n, ActivityType type, String text, int minutes) =>
      ActivityEntry(
        id: 'act-sep27-$n',
        inspectionId: id,
        type: type,
        description: text,
        occurredAt: at(minutes),
      );
  return [
    a('1', ActivityType.started, 'Inspection started', 0),
    a(
      '2',
      ActivityType.findingAdded,
      'Finding added — Damaged Electrical Panel',
      10,
    ),
    a(
      '3',
      ActivityType.findingAdded,
      'Finding added — Exposed Live Wiring',
      12,
    ),
    a('4', ActivityType.findingAdded, 'Finding added — Leaking Pipe', 20),
    a(
      '5',
      ActivityType.findingAdded,
      'Finding added — Blocked Emergency Exit',
      30,
    ),
    a('6', ActivityType.findingAdded, 'Finding added — Roof Damage', 40),
    a(
      '7',
      ActivityType.signatureCaptured,
      'Inspector signature captured — Michael Carter',
      62,
    ),
    a(
      '8',
      ActivityType.signatureCaptured,
      'Customer signature captured — Rachel Kim',
      64,
    ),
    a('9', ActivityType.completed, 'Inspection completed', 65),
    a('10', ActivityType.reportGenerated, 'Report generated', 65),
  ];
}
