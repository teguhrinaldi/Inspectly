<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InspectionItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'inspection_id' => $this->inspection_id,
            'template_checklist_item_id' => $this->template_checklist_item_id,
            'label' => $this->label,
            'help_text' => $this->templateChecklistItem?->help_text,
            'result' => $this->result,
            'note' => $this->note,
            'sort_order' => $this->sort_order,
            'evidence' => EvidenceResource::collection($this->whenLoaded('evidence')),
        ];
    }
}
