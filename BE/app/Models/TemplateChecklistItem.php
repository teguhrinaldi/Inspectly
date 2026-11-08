<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TemplateChecklistItem extends Model
{
    // Soft-deleted when removed from a template, so past inspections keep
    // their link to the item (QC-024).
    use HasFactory, SoftDeletes;

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
