<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TemplateChecklistItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'section_id' => $this->section_id,
            'label' => $this->label,
            'help_text' => $this->help_text,
            'requires_evidence' => $this->requires_evidence,
            'sort_order' => $this->sort_order,
        ];
    }
}
