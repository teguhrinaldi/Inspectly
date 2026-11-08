<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FindingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'inspection_id' => $this->inspection_id,
            'inspection_item_id' => $this->inspection_item_id,
            'title' => $this->title,
            'description' => $this->description,
            'severity' => $this->severity,
            'recommendation' => $this->recommendation,
            'location' => $this->location,
            'status' => $this->status,
            'evidence' => EvidenceResource::collection($this->whenLoaded('evidence')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
