# Installation

## 1. Requirements

| Tool | Version used to build this product | Notes |
|---|---|---|
| Flutter | 3.47.x (stable) | `flutter doctor` should show no blocking issues for your target platform |
| Dart | 3.13.x | bundled with Flutter |
| PHP | 8.3+ | see "PHP version" note below |
| Composer | 2.x | |
| MySQL | 8.x (MariaDB 10.6+ also works) | |
| Node.js | only needed if you touch Filament's compiled admin assets | not required for normal use |

### PHP version note

The backend runs on **Laravel 12** with Sanctum 4 and Filament 3.3, and needs
**PHP 8.3 or newer** (`composer.json` requires `php: ^8.3`). It was upgraded
from Laravel 10 (end-of-life) straight to 12; `composer audit` reports no
advisories for the locked dependencies.

The application keeps the classic directory layout (`app/Http/Kernel.php`,
`app/Console/Kernel.php`, the service providers in `config/app.php`).
Laravel 11 and 12 still support that layout, so it was not migrated to the
slim `bootstrap/app.php` skeleton; that move is optional and purely
structural. See [Laravel's upgrade guide](https://laravel.com/docs/12.x/upgrade)
before upgrading further.

## 2. Demo Mode (Flutter only, no backend)

```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Log in with `michael.carter@inspectly.test` / `password` (any of the three
seeded inspector accounts work — see `docs/demo-data.md`). Everything works
without a backend: checklist, findings, camera/gallery evidence with
watermarking, GPS tagging, QR scanning, signatures, PDF report generation and
native sharing. Data persists locally between app restarts.

## 3. Full setup (Laravel API + MySQL)

```bash
cd BE
composer install
cp .env.example .env
php artisan key:generate
```

Edit `.env`:

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=inspectly
DB_USERNAME=root
DB_PASSWORD=
```

Create the database (MySQL must already be running):

```sql
CREATE DATABASE inspectly CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Migrate and seed the demo story:

```bash
php artisan migrate --seed
```

Run the API:

```bash
php artisan serve
```

Demo credentials (also seeded into MySQL, same story as Demo Mode):

| Role | Email | Password |
|---|---|---|
| Inspector | michael.carter@inspectly.test | password |
| Inspector | sarah.johnson@inspectly.test | password |
| Inspector | daniel.brooks@inspectly.test | password |
| Admin (Filament panel, `/admin`) | admin@inspectly.test | password |

## 4. Switching the Flutter app from Demo Mode to API Mode

Every repository has both a `Mock*` (Demo Mode) and an `Api*` (talks to the
Laravel API) implementation of the same interface — see
`app/lib/app/providers/repository_providers.dart`, the single seam that picks
between them. Run with the `INSPECTLY_USE_API` dart-define to switch:

```bash
flutter run --dart-define=INSPECTLY_USE_API=true \
            --dart-define=INSPECTLY_API_BASE_URL=http://10.0.2.2:8000/api
```

`INSPECTLY_API_BASE_URL` defaults to `http://10.0.2.2:8000/api`, the address
the Android emulator uses to reach `php artisan serve` on your host machine —
change it to your device's reachable address or your production API URL (see
`app/lib/core/network/api_client.dart`). No other file needs to change: every
screen depends on the repository *interface*, never on `Mock*`/`Api*`
directly.

## 5. Running tests

```bash
# Flutter
cd app && flutter test

# Laravel
cd BE && php artisan test
```

## 6. Device permissions

The app requests, at the point of use (never up front): Camera, Photo
Library, Location (When In Use only — never Always/background), and Local
Notifications. If a permission is denied, the relevant feature degrades
gracefully (e.g. an inspection can still be completed without a GPS tag) —
nothing crashes or blocks the workflow.

## 7. Troubleshooting

- **`flutter pub get` fails on `drift`/`sqlite3_flutter_libs`** — make sure
  you're on a recent stable Flutter; these packages require native builds for
  each platform, which `flutter run` handles automatically on first launch.
- **iOS build fails on camera/location permissions** — make sure
  `ios/Runner/Info.plist` has the `NSCameraUsageDescription`,
  `NSPhotoLibraryUsageDescription` and `NSLocationWhenInUseUsageDescription`
  keys (already included in this project).
- **Laravel: "could not find driver"** — enable `pdo_mysql` in `php.ini`.
- **Composer blocks install over "security vulnerability advisories"** — this
  is Composer 2.9+'s audit-on-install feature: a newly published advisory now
  affects a locked package. Run `composer audit` to see which one and
  `composer update <package>` to move to the patched release; don't silence
  the check.
