# Inspectly — Architecture & Domain Contract

This document is the authoritative contract between the Flutter app (`app/`) and the
Laravel API (`BE/`). Both sides must conform to it. If either side needs to diverge,
this document must be updated first.

## 1. Domain entities

### User (Laravel `users` table — auth identity)
- id, name, email, password, role (`inspector` | `admin`), phone, avatar_url, status (`active`|`inactive`), timestamps

### Inspector (profile data for a User with role=inspector)
- id, user_id (FK users), name, email, phone, avatar_url, status, timestamps
- Note: Inspector record is 1:1 with a User account. Kept as its own table so admin
  can manage inspector-specific fields without touching auth internals.

### Customer
- id, name, contact_name, email, phone, address, status (`active`|`inactive`), timestamps

### Site
- id, customer_id (FK), name, address, latitude, longitude, qr_code (unique string,
  format `INSPECTLY:SITE:<SLUG>-<NUM>`), status (`active`|`inactive`), cover_image_url, timestamps

### InspectionTemplate
- id, name, description, category (`safety`|`property`|`equipment`|`vehicle`|`custom`),
  is_active, timestamps

### TemplateSection
- id, template_id (FK), title, sort_order, timestamps

### TemplateChecklistItem
- id, section_id (FK), label, help_text (nullable), requires_evidence (bool),
  sort_order, timestamps

### Inspection
- id, template_id (FK), customer_id (FK), site_id (FK), inspector_id (FK),
  status (`draft`|`scheduled`|`in_progress`|`review`|`completed`),
  scheduled_at, started_at, completed_at,
  recurrence (`one_time`|`weekly`|`monthly`|`quarterly`), next_due_at (nullable),
  location_lat, location_lng, location_captured_at,
  pass_percentage (nullable, computed on completion),
  sync_state (client-only concept, not stored server-side — see §4), timestamps

### InspectionItem (checklist item instance for one inspection)
- id, inspection_id (FK), template_checklist_item_id (FK), label (copied at creation
  time so historical inspections remain stable even if template changes),
  result (`pass`|`fail`|`na`|null=pending), note (nullable), sort_order, timestamps

### Finding
- id, inspection_id (FK), inspection_item_id (FK, nullable — a finding can also be
  raised free-standing during review), title, description, severity
  (`critical`|`high`|`medium`|`low`), recommendation, status (`open`|`resolved`),
  timestamps

### Evidence
- id, inspection_id (FK), inspection_item_id (FK nullable), finding_id (FK nullable),
  file_path, watermarked_path (nullable), latitude, longitude, captured_at, timestamps
- Exactly one of inspection_item_id / finding_id should usually be set, or neither
  (inspection-level evidence).

### Signature
- id, inspection_id (FK), type (`inspector`|`customer`), signer_name, file_path, signed_at, timestamps

### Activity
- id, inspection_id (FK), type (`started`|`checklist_updated`|`finding_added`|
  `photo_added`|`signature_captured`|`completed`|`report_generated`), description,
  actor_user_id (FK nullable), occurred_at, timestamps

## 2. Relationships

```
Customer 1—* Site
Site 1—* Inspection
InspectionTemplate 1—* TemplateSection 1—* TemplateChecklistItem
InspectionTemplate 1—* Inspection
Inspector(User) 1—* Inspection
Inspection 1—* InspectionItem
Inspection 1—* Finding
InspectionItem 1—* Finding (nullable link)
Inspection / InspectionItem / Finding 1—* Evidence
Inspection 1—* Signature
Inspection 1—* Activity
```

## 3. State enums (locked — do not add states without updating this file)

- Inspection status: `DRAFT, SCHEDULED, IN_PROGRESS, REVIEW, COMPLETED`
- Checklist result: `PASS, FAIL, NA`
- Finding severity: `CRITICAL, HIGH, MEDIUM, LOW`
- Finding status: `OPEN, RESOLVED`
- Local sync state (Flutter-only, never sent to API as a field): `LOCAL, PENDING_SYNC, SYNCED, SYNC_FAILED`
- Recurrence: `ONE_TIME, WEEKLY, MONTHLY, QUARTERLY`

## 4. Repository strategy (Flutter)

Every feature repository is an interface with two implementations, chosen via
the single `useApiMode` flag in `app/lib/app/providers/repository_providers.dart`:
- `Mock<X>Repository` — backed by `DemoDataStore` (in-memory + a JSON snapshot
  written to disk on every mutation via `restoreFromDisk()`/`_persist()` —
  see `lib/data/datasources/demo/demo_data_store.dart`), used when the app
  runs in Demo Mode (default, no backend configured).
