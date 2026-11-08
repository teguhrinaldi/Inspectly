<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class SiteUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $siteId = $this->route('site');

        return [
            'customer_id' => ['sometimes', 'integer', 'exists:customers,id'],
            'name' => ['sometimes', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'qr_code' => ['sometimes', 'string', 'max:255', Rule::unique('sites', 'qr_code')->ignore($siteId)],
            'status' => ['sometimes', Rule::in(['active', 'inactive'])],
            'cover_image_url' => ['nullable', 'string', 'max:255'],
        ];
    }
}
