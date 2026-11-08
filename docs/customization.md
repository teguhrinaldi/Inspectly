# Customization

## Branding

- Colors: `app/lib/app/theme/app_colors.dart` — every color used anywhere in
  the app is a named constant here (navy/gray/status colors). Change these,
  not individual widgets.
- Typography/spacing/radius: `app_theme.dart`, `app_spacing.dart` in the same
  folder.
- App name/tagline: `app/lib/features/auth/login_screen.dart` (the only place
  "Inspectly" / "Inspect. Document. Report." are hardcoded as display text)
  plus `app/pubspec.yaml`'s `name:` and each platform's app-name config
  (`android/app/src/main/AndroidManifest.xml`'s `android:label`,
  `ios/Runner/Info.plist`'s `CFBundleDisplayName`).
- Admin panel branding: Filament's own branding config in
  `BE/app/Providers/Filament/AdminPanelProvider.php`.

## Inspection templates / checklist content

These are data, not code — manage them either via the Filament admin
("Inspection Templates" resource, which includes a nested section/checklist
item builder) or by editing `database/seeders/DemoSeeder.php` if you want to
change what ships as the *default* demo content. No Dart/PHP code changes
are needed to add a new template, section, or checklist item, or to mark one
`requires_evidence`.

## Adding a new checklist result type / inspection status

Don't. These are locked enums (`docs/architecture.md` §3) that both the
Flutter models (`data/models/enums.dart`, via `@JsonValue`) and the Laravel
Form Request validation rules (`Rule::in([...])`) must agree on byte-for-
byte. If your use case genuinely needs a new state, update
`docs/architecture.md` first, then both sides together, then re-run both
test suites — a state that exists on only one side of the contract will
silently misbehave (this project's own build hit exactly this kind of
contract drift once, between the Flutter models and the Laravel API
resources, before it was caught by `test/data/api_json_contract_test.dart`).

## Business rules likely to need adjustment per client

- **Pass percentage formula** (`pass / (pass + fail)`, N/A excluded) —
  implemented twice, deliberately kept identical: `Inspection.computedPassPercentage`
  (Flutter, `data/models/inspection.dart`) and `Inspection::computePassPercentage()`
  (Laravel, `app/Models/Inspection.php`). Change both together.
- **Recurrence intervals** (`weekly`/`monthly`/`quarterly`) — Laravel's
  `InspectionController::nextDueAt()` computes the next occurrence date;
  that's the only place the actual interval math lives.
- **Previous-inspection comparison matching key** — currently
  `template_checklist_item_id` (architecture.md §7). If your domain needs a
  different stable identity for "the same issue across inspections" (e.g. a
  location tag), that's `SiteController::comparison()` (Laravel) and
  `DemoDataStore.comparisonFor()` (Flutter Demo Mode) — both must change
  together, and both have direct unit test coverage
  (`SiteComparisonTest.php`, `demo_data_store_test.dart`) to update alongside.
- **Admin-only vs open endpoints** — currently templates/customers/inspectors
  are admin-write-gated, sites are not (see `docs/api.md`). Adjust the
  `admin` middleware group in `BE/routes/api.php`.

## Switching Demo Mode ↔ API Mode

One flag: `useApiMode` in
`app/lib/app/providers/repository_providers.dart` (set via the
`INSPECTLY_USE_API` dart-define — see `docs/installation.md` §4). Every
repository has a `Mock*` and an `Api*` implementation of the same interface;
nothing else in the app needs to change.

## Known limitations (be aware before extending)

- **Offline continuation against a real API deployment** is not implemented
  — Demo Mode persists a local JSON snapshot (survives app restarts), but
  there is no pending-sync queue for editing an inspection while genuinely
  offline against Mode B. If your buyers need this, it's the natural next
  layer to add on top of the existing repository seam (see
  `docs/architecture.md` §4).
- **Laravel 10 / PHP 8.1** — functional and fully tested, but Laravel 10 is
  EOL. See the PHP version note in `docs/installation.md` before a
  production launch.
- **QR-scan-to-create-inspection** always creates a `one_time`,
  `DRAFT`-status inspection — if your workflow wants the QR flow to also let
  the inspector pick a recurrence at creation time, that's a small addition
  to `SiteTemplatePickerSheet` (Flutter) — the repository/API already accept
  a `recurrence` parameter.
