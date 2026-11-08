<?php

namespace App\Support;

use App\Models\Inspection;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;

/**
 * Admin KPIs shared by the dashboard and the Inspections list. Every value is
 * a current count from the database (drafts excluded); trends compare the
 * last 30 days with the 30 before (see TrendWindow), by the date that makes
 * the inspection count: scheduled (total), completed, started (in progress)
 * and performed (needs review).
 */
class InspectionStats
{
    /** @var Collection<int, Inspection>|null */
    private ?Collection $inspections = null;

    /** @return Collection<int, Inspection> */
    public function inspections(): Collection
    {
        return $this->inspections ??= Inspection::query()
            ->with(['site', 'template', 'inspector', 'findings'])
            ->where('status', '!=', Inspection::STATUS_DRAFT)
            ->get();
    }

    /**
     * @return array<int, array{key: string, label: string, value: int, trend: ?int, icon: string, tone: string}>
     */
    public function kpis(): array
    {
        $all = $this->inspections();
        $trend = function (callable $date) use ($all): ?int {
            $count = fn (string $w) => $all->filter(fn (Inspection $i) => TrendWindow::of($date($i)) === $w)->count();

            return TrendWindow::change($count(TrendWindow::LAST), $count(TrendWindow::PREV));
        };
        $status = fn (string $s) => $all->where('status', $s);

        return [
            [
                'key' => 'total',
                'label' => 'Total Inspections',
                'value' => $all->count(),
                'trend' => $trend(fn (Inspection $i) => $i->scheduled_at),
                'icon' => 'heroicon-o-clipboard-document-list',
                'tone' => 'blue',
            ],
            [
                'key' => 'completed',
                'label' => 'Completed',
                'value' => $status(Inspection::STATUS_COMPLETED)->count(),
                'trend' => $trend(fn (Inspection $i) => $i->status === Inspection::STATUS_COMPLETED ? $i->completed_at : null),
                'icon' => 'heroicon-o-check-badge',
                'tone' => 'green',
            ],
            [
                'key' => 'in_progress',
                'label' => 'In Progress',
                'value' => $status(Inspection::STATUS_IN_PROGRESS)->count(),
                'trend' => $trend(fn (Inspection $i) => $i->started_at),
                'icon' => 'heroicon-o-clock',
                'tone' => 'orange',
            ],
            [
                'key' => 'review',
                'label' => 'Needs Review',
                'value' => $status(Inspection::STATUS_REVIEW)->count(),
                'trend' => $trend(fn (Inspection $i) => $i->status === Inspection::STATUS_REVIEW ? TrendWindow::activityDate($i) : null),
                'icon' => 'heroicon-o-exclamation-circle',
                'tone' => 'red',
            ],
        ];
    }

    /** Chart periods: key => [label, bucket count, bucket size in days]. */
    public const PERIODS = [
        '7d' => ['Last 7 days', 7, 1],
        '30d' => ['Last 30 days', 30, 1],
        '8w' => ['Last 8 weeks', 8, 7],
    ];

    /**
     * Activity per day (or week) over [period], ending today:
     * - completed: inspections completed in the bucket,
     * - started: inspections started in the bucket,
     * - review: inspections now waiting for review, by the day they were performed.
     *
     * @return array{labels: array<int, string>, range: string, series: array<string, array<int, int>>}
     */
    public function overview(string $period, ?Carbon $today = null): array
    {
        [, $count, $size] = self::PERIODS[$period] ?? self::PERIODS['8w'];
        $today = ($today ?? Carbon::today())->copy()->startOfDay();
        $first = $today->copy()->subDays($count * $size - 1);

        $bucket = function (?Carbon $at) use ($first, $size, $count): ?int {
            if ($at === null) {
                return null;
            }
            $days = (int) $first->diffInDays($at->copy()->startOfDay(), false);
            $index = intdiv($days, $size);

            return $days >= 0 && $index < $count ? $index : null;
        };

        $series = ['completed' => array_fill(0, $count, 0), 'started' => array_fill(0, $count, 0), 'review' => array_fill(0, $count, 0)];
        foreach ($this->inspections() as $i) {
            if (($b = $bucket($i->completed_at)) !== null) {
                $series['completed'][$b]++;
            }
            if (($b = $bucket($i->started_at)) !== null) {
                $series['started'][$b]++;
            }
            if ($i->status === Inspection::STATUS_REVIEW && ($b = $bucket(TrendWindow::activityDate($i))) !== null) {
                $series['review'][$b]++;
            }
        }

        $labels = [];
        for ($n = 0; $n < $count; $n++) {
            $labels[] = $first->copy()->addDays($n * $size)->format('M j');
        }

        return [
            'labels' => $labels,
            'range' => $first->format('M j').' – '.$today->format('M j, Y'),
            'series' => $series,
        ];
    }
}
