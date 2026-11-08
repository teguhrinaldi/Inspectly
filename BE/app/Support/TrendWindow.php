<?php

namespace App\Support;

use App\Models\Inspection;
use Illuminate\Support\Carbon;

/**
 * Day-based trend windows shared by the dashboard and the demo seeder:
 * "last" is today and the 29 days before, "prev" the 30 days before that.
 * Future dates belong to neither.
 */
class TrendWindow
{
    public const LAST = 'last';

    public const PREV = 'prev';

    public const OTHER = 'other';

    public static function of(?\DateTimeInterface $at, ?\DateTimeInterface $today = null): string
    {
        if ($at === null) {
            return self::OTHER;
        }
        $today = Carbon::instance($today ?? Carbon::today())->startOfDay();
        $age = (int) Carbon::instance($at)->copy()->startOfDay()->diffInDays($today, false);

        return match (true) {
            $age >= 0 && $age <= 29 => self::LAST,
            $age >= 30 && $age <= 59 => self::PREV,
            default => self::OTHER,
        };
    }

    /** When an inspection happened: completed, else started, else scheduled. */
    public static function activityDate(Inspection $inspection): ?Carbon
    {
        return $inspection->completed_at ?? $inspection->started_at ?? $inspection->scheduled_at;
    }

    /** Relative change in percent, or null when there is nothing to compare. */
    public static function change(int|float $current, int|float $previous): ?int
    {
        if ($previous == 0) {
            return null;
        }

        return (int) round(($current - $previous) / $previous * 100);
    }
}
