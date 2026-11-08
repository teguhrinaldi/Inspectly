# Deployment

Inspectly is source code you deploy to your own infrastructure — there is no
hosted service and no dependency on ours. This covers the Laravel API/admin;
the Flutter app is built and distributed the normal way (Play Store/App
Store/internal distribution), pointed at whichever API URL you deployed to
via `--dart-define=INSPECTLY_API_BASE_URL=...` (see `docs/installation.md` §4).

## Backend requirements

- PHP 8.3+ (Laravel 12 — see the PHP version note in
  `docs/installation.md`) with the standard Laravel extension set
  (`pdo_mysql`, `mbstring`, `openssl`, `curl`, `zip`, `gd`, `fileinfo`,
  `bcmath`, `intl`).
- MySQL 8.x or MariaDB 10.6+.
- A process manager for the queue/scheduler if you later add either (neither
  is required for the current feature set — everything here runs
  synchronously).
- HTTPS in front of the API (Sanctum bearer tokens over plain HTTP leak the
  token to anyone on the network path).

## Generic VPS / shared hosting

1. Point the web server's document root at `BE/public`.
2. `composer install --no-dev --optimize-autoloader`
3. Copy `.env.example` to `.env`, fill in real `DB_*`, `APP_URL`, generate
   `APP_KEY` (`php artisan key:generate`), set `APP_ENV=production`,
   `APP_DEBUG=false`.

   > **APP_KEY:** generate a brand-new key **on the server** with
   > `php artisan key:generate`. Never copy the key from a local `.env` or
   > from `BE/.env.testing` (that one is committed to the repository and is
   > only meant for the test suite). Every environment gets its own key.
4. `php artisan migrate --force` (demo data is skipped in production unless
   `ALLOW_DEMO_SEED=true` is set; add `--seed` only for a staging/demo
   environment — never seed fake customers/inspectors into a real production
   database).
5. `php artisan storage:link` (evidence/signature file URLs depend on this).
   Add the Laravel scheduler to cron (`* * * * * cd /path/to/BE && php artisan schedule:run`):
   it prunes expired API tokens daily. App tokens expire after 30 days
   (`SANCTUM_EXPIRATION`, in minutes); inspectors then simply sign in again.
6. `php artisan config:cache && php artisan route:cache`
7. Point your web server (Nginx/Apache) at `public/index.php` per Laravel's
   standard `.htaccess`/Nginx config (unchanged from stock Laravel — nothing
   in this product requires custom web-server rules).

This works on any standard Laravel-compatible host: a plain VPS
(DigitalOcean, Linode, Hetzner, etc.), a managed Laravel host (Laravel
Cloud, Forge-managed VPS), or shared hosting with PHP 8.2+ and SSH/Composer
access. No specific provider is required or assumed.

## File storage

Evidence photos and signatures are stored via Laravel's `public` disk
(`storage/app/public`, symlinked to `public/storage`). For a multi-server
deployment (more than one app server behind a load balancer), switch
`FILESYSTEM_DISK` to an S3-compatible disk instead — Laravel's filesystem
abstraction makes this a config change, not a code change, since
`EvidenceController`/`SignatureController` only ever call
`Storage::disk(...)->store()`/`->url()`.

## Admin panel (`/admin`)

Filament ships as part of the same Laravel app — no separate deployment
step. Access is gated to `role=admin` users (see
`app/Models/User::canAccessPanel()`); make sure you change the seeded demo
admin password (`admin@inspectly.test` / `password`) before deploying
anywhere reachable from the internet, or better, don't seed the demo admin
at all in production and instead create a real admin via `php artisan tinker`
or a one-off seeder.

## Flutter app builds

Standard Flutter release build process — nothing product-specific:

```bash
flutter build apk --release --dart-define=INSPECTLY_USE_API=true --dart-define=INSPECTLY_API_BASE_URL=https://api.yourdomain.com/api
flutter build ipa --release --dart-define=INSPECTLY_USE_API=true --dart-define=INSPECTLY_API_BASE_URL=https://api.yourdomain.com/api
```

Omit the two `--dart-define`s to ship a Demo Mode build (useful for an app
store listing/demo build that doesn't require a live backend).

## What is NOT included

- Server/hosting itself — you provide and pay for your own infrastructure.
- Push notification infrastructure (the product deliberately uses local
  notifications only — see `docs/architecture.md`).
- A CDN/image-processing pipeline beyond the local `public` disk described
  above.
- CI/CD pipelines — set these up to match your own team's process.
