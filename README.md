# Inspectly

**Inspect. Document. Report.**

Inspectly is a premium Flutter + Laravel + MySQL foundation for building
professional inspection and field-reporting applications. It is sold as
source code for developers, freelancers and agencies who need a real
inspection workflow — checklist → finding → evidence → review → sign →
report — without starting from zero.

This is not a UI-only template. Every feature shown in the app is backed by
real, working code: the camera actually captures photos, GPS actually reads
device location, the QR scanner actually scans, signatures are actually
captured and persisted, PDFs are actually generated on-device, and the
Laravel API actually talks to a MySQL database.

## What's inside

```
INSPECTLY/
├── app/          Flutter mobile app (inspector-facing)
├── BE/           Laravel REST API + Filament admin panel
├── docs/         Architecture, installation, API, deployment docs
└── marketing/    Screenshots / promotional assets
```

- **app/** — feature-oriented Flutter app. Runs immediately in **Demo Mode**
  with no backend configuration (an in-memory + on-disk repository seeded
  with a realistic multi-site inspection story). Swap to **API Mode** by
  changing one file (`app/lib/app/providers/repository_providers.dart`) once
  you've deployed the backend.
- **BE/** — Laravel 12 API (Sanctum auth, full REST resource layer) plus a
  Filament admin panel for managing customers, sites, inspectors, templates
  and inspections.
- **docs/** — read `docs/installation.md` first.

## Quick start (Demo Mode — no backend needed)

```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Log in with `michael.carter@inspectly.test` / `password`. See
`docs/demo-data.md` for the full seeded story (sites, customers, inspectors,
inspections, findings).

## Full setup (Flutter + Laravel + MySQL)

See `docs/installation.md` for the complete step-by-step guide, including
demo admin credentials for the Filament panel.

## Documentation

| File | Contents |
|---|---|
| `docs/architecture.md` | Domain model, state machine, API contract — the source of truth both sides implement against |
| `docs/installation.md` | Environment requirements, setup steps, troubleshooting |
| `docs/api.md` | Full REST endpoint reference |
| `docs/database.md` | Schema, migrations, seeders |
| `docs/deployment.md` | Deploying the Laravel API to your own infrastructure |
| `docs/customization.md` | Where to change branding, templates, business rules |
| `docs/assets.md` | Source/license of every bundled demo image |
| `docs/demo-data.md` | The exact seeded demo story |

## Scope (locked)

Two roles only: **Inspector** (mobile app) and **Admin** (web panel).
Customer is a data entity, not a login role. No AI, no payments, no realtime
GPS tracking, no push infrastructure, no multi-tenancy — see
`docs/architecture.md` for the full list of what is intentionally out of
scope and why.

## License

This is a commercial source-code product. See the license terms provided at
the point of purchase.
