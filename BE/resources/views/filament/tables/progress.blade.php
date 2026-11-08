@php
    $record = $getRecord();
    $done = (int) ($record->answered_items_count ?? 0);
    $total = (int) ($record->items_count ?? 0);
    $pct = $total > 0 ? (int) round($done / $total * 100) : 0;
    $tone = $total > 0 && $done === $total ? 'green' : 'blue';
@endphp
<div class="insp-cell-progress">
    <span class="insp-cell-progress-count">{{ $done }} / {{ $total }}</span>
    <span class="insp-progress-row">
        <span class="insp-bar"><span class="fill-{{ $tone }}" style="width: {{ $pct }}%"></span></span>
        <span class="insp-cell-sub">{{ $pct }}%</span>
    </span>
</div>
