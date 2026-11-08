<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TemplateChecklistItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'section_id',
        'label',
        'help_text',
        'requires_evidence',
        'sort_order',
    ];

    protected $casts = [
        'requires_evidence' => 'boolean',
    ];

    public function section(): BelongsTo
    {
        return $this->belongsTo(TemplateSection::class, 'section_id');
    }
}
