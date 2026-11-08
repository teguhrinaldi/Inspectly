@php
    $site = $getRecord()->site;
    $cover = \App\Support\MediaUrl::for($site?->cover_image_url);
    // "480 Riverside Dr, New York, NY" -> "New York, NY"
    $parts = array_map('trim', explode(',', (string) $site?->address));
    $place = count($parts) >= 3 ? implode(', ', array_slice($parts, -2)) : ($site?->address ?? '');
@endphp
<div class="insp-cell-site">
    @if ($cover)
        <img src="{{ $cover }}" alt="" loading="lazy">
    @else
        <span class="insp-thumb-icon"><x-filament::icon icon="heroicon-o-building-office-2" class="h-5 w-5" /></span>
    @endif
    <span>
        <span class="insp-cell-title">{{ $site?->name }}</span>
        @if ($place !== '')<span class="insp-cell-sub">{{ $place }}</span>@endif
    </span>
</div>
