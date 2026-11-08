{{-- Four KPI cards (InspectionStats::kpis()), shared by the dashboard and the Inspections list. --}}
<div class="insp-stats">
    @foreach ($stats as $stat)
        <div class="insp-card insp-stat">
            <span class="insp-stat-icon solid-{{ $stat['tone'] }}">
                <x-filament::icon :icon="$stat['icon']" class="h-6 w-6" />
            </span>
            <div class="insp-stat-body">
                <div class="insp-stat-label">{{ $stat['label'] }}</div>
                <div class="insp-stat-value">{{ number_format($stat['value']) }}</div>
                @if ($stat['trend'] !== null)
                    <div @class(['insp-trend', 'is-up' => $stat['trend'] >= 0, 'is-down' => $stat['trend'] < 0]) title="Last 30 days vs the 30 days before">
                        <x-filament::icon :icon="$stat['trend'] >= 0 ? 'heroicon-m-arrow-up' : 'heroicon-m-arrow-down'" class="h-3.5 w-3.5" />
                        {{ abs($stat['trend']) }}%
                        <span>vs. prior 30 days</span>
                    </div>
                @else
                    <div class="insp-trend is-flat" title="Nothing in the prior 30 days to compare with">No prior-period data</div>
                @endif
            </div>
        </div>
    @endforeach
</div>
