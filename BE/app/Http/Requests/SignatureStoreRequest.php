<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class SignatureStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'file' => ['required', 'file', 'image', 'max:5120'],
            'inspection_id' => ['required', 'integer', 'exists:inspections,id'],
            'type' => ['required', Rule::in(['inspector', 'customer'])],
            'signer_name' => ['required', 'string', 'max:255'],
        ];
    }
}
