<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TemplateSectionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'template_id' => $this->template_id,
            'title' => $this->title,
            'sort_order' => $this->sort_order,
            'items' => TemplateChecklistItemResource::collection($this->whenLoaded('checklistItems')),
        ];
    }
}
