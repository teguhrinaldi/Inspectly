<?php

namespace App\Support;

use Illuminate\Support\Facades\Storage;

/**
 * Seeded demo rows reference photos bundled with the mobile app
 * (`assets/images/...`); the same files are published under
 * public/demo-assets so the web admin can show them. Anything else is an
 * uploaded file on the public disk, or already a full URL.
 */
class MediaUrl
{
    public static function for(?string $path): ?string
    {
        if ($path === null || $path === '') {
            return null;
        }
        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            return $path;
        }
        if (str_starts_with($path, 'assets/images/')) {
            $relative = substr($path, strlen('assets/images/'));

            return asset('demo-assets/'.(str_starts_with($relative, 'demo/') ? substr($relative, 5) : $relative));
        }

        return Storage::disk('public')->url($path);
    }
}
