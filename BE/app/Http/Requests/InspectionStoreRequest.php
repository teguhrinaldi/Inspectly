<?php

namespace App\Http\Requests;

use App\Models\Inspection;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class InspectionStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'template_id' => ['required', 'integer', 'exists:inspection_templates,id'],
            'customer_id' => ['required', 'integer', 'exists:customers,id'],
            'site_id' => ['required', 'integer', 'exists:sites,id'],
            'inspector_id' => ['required', 'integer', 'exists:users,id'],
            'status' => ['sometimes', Rule::in([
                Inspection::STATUS_DRAFT,
                Inspection::STATUS_SCHEDULED,
                Inspection::STATUS_IN_PROGRESS,
                Inspection::STATUS_REVIEW,
                Inspection::STATUS_COMPLETED,
            ])],
            'scheduled_at' => ['nullable', 'date'],
            'recurrence' => ['sometimes', Rule::in([
                Inspection::RECURRENCE_ONE_TIME,
                Inspection::RECURRENCE_WEEKLY,
                Inspection::RECURRENCE_MONTHLY,
                Inspection::RECURRENCE_QUARTERLY,
            ])],
        ];
    }
}
