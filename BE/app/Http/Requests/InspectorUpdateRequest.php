<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class InspectorUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $inspector = $this->route('inspector');
        $inspectorId = is_object($inspector) ? $inspector->id : $inspector;

        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'email', 'max:255', Rule::unique('inspectors', 'email')->ignore($inspectorId)],
            'phone' => ['nullable', 'string', 'max:50'],
            'password' => ['sometimes', 'string', 'min:6'],
            'avatar_url' => ['nullable', 'string', 'max:255'],
            'status' => ['sometimes', Rule::in(['active', 'inactive'])],
        ];
    }
}
