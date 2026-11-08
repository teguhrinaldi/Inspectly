<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

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
            // Must belong to the same inspection, so evidence can't be
            // attached across inspections.
            'inspection_item_id' => ['nullable', 'integer', Rule::exists('inspection_items', 'id')->where('inspection_id', $this->integer('inspection_id'))],
            'finding_id' => ['nullable', 'integer', Rule::exists('findings', 'id')->where('inspection_id', $this->integer('inspection_id'))],
            'lat' => ['nullable', 'numeric', 'between:-90,90'],
            'lng' => ['nullable', 'numeric', 'between:-180,180'],
        ];
    }
}
