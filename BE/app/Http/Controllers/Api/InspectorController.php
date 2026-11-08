<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\InspectorStoreRequest;
use App\Http\Requests\InspectorUpdateRequest;
use App\Http\Resources\InspectorResource;
use App\Models\Inspector;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class InspectorController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Inspector::query();

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        if ($request->filled('search')) {
            $query->where('name', 'like', '%'.$request->string('search').'%');
        }

        $inspectors = $query->orderBy('name')->paginate($this->perPage($request))->withQueryString();

        return InspectorResource::collection($inspectors)->response();
    }

    /**
     * Creates both the auth-capable User (role=inspector) and the linked
     * Inspector profile row in one call, per architecture.md's 1:1 note.
     */
    public function store(InspectorStoreRequest $request): JsonResponse
    {
        $data = $request->validated();

        $inspector = DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password'] ?? Str::random(16)),
                'role' => User::ROLE_INSPECTOR,
                'phone' => $data['phone'] ?? null,
                'avatar_url' => $data['avatar_url'] ?? null,
                'status' => $data['status'] ?? 'active',
            ]);

            return Inspector::create([
                'user_id' => $user->id,
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'] ?? null,
                'avatar_url' => $data['avatar_url'] ?? null,
                'status' => $data['status'] ?? 'active',
            ]);
        });

        return (new InspectorResource($inspector))->response()->setStatusCode(201);
    }

    public function update(InspectorUpdateRequest $request, Inspector $inspector): JsonResponse
    {
        $data = $request->validated();

        DB::transaction(function () use ($data, $inspector) {
            $inspector->update($data);

            $userAttributes = array_intersect_key($data, array_flip(['name', 'email', 'phone', 'avatar_url', 'status']));

            if (! empty($data['password'])) {
                $userAttributes['password'] = Hash::make($data['password']);
            }

            if (! empty($userAttributes) && $inspector->user) {
                $inspector->user->update($userAttributes);
            }
        });

        return (new InspectorResource($inspector))->response();
    }
}
