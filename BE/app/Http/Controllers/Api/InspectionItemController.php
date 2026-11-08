<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\InspectionItemUpdateRequest;
use App\Http\Resources\InspectionItemResource;
use App\Models\Activity;
use App\Models\Inspection;
use App\Models\InspectionItem;
use Illuminate\Http\JsonResponse;

class InspectionItemController extends Controller
{
    public function update(InspectionItemUpdateRequest $request, Inspection $inspection, InspectionItem $item): JsonResponse
    {
        abort_if($item->inspection_id !== $inspection->id, 404);
        $this->authorize('write', $inspection);

        $item->update($request->validated());

        Activity::create([
            'inspection_id' => $inspection->id,
            'type' => Activity::TYPE_CHECKLIST_UPDATED,
            'description' => sprintf('Checklist item "%s" updated to %s.', $item->label, $item->result ?? 'pending'),
            'actor_user_id' => $request->user()?->id,
            'occurred_at' => now(),
        ]);

        return (new InspectionItemResource($item))->response();
    }
}
