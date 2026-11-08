<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Activity extends Model
{
    use HasFactory;

    public const TYPE_STARTED = 'started';

    public const TYPE_CHECKLIST_UPDATED = 'checklist_updated';

    public const TYPE_FINDING_ADDED = 'finding_added';

    public const TYPE_PHOTO_ADDED = 'photo_added';

    public const TYPE_SIGNATURE_CAPTURED = 'signature_captured';

    public const TYPE_COMPLETED = 'completed';

    public const TYPE_REPORT_GENERATED = 'report_generated';

    protected $fillable = [
        'inspection_id',
        'type',
        'description',
        'actor_user_id',
        'occurred_at',
    ];

    protected $casts = [
        'occurred_at' => 'datetime',
    ];

    public function inspection(): BelongsTo
    {
        return $this->belongsTo(Inspection::class);
    }

    public function actor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'actor_user_id');
    }
}
