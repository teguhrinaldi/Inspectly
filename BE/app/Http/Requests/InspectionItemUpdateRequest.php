<?php

namespace App\Http\Requests;

use App\Models\InspectionItem;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class InspectionItemUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'result' => ['nullable', Rule::in([
                InspectionItem::RESULT_PASS,
                InspectionItem::RESULT_FAIL,
                InspectionItem::RESULT_NA,
            ])],
            'note' => ['nullable', 'string'],
        ];
    }
}
