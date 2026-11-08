<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TemplateSection extends Model
{
    // Soft-deleted when removed from a template, so past inspections keep
    // their link to the item (QC-024).
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'template_id',
        'title',
        'sort_order',
    ];

    public function template(): BelongsTo
    {
        return $this->belongsTo(InspectionTemplate::class, 'template_id');
    }

    public function checklistItems(): HasMany
    {
        return $this->hasMany(TemplateChecklistItem::class, 'section_id')->orderBy('sort_order');
    }
}
