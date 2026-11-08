@php
    $status = $getRecord()->status;
    $tone = ['scheduled' => 'blue', 'in_progress' => 'orange', 'review' => 'coral', 'completed' => 'green', 'draft' => 'slate'][$status] ?? 'slate';
    $label = ['scheduled' => 'Scheduled', 'in_progress' => 'In Progress', 'review' => 'Review', 'completed' => 'Completed', 'draft' => 'Draft'][$status] ?? $status;
@endphp
<span class="insp-chip tone-{{ $tone }}">{{ $label }}</span>
