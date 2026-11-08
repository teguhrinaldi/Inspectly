<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ActivityResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'inspection_id' => $this->inspection_id,
            'type' => $this->type,
            'description' => $this->description,
            'actor_user_id' => $this->actor_user_id,
            'actor_name' => $this->whenLoaded('actor', fn () => $this->actor?->name),
            'occurred_at' => $this->occurred_at,
        ];
    }
}
