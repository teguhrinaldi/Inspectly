<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class EvidenceResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'inspection_id' => $this->inspection_id,
            'inspection_item_id' => $this->inspection_item_id,
            'finding_id' => $this->finding_id,
            'file_path' => $this->file_path,
            'file_url' => $this->file_path ? Storage::disk('public')->url($this->file_path) : null,
            'watermarked_path' => $this->watermarked_path,
            'watermarked_url' => $this->watermarked_path ? Storage::disk('public')->url($this->watermarked_path) : null,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'accuracy' => $this->accuracy,
            'captured_at' => $this->captured_at,
        ];
    }
}
