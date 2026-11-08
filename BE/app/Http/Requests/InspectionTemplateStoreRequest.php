<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class InspectionTemplateStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'category' => ['required', Rule::in(['safety', 'property', 'equipment', 'vehicle', 'custom'])],
            'is_active' => ['sometimes', 'boolean'],
            'sections' => ['sometimes', 'array'],
            'sections.*.title' => ['required_with:sections', 'string', 'max:255'],
            'sections.*.sort_order' => ['sometimes', 'integer'],
            'sections.*.items' => ['sometimes', 'array'],
            'sections.*.items.*.label' => ['required_with:sections.*.items', 'string', 'max:255'],
            'sections.*.items.*.help_text' => ['nullable', 'string'],
            'sections.*.items.*.requires_evidence' => ['sometimes', 'boolean'],
            'sections.*.items.*.sort_order' => ['sometimes', 'integer'],
        ];
    }
}
