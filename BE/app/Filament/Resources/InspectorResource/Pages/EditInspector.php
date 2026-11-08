<?php

namespace App\Filament\Resources\InspectorResource\Pages;

use App\Filament\Resources\InspectorResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class EditInspector extends EditRecord
{
    protected static string $resource = InspectorResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }

    protected function handleRecordUpdate(Model $record, array $data): Model
    {
        return DB::transaction(function () use ($record, $data) {
            $record->update([
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'] ?? null,
                'status' => $data['status'] ?? 'active',
            ]);

            $userAttributes = [
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'] ?? null,
                'status' => $data['status'] ?? 'active',
            ];

            if (filled($data['password'] ?? null)) {
                $userAttributes['password'] = Hash::make($data['password']);
            }

            $record->user?->update($userAttributes);

            return $record;
        });
    }
}
