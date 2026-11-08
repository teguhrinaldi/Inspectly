<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\InspectionStoreRequest;
use App\Http\Requests\InspectionUpdateRequest;
use App\Http\Resources\InspectionResource;
use App\Models\Activity;
use App\Models\Inspection;
use App\Models\InspectionItem;
use App\Models\InspectionTemplate;
use App\Models\Setting;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class InspectionController extends Controller
{
    private const EAGER = ['template.sections.checklistItems', 'customer', 'site', 'inspector', 'items.evidence', 'items.templateChecklistItem', 'findings.evidence', 'evidence', 'signatures'];

    public function index(Request $request): JsonResponse
    {
        $query = Inspection::query()->with(['template', 'customer', 'site', 'inspector', 'items.evidence', 'items.templateChecklistItem', 'findings.evidence']);

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        if ($request->filled('site_id')) {
            $query->where('site_id', $request->integer('site_id'));
        }

        if ($request->filled('search')) {
            $search = '%'.$request->string('search').'%';
            $query->where(function ($q) use ($search) {
                $q->whereHas('site', fn ($s) => $s->where('name', 'like', $search))
                    ->orWhereHas('customer', fn ($c) => $c->where('name', 'like', $search))
                    ->orWhereHas('template', fn ($t) => $t->where('name', 'like', $search));
            });
        }

        if ($request->filled('inspector_id')) {
            $query->where('inspector_id', $request->integer('inspector_id'));
        }

        $perPage = $this->perPage($request, 50);
        $inspections = $query->orderByDesc('scheduled_at')->orderByDesc('id')->paginate($perPage)->withQueryString();

        return InspectionResource::collection($inspections)->response();
    }

    public function show(Inspection $inspection): JsonResponse
    {
        $inspection->load(self::EAGER);

        return (new InspectionResource($inspection))->response();
    }

    public function store(InspectionStoreRequest $request): JsonResponse
    {
        $data = $request->validated();

        $inspection = DB::transaction(function () use ($data) {
            $inspection = Inspection::create(array_merge($data, [
                'status' => $data['status'] ?? Inspection::STATUS_SCHEDULED,
                'recurrence' => $data['recurrence'] ?? Setting::valueOf('default_recurrence'),
            ]));

            $this->createItemsFromTemplate($inspection, InspectionTemplate::findOrFail($data['template_id']));

            return $inspection;
        });

        $inspection->load(self::EAGER);

        return (new InspectionResource($inspection))->response()->setStatusCode(201);
    }

    public function update(InspectionUpdateRequest $request, Inspection $inspection): JsonResponse
    {
        $inspection->update($request->validated());
        $inspection->load(self::EAGER);

        return (new InspectionResource($inspection))->response();
    }

    public function start(Request $request, Inspection $inspection): JsonResponse
    {
        $request->validate([
            'location_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'location_lng' => ['nullable', 'numeric', 'between:-180,180'],
        ]);

        $attributes = [
            'status' => Inspection::STATUS_IN_PROGRESS,
            'started_at' => $inspection->started_at ?? now(),
        ];

        if ($request->filled('location_lat') && $request->filled('location_lng')) {
            $attributes['location_lat'] = $request->float('location_lat');
            $attributes['location_lng'] = $request->float('location_lng');
            $attributes['location_captured_at'] = now();
        }

        $inspection->update($attributes);

        Activity::create([
            'inspection_id' => $inspection->id,
            'type' => Activity::TYPE_STARTED,
            'description' => 'Inspection started.',
            'actor_user_id' => $request->user()?->id,
            'occurred_at' => now(),
        ]);

        $inspection->load(self::EAGER);

        return (new InspectionResource($inspection))->response();
    }

    /**
     * Complete an inspection: compute pass_percentage from actually recorded
     * results (pass / (pass + fail), N/A excluded from the denominator — kept
     * consistent with the Flutter-side computedPassPercentage logic), stamp
     * completed_at, flip status, log an activity, and — if this inspection
     * carries a recurrence — schedule the next occurrence.
     *
     * Recurring inspections design: rather than storing a "next due" pointer
     * that some other job has to interpret later, we eagerly create the next
     * Inspection row (status=scheduled) right here so it immediately shows up
     * in dashboards/lists. `next_due_at` is still stored on the completed
     * inspection for display/reporting purposes.
     */
    public function complete(Request $request, Inspection $inspection): JsonResponse
    {
        $inspection->load('items');

        $passPercentage = $inspection->computePassPercentage();

        $completedAt = now();
        $nextDueAt = $this->nextDueAt($inspection->recurrence, $completedAt);

        DB::transaction(function () use ($inspection, $passPercentage, $completedAt, $nextDueAt, $request) {
            $inspection->update([
                'status' => Inspection::STATUS_COMPLETED,
                'completed_at' => $completedAt,
                'pass_percentage' => $passPercentage,
                'next_due_at' => $nextDueAt,
            ]);

            Activity::create([
                'inspection_id' => $inspection->id,
                'type' => Activity::TYPE_COMPLETED,
                'description' => 'Inspection completed.',
                'actor_user_id' => $request->user()?->id,
                'occurred_at' => $completedAt,
            ]);

            if ($nextDueAt !== null) {
                $next = Inspection::create([
                    'template_id' => $inspection->template_id,
                    'customer_id' => $inspection->customer_id,
                    'site_id' => $inspection->site_id,
                    'inspector_id' => $inspection->inspector_id,
                    'status' => Inspection::STATUS_SCHEDULED,
                    'scheduled_at' => $nextDueAt,
                    'recurrence' => $inspection->recurrence,
                ]);

                $this->createItemsFromTemplate($next, InspectionTemplate::findOrFail($inspection->template_id));
            }
        });

        $inspection->load(self::EAGER);

        return (new InspectionResource($inspection))->response();
    }

    private function nextDueAt(string $recurrence, \DateTimeInterface $from): ?\Illuminate\Support\Carbon
    {
        return match ($recurrence) {
            Inspection::RECURRENCE_WEEKLY => \Illuminate\Support\Carbon::parse($from)->addWeek(),
            Inspection::RECURRENCE_MONTHLY => \Illuminate\Support\Carbon::parse($from)->addMonthNoOverflow(),
            Inspection::RECURRENCE_QUARTERLY => \Illuminate\Support\Carbon::parse($from)->addMonthsNoOverflow(3),
            default => null,
        };
    }

    private function createItemsFromTemplate(Inspection $inspection, InspectionTemplate $template): void
    {
        $template->load('sections.checklistItems');

        $sortOrder = 0;

        foreach ($template->sections as $section) {
            foreach ($section->checklistItems as $checklistItem) {
                InspectionItem::create([
                    'inspection_id' => $inspection->id,
                    'template_checklist_item_id' => $checklistItem->id,
                    'label' => $checklistItem->label,
                    'result' => null,
                    'note' => null,
                    'sort_order' => $sortOrder++,
                ]);
            }
        }
    }
}
