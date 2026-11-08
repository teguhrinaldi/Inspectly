<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Evidence extends Model
{
    use HasFactory;

    protected $table = 'evidence';

    protected $fillable = [
        'inspection_id',
        'inspection_item_id',
        'finding_id',
        'file_path',
        'watermarked_path',
        'latitude',
        'longitude',
        'captured_at',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'captured_at' => 'datetime',
    ];

    public function inspection(): BelongsTo
    {
        return $this->belongsTo(Inspection::class);
    }

    public function inspectionItem(): BelongsTo
    {
        return $this->belongsTo(InspectionItem::class);
    }

    public function finding(): BelongsTo
    {
        return $this->belongsTo(Finding::class);
    }
}
