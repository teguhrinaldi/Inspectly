@php $inspector = $getRecord()->inspector; @endphp
<div class="insp-cell-person">
    @if ($inspector && ($avatar = $inspector->getFilamentAvatarUrl()))
        <img src="{{ $avatar }}" alt="" loading="lazy">
    @else
        <span class="insp-initials">{{ \Illuminate\Support\Str::of($inspector?->name ?? '?')->explode(' ')->map(fn ($p) => mb_substr($p, 0, 1))->take(2)->join('') }}</span>
    @endif
    <span class="insp-cell-text">{{ $inspector?->name ?? '—' }}</span>
</div>
