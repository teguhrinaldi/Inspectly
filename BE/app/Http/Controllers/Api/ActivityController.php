<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ActivityResource;
use App\Models\Activity;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ActivityController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'inspection_id' => ['required', 'integer', 'exists:inspections,id'],
        ]);

        $activities = Activity::query()
            ->with('actor')
            ->where('inspection_id', $request->integer('inspection_id'))
            ->orderBy('occurred_at')
            ->paginate(50);

        return ActivityResource::collection($activities)->response();
    }
}
