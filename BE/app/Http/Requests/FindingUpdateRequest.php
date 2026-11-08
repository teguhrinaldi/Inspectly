<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class FindingUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'inspection_item_id' => ['nullable', 'integer', Rule::exists('inspection_items', 'id')->where('inspection_id', $this->route('finding')?->inspection_id)],
            'title' => ['sometimes', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'severity' => ['sometimes', Rule::in(['critical', 'high', 'medium', 'low'])],
            'recommendation' => ['nullable', 'string'],
            'location' => ['nullable', 'string', 'max:255'],
            'status' => ['sometimes', Rule::in(['open', 'resolved'])],
        ];
    }
}
