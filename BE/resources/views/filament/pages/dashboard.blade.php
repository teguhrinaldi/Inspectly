@php
    $stats = $this->stats();
    $risk = $this->riskOverview();
    $overview = $this->overview();
    $openFindings = $this->openFindingsCount();
    $statusTone = [
        'scheduled' => 'blue', 'in_progress' => 'orange', 'review' => 'coral',
        'completed' => 'green', 'draft' => 'slate',
    ];
    $statusLabel = [
        'scheduled' => 'Scheduled', 'in_progress' => 'In Progress', 'review' => 'Review',
        'completed' => 'Completed', 'draft' => 'Draft',
    ];
    $severityTone = ['critical' => 'red', 'high' => 'orange', 'medium' => 'amber', 'low' => 'green'];
    $chartSeries = [
        ['name' => 'Completed', 'color' => '#16A34A', 'values' => $overview['series']['completed'], 'area' => true],
        ['name' => 'Started', 'color' => '#1677FF', 'values' => $overview['series']['started']],
        ['name' => 'Needs Review', 'color' => '#E02D2D', 'values' => $overview['series']['review']],
    ];
@endphp

<x-filament-panels::page class="insp-dashboard">
    <div class="insp-greeting">
        <div>
            <h1>{{ $this->greeting() }}</h1>
            <p>Here's what's happening with your inspections today.</p>
        </div>
        <label class="insp-period">
            <x-filament::icon icon="heroicon-o-calendar" class="h-4 w-4" />
            <span class="sr-only">Chart period</span>
            <select wire:model.live="period">
                @foreach ($this->periodOptions() as $key => $label)
                    <option value="{{ $key }}">{{ $label }}</option>
                @endforeach
            </select>
            <span class="insp-period-range">{{ $overview['range'] }}</span>
        </label>
    </div>

    @include('filament.partials.kpi-cards', ['stats' => $stats])

    <div class="insp-grid">
        <div class="insp-card insp-overview">
            <div class="insp-card-head">
                <div class="insp-card-title">Inspection Overview</div>
                <ul class="insp-chart-legend">
                    @foreach ($chartSeries as $s)
                        <li><span style="background: {{ $s['color'] }}"></span>{{ $s['name'] }}</li>
                    @endforeach
                </ul>
            </div>
            <div wire:loading.class="opacity-60" wire:target="period">
                @include('filament.partials.line-chart', ['labels' => $overview['labels'], 'series' => $chartSeries])
            </div>
        </div>

        <div class="insp-card insp-recent">
            <div class="insp-card-head">
                <div class="insp-card-title">Recent Inspections</div>
                <a class="insp-link-sm" href="{{ \App\Filament\Resources\InspectionResource::getUrl() }}">View all</a>
            </div>
            @forelse ($this->recentInspections() as $inspection)
                <a class="insp-row" href="{{ \App\Filament\Resources\InspectionResource::getUrl('view', ['record' => $inspection]) }}">
                    @if ($cover = \App\Support\MediaUrl::for($inspection->site?->cover_image_url))
                        <img class="insp-thumb" src="{{ $cover }}" alt="">
                    @else
                        <span class="insp-thumb insp-thumb-icon"><x-filament::icon icon="heroicon-o-building-office-2" class="h-5 w-5" /></span>
                    @endif
                    <span class="insp-row-text">
                        <span class="insp-row-title">{{ $inspection->site?->name }}</span>
                        <span class="insp-row-sub">{{ $inspection->template?->name }}</span>
                    </span>
                    <span class="insp-row-end">
                        <span class="insp-chip tone-{{ $statusTone[$inspection->status] ?? 'slate' }}">{{ $statusLabel[$inspection->status] ?? $inspection->status }}</span>
                        <span class="insp-row-date">{{ $this->dateLabel($inspection->scheduled_at ?? $inspection->started_at ?? $inspection->completed_at) }}</span>
                    </span>
                </a>
            @empty
                <p class="insp-empty">No inspections yet.</p>
            @endforelse
        </div>
    </div>

    <div class="insp-grid insp-grid-even">
        <div class="insp-card insp-risk">
            <div class="insp-card-head">
                <div class="insp-card-title">Inspection Risk Overview</div>
                @if ($risk['inspection'])
                    <span class="insp-card-meta">{{ $risk['inspection']->site?->name }} · {{ $risk['inspection']->completed_at?->format('M j, Y') }}</span>
                @endif
            </div>
            <div class="insp-risk-body">
                <div class="insp-donut">
                    @include('filament.partials.donut', ['rate' => $risk['rate'], 'pass' => $risk['pass'], 'attention' => $risk['attention'], 'fail' => $risk['fail']])
                </div>
                <ul class="insp-legend">
                    <li><span class="dot tone-green"></span>Pass<b>{{ $risk['pass'] }}</b></li>
                    <li><span class="dot tone-orange"></span>Needs Attention<b>{{ $risk['attention'] }}</b></li>
                    <li><span class="dot tone-red"></span>Fail<b>{{ $risk['fail'] }}</b></li>
                </ul>
            </div>
        </div>

        <div class="insp-card insp-findings">
            <div class="insp-card-head">
                <div class="insp-card-title">Recent Findings</div>
                <span class="insp-chip tone-red">{{ $openFindings }} open</span>
            </div>
            @forelse ($this->recentFindings() as $finding)
                <a class="insp-finding" href="{{ \App\Filament\Resources\InspectionResource::getUrl('view', ['record' => $finding->inspection_id]) }}">
                    <span class="insp-finding-icon tone-{{ $severityTone[$finding->severity] ?? 'slate' }}">
                        <x-filament::icon icon="heroicon-o-exclamation-triangle" class="h-4 w-4" />
                    </span>
                    <span class="insp-row-text">
                        <span class="insp-row-title">{{ $finding->title }}</span>
                        <span class="insp-row-sub"><b class="sev-{{ $finding->severity }}">{{ ucfirst($finding->severity) }}</b> · {{ $finding->inspection?->site?->name }}</span>
                    </span>
                    <x-filament::icon icon="heroicon-m-chevron-right" class="h-4 w-4 insp-chevron" />
                </a>
            @empty
                <p class="insp-empty">No open findings.</p>
            @endforelse
        </div>
    </div>
</x-filament-panels::page>
