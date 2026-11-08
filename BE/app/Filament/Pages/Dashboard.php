<?php

namespace App\Filament\Pages;

use App\Models\Finding;
use App\Models\Inspection;
use App\Support\InspectionStats;
use App\Support\TrendWindow;
use Filament\Pages\Dashboard as BaseDashboard;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;

/**
 * Admin dashboard. Every number is computed from the database:
 * - KPIs and the activity chart come from InspectionStats (current counts,
 *   30-day trends, per-day/week activity);
 * - "open findings" counts the open findings of each site's most recent
 *   inspection (older inspections are superseded);
 * - the risk overview is the most recently completed inspection.
 */
class Dashboard extends BaseDashboard
{
    protected static ?string $navigationIcon = 'heroicon-o-squares-2x2';

    protected static ?int $navigationSort = 1;

    protected static string $view = 'filament.pages.dashboard';

    /** Chart period (a key of InspectionStats::PERIODS), bound to the select on the chart. */
    public string $period = '8w';

    private ?InspectionStats $source = null;

    public function getTitle(): string
    {
        return '';
    }

    public function greeting(): string
    {
        $hour = now()->hour;
        $part = match (true) {
            $hour < 12 => 'morning',
            $hour < 18 => 'afternoon',
            default => 'evening',
        };

        return "Good {$part}, ".(auth()->user()?->name ?? 'Admin');
    }

    private function source(): InspectionStats
    {
        return $this->source ??= new InspectionStats;
    }

    /** @return Collection<int, Inspection> */
    private function inspections(): Collection
    {
        return $this->source()->inspections();
    }

    /** @return Collection<int, Inspection> each site's most recent performed inspection */
    private function latestPerSite(): Collection
    {
        return $this->source()->latestPerSite();
    }

    /**
     * Total / Completed / In Progress / Open Findings, with 30-day trends.
     *
     * @return array<int, array{key: string, label: string, value: int, trend: ?int, icon: string, tone: string}>
     */
    public function stats(): array
    {
        return $this->source()->kpis();
    }

    /** Open findings on each site's most recent performed inspection. */
    public function openFindingsCount(): int
    {
        return $this->source()->openFindings();
    }

    /** @return array{labels: array<int, string>, range: string, series: array<string, array<int, int>>} */
    public function overview(): array
    {
        return $this->source()->overview($this->period);
    }

    /** @return array<string, string> */
    public function periodOptions(): array
    {
        return array_map(fn (array $p) => $p[0], InspectionStats::PERIODS);
    }

    /** @return Collection<int, Inspection> today's and upcoming inspections, soonest first */
    public function recentInspections(): Collection
    {
        $today = now()->startOfDay();

        return $this->inspections()
            ->filter(function (Inspection $i) use ($today) {
                $date = $i->scheduled_at ?? $i->started_at ?? $i->completed_at;

                return $date !== null && $date->gte($today);
            })
            ->sortBy(fn (Inspection $i) => ($i->scheduled_at ?? $i->started_at ?? $i->completed_at)->timestamp)
            ->take(5)
            ->values();
    }

    /**
     * @return array{rate: int, pass: int, attention: int, fail: int, inspection: ?Inspection}
     */
    public function riskOverview(): array
    {
        $latest = Inspection::query()
            ->with(['items', 'findings', 'site'])
            ->where('status', Inspection::STATUS_COMPLETED)
            ->whereNotNull('completed_at')
            ->orderByDesc('completed_at')
            ->first();

        if (! $latest) {
            return ['rate' => 0, 'pass' => 0, 'attention' => 0, 'fail' => 0, 'inspection' => null];
        }

        return ['rate' => $latest->complianceScore(), ...$latest->riskBuckets(), 'inspection' => $latest];
    }

    /** @return Collection<int, Finding> the newest open finding at each site */
    public function recentFindings(): Collection
    {
        return $this->latestPerSite()
            ->sortByDesc(fn (Inspection $i) => TrendWindow::activityDate($i)->timestamp)
            ->map(function (Inspection $i) {
                $finding = $i->findings->where('status', Finding::STATUS_OPEN)->sortByDesc('id')->first();
                $finding?->setRelation('inspection', $i);

                return $finding;
            })
            ->filter()
            ->take(3)
            ->values();
    }

    public function dateLabel(?Carbon $date): string
    {
        if (! $date) {
            return '—';
        }
        $day = match (true) {
            $date->isToday() => 'Today',
            $date->isTomorrow() => 'Tomorrow',
            $date->isYesterday() => 'Yesterday',
            default => $date->format('M j, Y'),
        };

        return $day.' · '.$date->format('H:i');
    }

    public function getWidgets(): array
    {
        return [];
    }
}
