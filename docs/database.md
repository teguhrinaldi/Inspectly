# Database

MySQL 8.x (MariaDB 10.6+ also works). Migrations are the source of truth —
never hand-edit the schema in phpMyAdmin/a GUI tool and expect it to stay in
sync.

## Setup

```bash
cd BE
cp .env.example .env    # then edit DB_* values
php artisan key:generate
php artisan migrate --seed
```

`--seed` runs `database/seeders/DemoSeeder.php`, which creates the exact
story documented in `docs/demo-data.md` (3 customers, 4 sites, 4 templates,
6 inspections in various states, findings, evidence rows, signatures,
activity log). Re-running `php artisan migrate:fresh --seed` at any point
resets to that clean state.

## Schema overview

All id/foreign-key columns are MySQL auto-increment `bigint`s (Eloquent
default). Status/severity/type/enum-like columns are plain `string`, not
native MySQL `enum()` — this keeps the schema portable between MySQL (prod)
and SQLite (fast local test runs); validity is enforced by Laravel's Form
Request validation rules, not the database.

| Table | Notable columns | Cascade behavior |
|---|---|---|
| `users` | `role` (inspector/admin), `phone`, `avatar_url`, `status` | — |
| `inspectors` | `user_id` (1:1 with a `users` row) | cascades with its user |
| `customers` | | — |
| `sites` | `customer_id`, `qr_code` (unique), `latitude`/`longitude` | restrict (a customer/site can't be deleted out from under its inspection history) |
| `inspection_templates` | `category`, `is_active` | — |
| `template_sections` | `template_id` | cascades with its template |
| `template_checklist_items` | `section_id`, `requires_evidence` | cascades with its section |
| `inspections` | `template_id`, `customer_id`, `site_id`, `inspector_id` (→ `users.id`, **not** `inspectors.id`), `status`, `recurrence`, `pass_percentage`, `next_due_at`, `location_lat`/`lng` | restrict on template/customer/site/inspector |
| `inspection_items` | `inspection_id`, `template_checklist_item_id`, `label` (copied at creation so historical inspections stay stable if the template changes later), `result`, `note` | cascades with its inspection; `template_checklist_item_id` nulls on delete |
| `findings` | `inspection_id`, `inspection_item_id` (nullable), `severity`, `status` | cascades with its inspection |
| `evidence` | `inspection_id`, `inspection_item_id`/`finding_id` (nullable), `file_path`, `watermarked_path`, `latitude`/`longitude` | cascades with its inspection |
| `signatures` | `inspection_id`, `type` (inspector/customer), `file_path` | cascades with its inspection |
| `activities` | `inspection_id`, `type`, `actor_user_id` | cascades with its inspection |

See `docs/architecture.md` §1–§2 for the full field list and relationship
diagram, and the actual migration files in `BE/database/migrations/` for the
literal column definitions.

### Why `inspections.inspector_id` points at `users`, not `inspectors`

`Inspector` is a 1:1 profile row alongside a `User` (role=inspector) — it
exists so Admin can manage inspector-specific fields (phone, avatar, status)
without touching authentication internals. But the actual work-assignment
foreign key on `inspections` goes straight to `users.id`, since that's what
Sanctum authenticates and what every "who is logged in" check already has in
hand. The Flutter app's `Inspection.inspectorId` field follows the same
convention. Don't create a inspector-id vs user-id mismatch when extending
this — it's a real bug this project already had once (see the QR-scan
inspection-creation flow's history for the fix).

## Factories & seeders

- `database/factories/*Factory.php` — one per model, used by tests and
  available for buyers who want to generate additional fake data
  (`InspectionFactory` has `draft()/inProgress()/completed()` states,
  `UserFactory` has `admin()/inspector()` states).
- `database/seeders/DemoSeeder.php` — the authoritative demo dataset,
  orchestrated by `DatabaseSeeder`.

## Tests

`php artisan test` uses SQLite by default (`.env.testing`, `:memory:` for
speed). To run the same suite against real MySQL before a release, point
`.env.testing` at a real `DB_CONNECTION=mysql` / `DB_DATABASE=inspectly_testing`
temporarily — see the comment in `BE/.env.testing` for the exact toggle. Both
have been verified to produce identical results (no MySQL-specific strict-
mode, key-length, or type-coercion issues surfaced during this product's own
QA pass).
