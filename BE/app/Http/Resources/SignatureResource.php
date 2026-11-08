<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class SignatureResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'inspection_id' => $this->inspection_id,
            'type' => $this->type,
            'signer_name' => $this->signer_name,
            'file_path' => $this->file_path,
            'file_url' => $this->file_path ? Storage::disk('public')->url($this->file_path) : null,
            'signed_at' => $this->signed_at,
        ];
    }
}
