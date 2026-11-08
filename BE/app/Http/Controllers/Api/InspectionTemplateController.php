<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\InspectionTemplateStoreRequest;
use App\Http\Requests\InspectionTemplateUpdateRequest;
use App\Http\Resources\InspectionTemplateResource;
use App\Models\InspectionTemplate;
use App\Models\TemplateChecklistItem;
use App\Models\TemplateSection;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class InspectionTemplateController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = InspectionTemplate::query()->with('sections.checklistItems');

        if ($request->filled('category')) {
            $query->where('category', $request->string('category'));
        }

        // `active` is the documented name (docs/api.md, used by the app);
        // `active_only` is kept for existing integrations.
        if ($request->boolean('active') || $request->boolean('active_only')) {
            $query->where('is_active', true);
        }

        $templates = $query->orderBy('name')->paginate($this->perPage($request))->withQueryString();

        return InspectionTemplateResource::collection($templates)->response();
    }

    public function show(InspectionTemplate $inspectionTemplate): JsonResponse
    {
        $inspectionTemplate->load('sections.checklistItems');

        return (new InspectionTemplateResource($inspectionTemplate))->response();
    }

    public function store(InspectionTemplateStoreRequest $request): JsonResponse
    {
        $data = $request->validated();

        $template = DB::transaction(function () use ($data) {
            $template = InspectionTemplate::create([
                'name' => $data['name'],
                'description' => $data['description'] ?? null,
                'category' => $data['category'],
                'is_active' => $data['is_active'] ?? true,
            ]);

            $this->syncSections($template, $data['sections'] ?? []);

            return $template;
        });

        $template->load('sections.checklistItems');

        return (new InspectionTemplateResource($template))->response()->setStatusCode(201);
    }

    public function update(InspectionTemplateUpdateRequest $request, InspectionTemplate $inspectionTemplate): JsonResponse
    {
        $data = $request->validated();

        DB::transaction(function () use ($data, $inspectionTemplate) {
            $inspectionTemplate->update(array_filter([
                'name' => $data['name'] ?? null,
                'description' => $data['description'] ?? $inspectionTemplate->description,
                'category' => $data['category'] ?? null,
                'is_active' => array_key_exists('is_active', $data) ? $data['is_active'] : null,
            ], fn ($v) => $v !== null));

            if (array_key_exists('sections', $data)) {
                $this->syncSections($inspectionTemplate, $data['sections'], replace: true);
            }
        });

        $inspectionTemplate->load('sections.checklistItems');

        return (new InspectionTemplateResource($inspectionTemplate))->response();
    }

    public function destroy(InspectionTemplate $inspectionTemplate): JsonResponse
    {
        if ($inspectionTemplate->inspections()->exists()) {
            return response()->json([
                'message' => 'This template is used by inspections. Deactivate it instead of deleting it.',
            ], 409);
        }

        $inspectionTemplate->delete();

        return response()->json(null, 204);
    }

    /**
     * Create/update sections + checklist items for a template. On update with
     * replace=true, sections/items present in the request are upserted (by id
     * when given) and any existing sections not referenced are removed —
     * historical InspectionItems are unaffected since they store a copied label.
     */
    private function syncSections(InspectionTemplate $template, array $sections, bool $replace = false): void
    {
        $keepSectionIds = [];

        foreach ($sections as $sectionIndex => $sectionData) {
            $section = null;

            if (! empty($sectionData['id'])) {
                $section = TemplateSection::where('template_id', $template->id)->find($sectionData['id']);
            }

            if (! $section) {
                $section = new TemplateSection(['template_id' => $template->id]);
            }

            $section->title = $sectionData['title'];
            $section->sort_order = $sectionData['sort_order'] ?? $sectionIndex;
            $section->template_id = $template->id;
            $section->save();

            $keepSectionIds[] = $section->id;

            $keepItemIds = [];

            foreach ($sectionData['items'] ?? [] as $itemIndex => $itemData) {
                $item = null;

                if (! empty($itemData['id'])) {
                    $item = TemplateChecklistItem::where('section_id', $section->id)->find($itemData['id']);
                }

                if (! $item) {
                    $item = new TemplateChecklistItem(['section_id' => $section->id]);
                }

                $item->label = $itemData['label'];
                $item->help_text = $itemData['help_text'] ?? null;
                $item->requires_evidence = $itemData['requires_evidence'] ?? false;
                $item->sort_order = $itemData['sort_order'] ?? $itemIndex;
                $item->section_id = $section->id;
                $item->save();

                $keepItemIds[] = $item->id;
            }

            if ($replace) {
                TemplateChecklistItem::where('section_id', $section->id)
                    ->whereNotIn('id', $keepItemIds)
                    ->delete();
            }
        }

        if ($replace) {
            TemplateSection::where('template_id', $template->id)
                ->whereNotIn('id', $keepSectionIds)
                ->delete();
        }
    }
}
