<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ActivityResource;
use App\Http\Resources\EvidenceResource;
use App\Http\Resources\FindingResource;
use App\Http\Resources\InspectionItemResource;
use App\Http\Resources\SignatureResource;
use App\Models\Activity;
use App\Models\Inspection;
use App\Models\Setting;
use Illuminate\Http\JsonResponse;

class ReportController extends Controller
{
    /**
     * Full compiled JSON for one inspection, consumed by the Flutter app's
     * client-side PDF generator (architecture.md §6). Both demo mode and API
     * mode must produce this same shape, so every relationship a report needs
     * to render (site/customer/inspector context, items, findings, evidence,
     * signatures, activity log) is eagerly loaded and included here.
     */
    public function show(Inspection $inspection): JsonResponse
    {
        $inspection->load([
            'template.sections.checklistItems',
            'customer',
            'site',
            'inspector',
            'items.findings',
            'items.evidence',
            'findings.evidence',
            'evidence',
            'signatures',
        ]);

        Activity::create([
            'inspection_id' => $inspection->id,
            'type' => Activity::TYPE_REPORT_GENERATED,
            'description' => 'Report generated.',
            'actor_user_id' => request()->user()?->id,
            'occurred_at' => now(),
        ]);

        return response()->json([
            'branding' => [
                'company_name' => Setting::valueOf('company_name'),
                'report_footer' => Setting::valueOf('report_footer'),
            ],
            'inspection' => [
                'id' => $inspection->id,
                'status' => $inspection->status,
                'scheduled_at' => $inspection->scheduled_at,
                'started_at' => $inspection->started_at,
                'completed_at' => $inspection->completed_at,
                'recurrence' => $inspection->recurrence,
                'next_due_at' => $inspection->next_due_at,
                'pass_percentage' => $inspection->pass_percentage,
                'completed_item_count' => $inspection->completedItemCount(),
                'total_item_count' => $inspection->totalItemCount(),
                'location_lat' => $inspection->location_lat,
                'location_lng' => $inspection->location_lng,
            ],
            'template' => [
                'id' => $inspection->template->id,
                'name' => $inspection->template->name,
                'category' => $inspection->template->category,
            ],
            'customer' => $inspection->customer,
            'site' => $inspection->site,
            'inspector' => [
                'id' => $inspection->inspector->id,
                'name' => $inspection->inspector->name,
                'email' => $inspection->inspector->email,
                'phone' => $inspection->inspector->phone,
            ],
            'items' => InspectionItemResource::collection($inspection->items),
            'findings' => FindingResource::collection($inspection->findings),
            'evidence' => EvidenceResource::collection($inspection->evidence),
            'signatures' => SignatureResource::collection($inspection->signatures),
            'activities' => ActivityResource::collection($inspection->activities()->with('actor')->get()),
            'generated_at' => now(),
        ]);
    }
}
