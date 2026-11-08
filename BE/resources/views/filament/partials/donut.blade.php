@php
    // Segments are proportional to the checklist buckets of the inspection;
    // the centre shows its overall compliance score.
    $segments = [
        ['value' => $pass, 'from' => '#22C3D6', 'to' => '#12A36B', 'id' => 'pass'],
        ['value' => $attention, 'from' => '#FFB23E', 'to' => '#F07A12', 'id' => 'attention'],
        ['value' => $fail, 'from' => '#FF6B5B', 'to' => '#E02D2D', 'id' => 'fail'],
    ];
    $total = max(1, $pass + $attention + $fail);
    $r = 70;
    $circumference = 2 * M_PI * $r;
    $gap = ($pass + $attention + $fail) > 1 ? 6 : 0;
    $offset = 0;
@endphp
<svg viewBox="0 0 180 180" width="180" height="180" role="img" aria-label="Overall compliance {{ $rate }} percent">
    <defs>
        @foreach ($segments as $s)
            <linearGradient id="insp-g-{{ $s['id'] }}" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0" stop-color="{{ $s['from'] }}"/>
                <stop offset="1" stop-color="{{ $s['to'] }}"/>
            </linearGradient>
        @endforeach
    </defs>
    <circle cx="90" cy="90" r="{{ $r }}" fill="none" stroke="#EEF3F9" stroke-width="22"/>
    <g transform="rotate(-90 90 90)">
        @foreach ($segments as $s)
            @continue($s['value'] <= 0)
            @php
                $length = $circumference * $s['value'] / $total;
                $visible = max(0, $length - $gap);
            @endphp
            <circle cx="90" cy="90" r="{{ $r }}" fill="none"
                    stroke="url(#insp-g-{{ $s['id'] }})" stroke-width="22"
                    stroke-dasharray="{{ $visible }} {{ $circumference - $visible }}"
                    stroke-dashoffset="{{ -$offset }}"/>
            @php $offset += $length; @endphp
        @endforeach
    </g>
    <circle cx="90" cy="90" r="52" fill="#fff"/>
    <text x="90" y="99" text-anchor="middle" font-family="Inter, sans-serif" font-size="28" font-weight="700" fill="#16244A">{{ $rate }}%</text>
</svg>
