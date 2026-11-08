<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsAdmin
{
    /**
     * Role-gate admin-only endpoints. Kept intentionally simple (no permissions
     * package) per architecture.md: only the `role === admin` check matters.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user || $user->role !== \App\Models\User::ROLE_ADMIN) {
            return response()->json([
                'message' => 'This action requires administrator privileges.',
            ], 403);
        }

        return $next($request);
    }
}
