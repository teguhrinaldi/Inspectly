<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller as BaseController;

class Controller extends BaseController
{
    use AuthorizesRequests, ValidatesRequests;

    /** `?per_page=` for list endpoints, clamped to 1..100. */
    protected function perPage(Request $request, int $default = 15): int
    {
        return min(max($request->integer('per_page', $default), 1), 100);
    }
}
