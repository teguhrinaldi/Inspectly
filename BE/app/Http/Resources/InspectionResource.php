<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InspectionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'template_id' => $this->template_id,
            // Flat, denormalized display fields the Flutter client reads
            // directly (no extra lookups for list/detail rendering) —
            // computed from the relations eagerly loaded by the controller.
            'template_name' => $this->template?->name,
            'customer_id' => $this->customer_id,
            'customer_name' => $this->customer?->name,
            'site_id' => $this->site_id,
            'site_name' => $this->site?->name,
            'site_address' => $this->site?->address,
            'site_cover_image_url' => $this->site?->cover_image_url,
            'inspector_id' => $this->inspector_id,
            'inspector_name' => $this->inspector?->name,
            'inspector_avatar_url' => $this->inspector?->avatar_url,
            'status' => $this->status,
            'scheduled_at' => $this->scheduled_at,
            'started_at' => $this->started_at,
            'completed_at' => $this->completed_at,
            'recurrence' => $this->recurrence,
            'next_due_at' => $this->next_due_at,
            'location_lat' => $this->location_lat,
            'location_lng' => $this->location_lng,
            'location_captured_at' => $this->location_captured_at,
            'pass_percentage' => $this->pass_percentage,
            'completed_item_count' => $this->whenLoaded('items', fn () => $this->completedItemCount()),
            'total_item_count' => $this->whenLoaded('items', fn () => $this->totalItemCount()),
            'template' => new InspectionTemplateResource($this->whenLoaded('template')),
            'customer' => new CustomerResource($this->whenLoaded('customer')),
            'site' => new SiteResource($this->whenLoaded('site')),
            'inspector' => new UserResource($this->whenLoaded('inspector')),
            'items' => InspectionItemResource::collection($this->whenLoaded('items')),
            'findings' => FindingResource::collection($this->whenLoaded('findings')),
            'evidence' => EvidenceResource::collection($this->whenLoaded('evidence')),
            'signatures' => SignatureResource::collection($this->whenLoaded('signatures')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
