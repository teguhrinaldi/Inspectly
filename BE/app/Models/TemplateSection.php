<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TemplateSection extends Model
{
    use HasFactory;

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
