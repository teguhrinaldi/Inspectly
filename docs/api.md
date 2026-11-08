# API Reference

Base path: `/api`. Auth: Laravel Sanctum bearer tokens (`Authorization: Bearer <token>`).

Every **single-item** JSON response is wrapped in `{"data": {...}}` (Laravel's
default `JsonResource` behavior). Every **list** endpoint returns a paginated
shape: `{"data": [...], "links": {...}, "meta": {...}}`. The Flutter client's
`ApiClient.unwrap()` (single-item) and the `response.data['data']` pattern
(lists) both account for this — see `app/lib/core/network/api_client.dart`.

IDs are MySQL auto-increment integers on the wire, but every Flutter domain
model treats every id as a `String` (so the same models work for
client-generated ids too, e.g. while offline). `ApiClient`'s response
interceptor (`normalizeIds`) stringifies every `id`/`*_id` field right after
decoding, before any model ever sees it — this is the single place that
conversion happens.

## Auth

```
POST /login              {email, password}           -> {token, user}
POST /logout                                          -> {message}
GET  /me                                              -> {user}
```

`login`/`me` do not use the `{"data": ...}` wrapper — they hand-build
`{token, user}` / `{user}` responses.

## Inspections

```
GET  /inspections?status=&site_id=&search=&inspector_id=&per_page=   -> paginated list (default 50, max 100), each row includes items[] and findings[] with evidence
GET  /inspections/{id}
POST /inspections          {template_id, site_id, customer_id, inspector_id, recurrence, status?, scheduled_at?}   (non-admin: inspector_id must be the caller)
PUT  /inspections/{id}     (admin)
POST /inspections/{id}/start      {location_lat?, location_lng?}   409 if already completed; no-op if in_progress; owner or admin only
POST /inspections/{id}/complete                                     422 (errors.items) if an item has no result; no-op if already completed
PUT  /inspections/{id}/items/{itemId}   {result?, note?}   -> the updated InspectionItem (not the Inspection)
```

Inspection rows also carry flat display fields: `template_name`, `customer_name`,
`site_name`, `site_address`, `site_cover_image_url`, `inspector_name`,
`inspector_avatar_url`. Checklist items carry `help_text` (the question shown
in the checklist wizard) from their template item.

`inspector_id` is a **User** id (`users.id`), not a separate Inspector-table
id — `inspections.inspector_id` is a direct foreign key to `users`.

`POST .../complete` computes `pass_percentage` (pass / (pass+fail), N/A
excluded), logs a `completed` activity, and — if the inspection has a
recurrence other than `one_time` — immediately creates the *next* Inspection
row (status `scheduled`, checklist pre-generated from the same template)
rather than storing a pointer some other process has to interpret later.

## Inspection Templates (admin-only writes)

```
GET    /inspection-templates?active=1
GET    /inspection-templates/{id}
POST   /inspection-templates      (admin)
PUT    /inspection-templates/{id} (admin)
DELETE /inspection-templates/{id} (admin)
```

## Customers (admin-only writes) / Inspectors (admin-only writes) / Sites

```
GET  /customers?search=          GET/POST/PUT admin-gated for writes
GET  /sites?customer_id=&search=&status=&qr_code=   (qr_code = exact match, used by the QR scanner)
GET  /sites/{id}
POST /sites  |  PUT /sites/{id}          (open to any authenticated user)
GET  /sites/{id}/history                 -> paginated Inspection list (drafts excluded), most recent first
GET  /sites/{id}/comparison?inspection_id=
GET  /inspectors?search=          GET open; POST/PUT admin-gated

Every list endpoint is paginated and accepts `per_page` (1-100; default 15,
50 for inspections and activities). The app reads all pages by following
`meta.last_page` (`ApiClient.getAllPages`).
```

### `GET /sites/{id}/comparison` response shape (bespoke, not a JsonResource)

```json
{
  "has_previous": true,
  "previous_inspection_id": 2,
  "previous_completed_at": "2026-08-12T08:35:00Z",
  "comparison": [
    {"classification": "STILL_OPEN", "finding": {...FindingResource}, "previous_finding": {...FindingResource}},
    {"classification": "RESOLVED", "finding": null, "previous_finding": {...FindingResource}},
    {"classification": "NEW", "finding": {...FindingResource}, "previous_finding": null}
  ]
}
```

`{"has_previous": false, "comparison": []}` when no comparable earlier
inspection exists (deterministic — see `docs/architecture.md` §7). The
Flutter client's `ApiSiteRepository.comparison()` translates this shape into
`SiteComparisonResult`/`ComparisonEntry`.

## Findings

```
POST /findings   {inspection_id, inspection_item_id?, title, description, severity, recommendation?, location?, status?}
PUT  /findings/{id}
```

`location` is free text such as `Building A · Floor 2`.

Image fields (`cover_image_url`, `avatar_url`, evidence/signature `file_path`)
may hold a path to an image bundled in the mobile app (`assets/...`, used by
the demo seeder); the app renders those locally and uses `file_url` for
uploaded files.

## Evidence & Signatures (multipart uploads)

```
POST   /evidence     multipart: file, inspection_id, inspection_item_id?, finding_id?, lat?, lng?, accuracy?   (accuracy = GPS radius in metres)
DELETE /evidence/{id}
POST   /signatures   multipart: file, inspection_id, type (inspector|customer), signer_name
```

Note the field names are `lat`/`lng` (not `latitude`/`longitude`).

## Reports & Activity

```
GET /reports/{inspectionId}   -> full compiled JSON (not currently called by
                                  the Flutter app — it builds the PDF client-side
                                  from an already-fetched Inspection instead, so
                                  Demo Mode and API Mode produce an identical
                                  report with zero extra network calls; this
                                  endpoint exists for other potential consumers,
                                  e.g. a future web report viewer)
GET /activities?inspection_id=   -> paginated ActivityEntry list
```

## Error shape

```
401 {"message": "..."}                          — expired/invalid token
403 {"message": "..."}                          — authenticated but not admin
404 {"message": "..."}                          — not found
422 {"message": "...", "errors": {"field": ["msg", ...]}}   — validation
500 {"message": "..."}
```
