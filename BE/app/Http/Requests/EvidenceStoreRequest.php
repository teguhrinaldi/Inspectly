<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class EvidenceStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'file' => ['required', 'file', 'image', 'max:10240'],
            'inspection_id' => ['required', 'integer', 'exists:inspections,id'],
            'inspection_item_id' => ['nullable', 'integer', 'exists:inspection_items,id'],
            'finding_id' => ['nullable', 'integer', 'exists:findings,id'],
            'lat' => ['nullable', 'numeric', 'between:-90,90'],
            'lng' => ['nullable', 'numeric', 'between:-180,180'],
        ];
    }
}