- `Api<X>Repository` — talks to the Laravel REST API via `core/network/api_client.dart` (Dio).

The UI only ever depends on the repository *interface*, never the implementation.

Note: offline continuation of an in-progress inspection while genuinely
disconnected from a *live* API deployment (Mode B), including a pending-sync
queue and conflict handling, is not implemented — Demo Mode's on-disk JSON
snapshot covers "the app was closed/crashed, resume where I left off" but not
"I was mid-inspection with no signal, on a real backend deployment." Treat
this as a known limitation for Mode B; see `docs/customization.md`.

## 5. API contract (base path `/api`)

See `docs/api.md` for the full, verified reference (every endpoint below has
been exercised end-to-end against a live server, not just written down in
advance). Summary:

```
POST   /login                              -> {token, user}   (not data-wrapped)
POST   /logout
GET    /me                                 -> {user}          (not data-wrapped)

GET    /inspections?status=&site_id=&search=&inspector_id=
GET    /inspections/{id}
POST   /inspections   {template_id, site_id, customer_id, inspector_id, recurrence, status?}
PUT    /inspections/{id}            (admin)
POST   /inspections/{id}/start      {location_lat?, location_lng?}
POST   /inspections/{id}/complete

PUT    /inspections/{id}/items/{itemId}     -> returns the InspectionItem, not the Inspection

GET    /inspection-templates
GET    /inspection-templates/{id}
POST   /inspection-templates      (admin)
PUT    /inspection-templates/{id} (admin)
DELETE /inspection-templates/{id} (admin)

GET    /customers                 POST/PUT admin-gated
GET    /sites                     POST/PUT open to any authenticated user
GET    /sites/{id}
GET    /sites/{id}/history                        -> paginated Inspection list
GET    /sites/{id}/comparison?inspection_id=       -> bespoke shape, see docs/api.md

GET    /inspectors                POST/PUT admin-gated

POST   /findings
PUT    /findings/{id}

POST   /evidence          (multipart: file, inspection_id, inspection_item_id?, finding_id?, lat?, lng?)
DELETE /evidence/{id}
POST   /signatures        (multipart: file, inspection_id, type, signer_name)

GET    /reports/{inspectionId}   -> full compiled JSON; not currently called by the
                                     Flutter app (PDF is built client-side from an
                                     already-fetched Inspection instead)
GET    /activities?inspection_id=
```

`inspector_id` throughout is a **User id** (`users.id`), not a separate
Inspector-table id.

Every single-item response is wrapped in `{"data": {...}}` (Laravel's default
`JsonResource` behavior — `ApiClient.unwrap()` on the Flutter side accounts
for this); list endpoints return `{data: [...], links, meta}`. IDs are MySQL
integers on the wire; `ApiClient`'s response interceptor stringifies every
`id`/`*_id` field before any Flutter model parses it, since every domain
model treats ids as `String`. Auth via Laravel Sanctum bearer tokens. Errors
return `{message, errors?: {field: [msg]}}` with standard HTTP codes
(401/403/404/422/500).

## 6. Report / PDF generation

Report data is compiled client-side (`PdfReportService`, Flutter `pdf`
package) directly from an already-fetched `Inspection` object — not from a
separate `/reports/{id}` call. Because `Inspection` already carries
everything a report needs (denormalized site/customer/inspector names,
items, findings with their evidence, signatures), this works identically and
fully offline in both Demo Mode and API Mode with zero extra network calls.
The Laravel `/reports/{id}` endpoint still exists and returns an equivalent
compiled payload, for any other consumer that might want it (e.g. a future
web report viewer) — the mobile app just doesn't need it.

## 7. Comparison logic (deterministic, no AI)

For a site, the most recent *completed* inspection using the *same template*
(completed before the current one — or before now, if the current one is still
in progress) is compared against the current one. Only open findings take part.

Matching keys, applied identically by `DemoDataStore.comparisonFor` (Flutter)
and `SiteController::comparison` (Laravel):
1. A finding attached to a checklist item is keyed by that item's
   `template_checklist_item_id` — a stable key independent of wording changes.
2. A second finding on the same item is keyed by item + normalized title
   (trimmed, lower-case).
3. A finding with no checklist item is keyed by normalized title; if the
   previous inspection has an unmatched finding with exactly that title, the
   two are treated as the same issue.

Classification:
- Present in previous and current -> `STILL_OPEN`
- Present in previous but not in current -> `RESOLVED`
- Present in current but not previous -> `NEW`

No fuzzy/AI matching is performed.
