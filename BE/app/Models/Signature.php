<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Signature extends Model
{
    use HasFactory;

    public const TYPE_INSPECTOR = 'inspector';

    public const TYPE_CUSTOMER = 'customer';

    protected $fillable = [
        'inspection_id',
        'type',
        'signer_name',
        'file_path',
        'signed_at',
    ];

    protected $casts = [
        'signed_at' => 'datetime',
    ];

    public function inspection(): BelongsTo
    {
        return $this->belongsTo(Inspection::class);
    }
}
