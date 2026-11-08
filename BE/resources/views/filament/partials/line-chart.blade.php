{{--
    Inline SVG line chart (no chart library): $labels (x axis), $series as
    [['name' => .., 'color' => .., 'values' => [..], 'area' => bool], ..].
--}}
@php
    $w = 640; $h = 330; $left = 34; $right = 10; $top = 12; $bottom = 30;
    $n = max(1, count($labels));
    $max = max(1, ...array_map(fn ($s) => max($s['values'] ?: [0]), $series));
    $step = (int) max(1, ceil($max / 4));
    $yMax = $step * 4;
    $x = fn (int $i) => $left + ($n === 1 ? 0 : $i * ($w - $left - $right) / ($n - 1));
    $y = fn (float $v) => $top + ($h - $top - $bottom) * (1 - $v / $yMax);
    $labelEvery = (int) max(1, ceil($n / 8));
@endphp
<svg viewBox="0 0 {{ $w }} {{ $h }}" class="insp-line-chart" role="img" aria-label="{{ collect($series)->pluck('name')->join(', ') }} per period">
    @for ($t = 0; $t <= 4; $t++)
        @php $ty = $y($t * $step); @endphp
        <line x1="{{ $left }}" x2="{{ $w - $right }}" y1="{{ $ty }}" y2="{{ $ty }}" stroke="#E9EEF6" stroke-width="1" @if ($t > 0) stroke-dasharray="3 4" @endif />
        <text x="{{ $left - 10 }}" y="{{ $ty + 4 }}" text-anchor="end" class="insp-axis">{{ $t * $step }}</text>
    @endfor
    @foreach ($labels as $i => $label)
        @if ($i % $labelEvery === 0 && $n - 1 - $i >= $labelEvery / 2 || $i === $n - 1)
            <text x="{{ $x($i) }}" y="{{ $h - 8 }}" text-anchor="{{ $i === 0 ? 'start' : ($i === $n - 1 ? 'end' : 'middle') }}" class="insp-axis">{{ $label }}</text>
        @endif
    @endforeach
    @foreach ($series as $s)
        @php
            $pts = collect($s['values'])->map(fn ($v, $i) => round($x($i), 1).','.round($y($v), 1));
        @endphp
        @if ($s['area'] ?? false)
            <polygon points="{{ round($x(0), 1) }},{{ $y(0) }} {{ $pts->join(' ') }} {{ round($x($n - 1), 1) }},{{ $y(0) }}" fill="{{ $s['color'] }}" fill-opacity=".10" />
        @endif
        <polyline points="{{ $pts->join(' ') }}" fill="none" stroke="{{ $s['color'] }}" stroke-width="2.2" stroke-linejoin="round" stroke-linecap="round" />
        @if ($n <= 14)
            @foreach ($s['values'] as $i => $v)
                <circle cx="{{ round($x($i), 1) }}" cy="{{ round($y($v), 1) }}" r="3.2" fill="#fff" stroke="{{ $s['color'] }}" stroke-width="2"><title>{{ $s['name'] }} · {{ $labels[$i] }}: {{ $v }}</title></circle>
            @endforeach
        @endif
    @endforeach
</svg>
