<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\SignatureStoreRequest;
use App\Http\Resources\SignatureResource;
use App\Models\Activity;
use App\Models\Inspection;
use App\Models\Signature;
use Illuminate\Http\JsonResponse;

class SignatureController extends Controller
{
    public function store(SignatureStoreRequest $request): JsonResponse
    {
        $data = $request->validated();
        $this->authorize('write', Inspection::findOrFail($data['inspection_id']));

        $path = $request->file('file')->store('signatures/'.$data['inspection_id'], 'public');

        $signature = Signature::create([
            'inspection_id' => $data['inspection_id'],
            'type' => $data['type'],
            'signer_name' => $data['signer_name'],
            'file_path' => $path,
            'signed_at' => now(),
        ]);

        Activity::create([
            'inspection_id' => $signature->inspection_id,
            'type' => Activity::TYPE_SIGNATURE_CAPTURED,
            'description' => sprintf('%s signature captured (%s).', ucfirst($signature->type), $signature->signer_name),
            'actor_user_id' => $request->user()?->id,
            'occurred_at' => now(),
        ]);

        return (new SignatureResource($signature))->response()->setStatusCode(201);
    }
}
