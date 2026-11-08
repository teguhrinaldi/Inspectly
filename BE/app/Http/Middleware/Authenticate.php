<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     */
    protected function redirectTo(Request $request): ?string
    {
        // API calls never redirect (there is no API login page); the
        // exception handler turns them into a 401 JSON (QC-063).
        if ($request->expectsJson() || $request->is('api/*')) {
            return null;
        }

        return route('filament.admin.auth.login');
    }
}
