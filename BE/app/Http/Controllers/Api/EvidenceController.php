<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\EvidenceStoreRequest;
use App\Http\Resources\EvidenceResource;
use App\Models\Activity;
use App\Models\Evidence;
use App\Models\Inspection;
use Illuminate\Http\JsonResponse;

class EvidenceController extends Controller
{
    public function store(EvidenceStoreRequest $request): JsonResponse
    {
        $data = $request->validated();
        $this->authorize('write', Inspection::findOrFail($data['inspection_id']));

        $path = $request->file('file')->store('evidence/'.$data['inspection_id'], 'public');

        $evidence = Evidence::create([
            'inspection_id' => $data['inspection_id'],
            'inspection_item_id' => $data['inspection_item_id'] ?? null,
            'finding_id' => $data['finding_id'] ?? null,
            'file_path' => $path,
            'latitude' => $data['lat'] ?? null,
            'longitude' => $data['lng'] ?? null,
            'accuracy' => $data['accuracy'] ?? null,
            'captured_at' => now(),
        ]);

        Activity::create([
            'inspection_id' => $evidence->inspection_id,
            'type' => Activity::TYPE_PHOTO_ADDED,
            'description' => 'Evidence photo added.',
            'actor_user_id' => $request->user()?->id,
            'occurred_at' => now(),
        ]);

        return (new EvidenceResource($evidence))->response()->setStatusCode(201);
    }

    public function destroy(Evidence $evidence): JsonResponse
    {
        $this->authorize('write', $evidence->inspection);

        if ($evidence->file_path) {
            \Illuminate\Support\Facades\Storage::disk('public')->delete($evidence->file_path);
        }
        if ($evidence->watermarked_path) {
            \Illuminate\Support\Facades\Storage::disk('public')->delete($evidence->watermarked_path);
        }
        $evidence->delete();

        return response()->json(null, 204);
    }
}
