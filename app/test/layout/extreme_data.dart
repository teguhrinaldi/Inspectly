import 'package:inspectly/core/errors/failure.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/data/models/activity_entry.dart';
import 'package:inspectly/data/models/app_user.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/models/inspection.dart';
import 'package:inspectly/data/models/inspection_template.dart';
import 'package:inspectly/data/models/site.dart';
import 'package:inspectly/data/models/site_history.dart';
import 'package:inspectly/data/repositories/auth_repository.dart';
import 'package:inspectly/data/repositories/inspection_repository.dart';
import 'package:inspectly/data/repositories/site_repository.dart';
import 'package:inspectly/data/repositories/template_repository.dart';

/// Worst-case data for layout tests: very long text, emoji, Arabic (RTL)
/// text, huge lists, big numbers, null/empty optional fields — or nothing.
const longName =
    'Maximilian Alexander Wolfgang Bartholomew-Featherstonehaugh III 👷‍♂️🔧';
const longSite =
    'Riverside Office Complex — North Wing Mechanical & Electrical Plant Room, Level B2 🏢⚡';
const arabicCustomer =
    'شركة نورثبريدج لإدارة المرافق المتكاملة والخدمات الهندسية';
const longTemplate =
    'Comprehensive Annual Fire, Electrical & Structural Safety Compliance Inspection 🧯';
const longText =
    'The emergency exit door on the east stairwell 🚪 does not close fully and the '
    'self-closing hinge is corroded; temporary signage was placed. يجب إصلاح الباب فوراً. '
    'Pallets 📦 were stacked in front of the panel again.';

const extremeUser = AppUser(
  id: 'u-extreme',
  name: longName,
  email: 'maximilian.alexander.featherstonehaugh.the.third@very-long-company-domain.inspectly.test',
  role: UserRole.inspector,
  phone: '+62 812 3456 7890 1234',
);

class LayoutDataset {
  LayoutDataset({
    required this.name,
    required this.inspections,
    required this.sites,
    required this.templates,
    required this.detailInProgress,
    required this.detailCompleted,
  });

  final String name;
  final List<Inspection> inspections;
  final List<Site> sites;
  final List<InspectionTemplate> templates;

  /// Served by getById even when the list is empty (deep links).
  final Inspection detailInProgress;
  final Inspection detailCompleted;

  Inspection? byId(String id) {
    for (final i in [...inspections, detailInProgress, detailCompleted]) {
      if (i.id == id) return i;
    }
    return null;
  }
}

Inspection _stretch(Inspection i, int n) => i.copyWith(
  id: '${i.id}-x$n',
  siteName: longSite,
  siteAddress:
      '$longSite, 12345 Very Long Street Name Boulevard, Jakarta Selatan',
  customerName: arabicCustomer,
  templateName: longTemplate,
  inspectorId: n.isEven ? extremeUser.id : i.inspectorId,
  inspectorName: longName,
  passPercentage: n % 3 == 0 ? 100 : (n % 3 == 1 ? 0 : 99.99),
  items: [
    for (final item in i.items)
      item.copyWith(
        label: '${item.label} — $longText',
        note: item.note == null ? null : longText,
        helpText: longText,
      ),
  ],
  findings: [
    for (final f in i.findings)
      f.copyWith(
        title: '${f.title} 🔥 $longSite',
        description: longText,
        recommendation: longText,
        location: longSite,
      ),
  ],
  signatures: [for (final s in i.signatures) s.copyWith(signerName: longName)],
);

LayoutDataset extremeDataset() {
  final demo = DemoDataStore.instance.inspections;
  final inspections = [
    for (var n = 0; n < 500; n++) _stretch(demo[n % demo.length], n),
  ];
  final inProgress = inspections.firstWhere(
    (i) => i.status == InspectionStatus.inProgress && i.items.isNotEmpty,
  );
  final completed = inspections.firstWhere(
    (i) => i.status == InspectionStatus.completed && i.findings.isNotEmpty,
  );
  return LayoutDataset(
    name: 'extreme',
    inspections: inspections,
    sites: [
      for (var n = 0; n < 500; n++)
        Site(
          id: 's$n',
          customerId: 'c$n',
          name: '$longSite #$n',
          customerName: arabicCustomer,
          qrCode: 'INSPECTLY:SITE:S-$n',
          address: n.isEven ? null : longSite,
        ),
    ],
    templates: [
      for (var n = 0; n < 60; n++)
        InspectionTemplate(
          id: 't$n',
          name: '$longTemplate #$n',
          description: longText,
          category: const [
            'safety',
            'property',
            'equipment',
            'vehicle',
            'custom',
          ][n % 5],
          sections: [
            for (var s = 0; s < 3; s++)
              TemplateSection(
                id: 't$n-s$s',
                templateId: 't$n',
                title: 'Section $s — $longText',
                items: [
                  for (var k = 0; k < 40; k++)
                    TemplateChecklistItem(
                      id: 't$n-s$s-i$k',
                      sectionId: 't$n-s$s',
                      label: 'Item $k $longText',
                      requiresEvidence: k.isEven,
                    ),
                ],
              ),
          ],
        ),
    ],
    detailInProgress: inProgress,
    detailCompleted: completed,
  );
}

