<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\SiteStoreRequest;
use App\Http\Requests\SiteUpdateRequest;
use App\Http\Resources\FindingResource;
use App\Http\Resources\InspectionResource;
use App\Http\Resources\SiteResource;
use App\Models\Finding;
use App\Models\Inspection;
use App\Models\Site;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;

class SiteController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Site::query()->with('customer');

        if ($request->filled('customer_id')) {
            $query->where('customer_id', $request->integer('customer_id'));
        }

        if ($request->filled('search')) {
            $query->where('name', 'like', '%'.$request->string('search').'%');
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        if ($request->filled('qr_code')) {
            $query->where('qr_code', $request->string('qr_code'));
        }

        $sites = $query->orderBy('name')->paginate($this->perPage($request))->withQueryString();

        return SiteResource::collection($sites)->response();
    }

    public function show(Site $site): JsonResponse
    {
        $site->load('customer');

        return (new SiteResource($site))->response();
    }

    public function store(SiteStoreRequest $request): JsonResponse
    {
        $site = Site::create($request->validated());
        $site->load('customer');

        return (new SiteResource($site))->response()->setStatusCode(201);
    }

    public function update(SiteUpdateRequest $request, Site $site): JsonResponse
    {
        $site->update($request->validated());
        $site->load('customer');

        return (new SiteResource($site))->response();
    }

    /**
     * Real, chronologically ordered inspection history for a site.
     */
    public function history(Request $request, Site $site): JsonResponse
    {
        $inspections = Inspection::query()
            ->where('site_id', $site->id)
            ->where('status', Inspection::STATUS_COMPLETED)
            ->with(['template', 'inspector'])
            ->orderByDesc('scheduled_at')
            ->orderByDesc('completed_at')
            ->paginate($this->perPage($request));

        return InspectionResource::collection($inspections)->response();
    }

    /**
     * Deterministic previous-inspection comparison (architecture.md §7).
     *
     * For the given (current) inspection, find the most recent previously
     * COMPLETED inspection at the same site using the SAME template. Findings
     * are matched by the template_checklist_item_id of their parent
     * InspectionItem (plus exact normalized title when one item carries several
     * findings or a finding has no item) — no fuzzy matching:
     *   - open in previous AND present in current -> STILL_OPEN
     *   - open in previous, absent in current      -> RESOLVED
     *   - present in current, absent in previous    -> NEW
     */
    public function comparison(Request $request, Site $site): JsonResponse
    {
        $request->validate([
            'inspection_id' => ['required', 'integer', 'exists:inspections,id'],
        ]);

        $current = Inspection::with(['items', 'findings.inspectionItem'])
            ->where('site_id', $site->id)
            ->findOrFail($request->integer('inspection_id'));

        $previous = Inspection::with(['items', 'findings.inspectionItem'])
            ->where('site_id', $site->id)
            ->where('template_id', $current->template_id)
            ->where('status', Inspection::STATUS_COMPLETED)
            ->where('id', '!=', $current->id)
            ->where('completed_at', '<', $current->completed_at ?? now())
            ->orderByDesc('completed_at')
            ->orderByDesc('id')
            ->first();

        if (! $previous) {
            return response()->json([
                'has_previous' => false,
                'previous_inspection_id' => null,
                'comparison' => [],
            ]);
        }

        $previousOpenByKey = $this->keyFindings($previous);
        $currentByKey = $this->keyFindings($current);

        // A finding logged without a checklist item still continues an
        // earlier finding with the same title.
        foreach ($currentByKey->keys() as $key) {
            if (! str_starts_with($key, 'finding:') || $previousOpenByKey->has($key)) {
                continue;
            }
            $title = substr($key, strlen('finding:'));
            $match = $previousOpenByKey->search(
                fn (Finding $f, string $k) => ! $currentByKey->has($k) && $this->normalizeTitle($f) === $title
            );
            if ($match !== false) {
                $currentByKey->put($match, $currentByKey->pull($key));
            }
        }

        $results = [];

        foreach ($currentByKey as $key => $finding) {
            $results[] = [
                'classification' => $previousOpenByKey->has($key) ? 'STILL_OPEN' : 'NEW',
                'finding' => new FindingResource($finding),
                'previous_finding' => $previousOpenByKey->has($key)
                    ? new FindingResource($previousOpenByKey->get($key))
                    : null,
            ];
        }

        foreach ($previousOpenByKey as $key => $previousFinding) {
            if (! $currentByKey->has($key)) {
                $results[] = [
                    'classification' => 'RESOLVED',
                    'finding' => null,
                    'previous_finding' => new FindingResource($previousFinding),
                ];
            }
        }

        return response()->json([
            'has_previous' => true,
            'previous_inspection_id' => $previous->id,
            'previous_completed_at' => $previous->completed_at,
            'comparison' => $results,
        ]);
    }

    /**
     * Open findings keyed by their checklist item; a second finding on the
     * same item is keyed by item + title, and one without an item by title.
     *
     * @return Collection<string, Finding>
     */
    private function keyFindings(Inspection $inspection): Collection
    {
        $keyed = collect();
        foreach ($inspection->findings->where('status', Finding::STATUS_OPEN) as $finding) {
            $itemKey = $finding->inspectionItem?->template_checklist_item_id;
            $title = $this->normalizeTitle($finding);
            $key = match (true) {
                $itemKey === null => "finding:{$title}",
                $keyed->has((string) $itemKey) => "{$itemKey}:{$title}",
                default => (string) $itemKey,
            };
            $keyed->put($key, $finding);
        }

        return $keyed;
    }

    private function normalizeTitle(Finding $finding): string
    {
        return mb_strtolower(trim($finding->title));
    }
}
