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
            // The email is copied to the login (users) as well, so it must be
            // free there too; otherwise the update fails with a 500.
            'email' => [
                'sometimes', 'email', 'max:255',
                Rule::unique('inspectors', 'email')->ignore($inspectorId),
                Rule::unique('users', 'email')->ignore(is_object($inspector) ? $inspector->user_id : null),
            ],
            'phone' => ['nullable', 'string', 'max:50'],
            'password' => ['sometimes', 'string', 'min:8'], // QC-022
            'avatar_url' => ['nullable', 'string', 'max:255'],
            'status' => ['sometimes', Rule::in(['active', 'inactive'])],
        ];
    }
}