LayoutDataset emptyDataset() {
  final now = DateTime(2026, 9, 29, 12);
  final bare = Inspection(
    id: 'empty-1',
    templateId: 't',
    templateName: '',
    customerId: 'c',
    customerName: '',
    siteId: 's',
    siteName: '',
    inspectorId: extremeUser.id,
    inspectorName: '',
    status: InspectionStatus.inProgress,
  );
  return LayoutDataset(
    name: 'empty',
    inspections: const [],
    sites: const [],
    templates: const [],
    detailInProgress: bare,
    detailCompleted: bare.copyWith(
      id: 'empty-2',
      status: InspectionStatus.completed,
      completedAt: now,
    ),
  );
}

class FakeAuth implements AuthRepository {
  FakeAuth({this.signedIn = true});
  final bool signedIn;

  @override
  Future<Result<AppUser>> currentUser() async => signedIn
      ? const Success(extremeUser)
      : const Failed(UnauthorizedFailure());
  @override
  Future<bool> isLoggedIn() async => signedIn;
  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async => const Success(extremeUser);
  @override
  Future<Result<void>> logout() async => const Success(null);
}

class FakeInspections implements InspectionRepository {
  FakeInspections(this.data);
  final LayoutDataset data;

  @override
  Future<Result<List<Inspection>>> list([
    InspectionListFilter filter = const InspectionListFilter(),
  ]) async => Success([
    for (final i in data.inspections)
      if ((filter.status == null || i.status == filter.status) &&
          (filter.inspectorId == null || i.inspectorId == filter.inspectorId))
        i,
  ]);

  @override
  Future<Result<Inspection>> getById(String id) async {
    final i = data.byId(id);
    return i == null ? const Failed(NotFoundFailure()) : Success(i);
  }

  @override
  Future<Result<List<ActivityEntry>>> activities(String inspectionId) async =>
      Success([
        if (data.name != 'empty')
          for (var n = 0; n < 50; n++)
            ActivityEntry(
              id: 'a$n',
              inspectionId: inspectionId,
              type: ActivityType.values[n % ActivityType.values.length],
              description: longText,
              actorName: longName,
              occurredAt: DateTime(2026, 9, 27, 9, n),
            ),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSites implements SiteRepository {
  FakeSites(this.data);
  final LayoutDataset data;

  @override
  Future<Result<List<Site>>> list({String? customerId, String? search}) async =>
      Success(data.sites);

  @override
  Future<Result<Site>> getById(String id) async => Success(
    data.sites.firstWhere(
      (s) => s.id == id,
      orElse: () => data.sites.isEmpty
          ? const Site(id: 's', customerId: 'c', name: '', qrCode: '')
          : data.sites.first,
    ),
  );

  @override
  Future<Result<Site>> findByQrCode(String qrCode) async =>
      const Failed(NotFoundFailure());

  @override
  Future<Result<List<SiteHistoryEntry>>> history(String siteId) async =>
      Success([
        if (data.name != 'empty')
          for (var n = 0; n < 60; n++)
            SiteHistoryEntry(
              inspectionId: n == 0 ? data.detailCompleted.id : 'h$n',
              templateName: longTemplate,
              status: InspectionStatus.completed,
              completedAt: DateTime(
                2026,
                9,
                27,
              ).subtract(Duration(days: n * 30)),
              passPercentage: n.isEven ? 100 : 0,
            ),
      ]);

  @override
  Future<Result<SiteComparisonResult?>> comparison(
    String siteId,
    String currentInspectionId,
  ) async {
    if (data.name == 'empty') return const Success(null);
    return Success(
      SiteComparisonResult(
        siteId: siteId,
        previousInspectionId: data.detailCompleted.id,
        previousDate: DateTime(2026, 8, 12),
        currentInspectionId: currentInspectionId,
        currentDate: DateTime(2026, 9, 27),
        entries: [
          for (var n = 0; n < 40; n++)
            ComparisonEntry(
              templateChecklistItemId: 'k$n',
              label: '$longText #$n',
              state: ComparisonState.values[n % ComparisonState.values.length],
              previousDescription: n.isEven ? longText : null,
              currentDescription: n.isOdd ? longText : null,
            ),
        ],
      ),
    );
  }
}

class FakeTemplates implements TemplateRepository {
  FakeTemplates(this.data);
  final LayoutDataset data;

  @override
  Future<Result<List<InspectionTemplate>>> list({
    bool activeOnly = false,
  }) async => Success(data.templates);

  @override
  Future<Result<InspectionTemplate>> getById(String id) async {
    for (final t in data.templates) {
      if (t.id == id) return Success(t);
    }
    return Success(
      InspectionTemplate(id: id, name: longTemplate, category: 'safety'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
