<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\FindingStoreRequest;
use App\Http\Requests\FindingUpdateRequest;
use App\Http\Resources\FindingResource;
use App\Models\Activity;
use App\Models\Finding;
use Illuminate\Http\JsonResponse;

class FindingController extends Controller
{
    public function store(FindingStoreRequest $request): JsonResponse
    {
        $finding = Finding::create($request->validated() + ['status' => $request->input('status', Finding::STATUS_OPEN)]);

        Activity::create([
            'inspection_id' => $finding->inspection_id,
            'type' => Activity::TYPE_FINDING_ADDED,
            'description' => sprintf('Finding "%s" added (%s).', $finding->title, $finding->severity),
            'actor_user_id' => $request->user()?->id,
            'occurred_at' => now(),
        ]);

        return (new FindingResource($finding))->response()->setStatusCode(201);
    }

    public function update(FindingUpdateRequest $request, Finding $finding): JsonResponse
    {
        $finding->update($request->validated());

        return (new FindingResource($finding))->response();
    }
}
