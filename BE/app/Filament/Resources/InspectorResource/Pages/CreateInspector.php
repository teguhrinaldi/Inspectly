<?php

namespace App\Filament\Resources\InspectorResource\Pages;

use App\Filament\Resources\InspectorResource;
use App\Models\Inspector;
use App\Models\User;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class CreateInspector extends CreateRecord
{
    protected static string $resource = InspectorResource::class;

    protected function handleRecordCreation(array $data): Model
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
                'role' => User::ROLE_INSPECTOR,
                'phone' => $data['phone'] ?? null,
                'status' => $data['status'] ?? 'active',
                'email_verified_at' => now(),
            ]);

            return Inspector::create([
                'user_id' => $user->id,
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'] ?? null,
                'status' => $data['status'] ?? 'active',
            ]);
        });
    }
}
