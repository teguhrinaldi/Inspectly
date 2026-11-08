<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class InspectionItem extends Model
{
    use HasFactory;

    public const RESULT_PASS = 'pass';

    public const RESULT_FAIL = 'fail';

    public const RESULT_NA = 'na';

    protected $fillable = [
        'inspection_id',
        'template_checklist_item_id',
        'label',
        'result',
        'note',
        'sort_order',
    ];

    public function inspection(): BelongsTo
    {
        return $this->belongsTo(Inspection::class);
    }

    public function templateChecklistItem(): BelongsTo
    {
        // Includes items since removed from the template (help text etc.).
        return $this->belongsTo(TemplateChecklistItem::class)->withTrashed();
    }

    public function findings(): HasMany
    {
        return $this->hasMany(Finding::class);
    }

    public function evidence(): HasMany
    {
        return $this->hasMany(Evidence::class);
    }
}
