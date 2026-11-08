<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Inspection extends Model
{
    use HasFactory;

    protected static function booted(): void
    {
        // Evidence/signature rows go with the inspection via the database
        // cascade, which fires no model events: delete their files here so
        // they don't stay behind on the public disk (QC-054).
        static::deleting(function (Inspection $inspection) {
            $paths = $inspection->evidence()->pluck('file_path')
                ->merge($inspection->evidence()->pluck('watermarked_path'))
                ->merge($inspection->signatures()->pluck('file_path'))
                ->filter()
                ->all();
            \Illuminate\Support\Facades\Storage::disk('public')->delete($paths);
        });
    }

    public const STATUS_DRAFT = 'draft';

    public const STATUS_SCHEDULED = 'scheduled';

    public const STATUS_IN_PROGRESS = 'in_progress';

    public const STATUS_COMPLETED = 'completed';

    public const RECURRENCE_ONE_TIME = 'one_time';

    public const RECURRENCE_WEEKLY = 'weekly';

    public const RECURRENCE_MONTHLY = 'monthly';

    public const RECURRENCE_QUARTERLY = 'quarterly';

    protected $fillable = [
        'template_id',
        'customer_id',
        'site_id',
        'inspector_id',
        'status',
        'scheduled_at',
        'started_at',
        'completed_at',
        'recurrence',
        'next_due_at',
        'location_lat',
        'location_lng',
        'location_captured_at',
        'pass_percentage',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
        'next_due_at' => 'datetime',
        'location_captured_at' => 'datetime',
        'location_lat' => 'float',
        'location_lng' => 'float',
        'pass_percentage' => 'integer',
    ];

    public function template(): BelongsTo
    {
        return $this->belongsTo(InspectionTemplate::class, 'template_id');
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function site(): BelongsTo
    {
        return $this->belongsTo(Site::class);
    }

    public function inspector(): BelongsTo
    {
        return $this->belongsTo(User::class, 'inspector_id');
    }

    public function items(): HasMany
    {
        return $this->hasMany(InspectionItem::class)->orderBy('sort_order');
    }

    public function findings(): HasMany
    {
        return $this->hasMany(Finding::class);
    }

    public function evidence(): HasMany
    {
        return $this->hasMany(Evidence::class);
    }

    public function signatures(): HasMany
    {
        return $this->hasMany(Signature::class);
    }

    public function activities(): HasMany
    {
        return $this->hasMany(Activity::class)->orderBy('occurred_at');
    }

    /**
     * Number of checklist items that have been recorded (pass, fail or na) —
     * i.e. no longer pending. Deterministic, based purely on recorded results.
     */
    public function completedItemCount(): int
    {
        return $this->items->whereNotNull('result')->count();
    }

    public function totalItemCount(): int
    {
        return $this->items->count();
    }

    /**
     * pass / (pass + fail), excluding N/A from the denominator. Mirrors the
     * Flutter-side `computedPassPercentage` logic exactly (see architecture.md §7 area).
     * Returns null when there is nothing gradable yet (avoids division by zero).
     */
    public function computePassPercentage(): ?int
    {
        $graded = $this->items->whereIn('result', [InspectionItem::RESULT_PASS, InspectionItem::RESULT_FAIL]);

        $total = $graded->count();

        if ($total === 0) {
            return null;
        }

        $passed = $graded->where('result', InspectionItem::RESULT_PASS)->count();

        return (int) round(($passed / $total) * 100);
    }

    /** Points deducted from 100 per finding, by severity. */
    public const SEVERITY_DEDUCTION = ['critical' => 8, 'high' => 5, 'medium' => 2, 'low' => 1];

    /**
     * Overall compliance: 100 minus the severity deductions of this
     * inspection's findings, never below 0. Mirrors RiskBreakdown in the app.
     */
    public function complianceScore(): int
    {
        $deduction = $this->findings->sum(fn (Finding $f) => self::SEVERITY_DEDUCTION[$f->severity] ?? 0);

        return max(0, 100 - $deduction);
    }

    /**
     * Item-level buckets: failed items carrying a critical/high finding are
     * "fail", other failed items "attention".
     *
     * @return array{pass: int, attention: int, fail: int}
     */
    public function riskBuckets(): array
    {
        $serious = $this->findings
            ->whereIn('severity', ['critical', 'high'])
            ->pluck('inspection_item_id')
            ->filter()
            ->unique();
        $failed = $this->items->where('result', InspectionItem::RESULT_FAIL);
        $fail = $failed->whereIn('id', $serious)->count();

        return [
            'pass' => $this->items->where('result', InspectionItem::RESULT_PASS)->count(),
            'attention' => $failed->count() - $fail,
            'fail' => $fail,
        ];
    }
}
