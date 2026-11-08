<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Finding;
use App\Models\Inspection;
use App\Models\InspectionItem;
use App\Models\InspectionTemplate;
use App\Models\Site;
use App\Models\TemplateChecklistItem;
use App\Models\TemplateSection;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SiteComparisonTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Small, controlled fixture (architecture.md §7): a template with three
     * checklist items A/B/C. The previous completed inspection has open
     * findings on A and B. The current completed inspection has open
     * findings on A and C. Expected classification:
     *   A -> STILL_OPEN (open in both)
     *   B -> RESOLVED   (open previously, absent now)
     *   C -> NEW        (absent previously, present now)
     */
    public function test_comparison_classifies_still_open_resolved_and_new_findings(): void
    {
        $inspector = User::factory()->inspector()->create();
        $customer = Customer::factory()->create();
        $site = Site::factory()->create(['customer_id' => $customer->id]);
        $template = InspectionTemplate::factory()->create();
        $section = TemplateSection::factory()->create(['template_id' => $template->id]);

        $checklistA = TemplateChecklistItem::factory()->create(['section_id' => $section->id, 'label' => 'Item A']);
        $checklistB = TemplateChecklistItem::factory()->create(['section_id' => $section->id, 'label' => 'Item B']);
        $checklistC = TemplateChecklistItem::factory()->create(['section_id' => $section->id, 'label' => 'Item C']);

        // --- Previous completed inspection: findings on A and B ---
        $previous = Inspection::factory()->completed()->create([
            'template_id' => $template->id,
            'customer_id' => $customer->id,
            'site_id' => $site->id,
            'inspector_id' => $inspector->id,
            'completed_at' => now()->subDays(30),
        ]);

        $prevItemA = InspectionItem::factory()->create([
            'inspection_id' => $previous->id, 'template_checklist_item_id' => $checklistA->id, 'label' => 'Item A', 'result' => 'fail',
        ]);
        $prevItemB = InspectionItem::factory()->create([
            'inspection_id' => $previous->id, 'template_checklist_item_id' => $checklistB->id, 'label' => 'Item B', 'result' => 'fail',
        ]);
        InspectionItem::factory()->create([
            'inspection_id' => $previous->id, 'template_checklist_item_id' => $checklistC->id, 'label' => 'Item C', 'result' => 'pass',
        ]);

        Finding::factory()->create([
            'inspection_id' => $previous->id, 'inspection_item_id' => $prevItemA->id,
            'title' => 'Finding A', 'severity' => 'high', 'status' => Finding::STATUS_OPEN,
        ]);
        Finding::factory()->create([
            'inspection_id' => $previous->id, 'inspection_item_id' => $prevItemB->id,
            'title' => 'Finding B', 'severity' => 'medium', 'status' => Finding::STATUS_OPEN,
        ]);

        // --- Current completed inspection: findings on A (still) and C (new) ---
        $current = Inspection::factory()->completed()->create([
            'template_id' => $template->id,
            'customer_id' => $customer->id,
            'site_id' => $site->id,
            'inspector_id' => $inspector->id,
            'completed_at' => now(),
        ]);

        $curItemA = InspectionItem::factory()->create([
            'inspection_id' => $current->id, 'template_checklist_item_id' => $checklistA->id, 'label' => 'Item A', 'result' => 'fail',
        ]);
        InspectionItem::factory()->create([
            'inspection_id' => $current->id, 'template_checklist_item_id' => $checklistB->id, 'label' => 'Item B', 'result' => 'pass',
        ]);
        $curItemC = InspectionItem::factory()->create([
            'inspection_id' => $current->id, 'template_checklist_item_id' => $checklistC->id, 'label' => 'Item C', 'result' => 'fail',
        ]);

        Finding::factory()->create([
            'inspection_id' => $current->id, 'inspection_item_id' => $curItemA->id,
            'title' => 'Finding A', 'severity' => 'high', 'status' => Finding::STATUS_OPEN,
        ]);
        Finding::factory()->create([
            'inspection_id' => $current->id, 'inspection_item_id' => $curItemC->id,
            'title' => 'Finding C', 'severity' => 'critical', 'status' => Finding::STATUS_OPEN,
        ]);

        Sanctum::actingAs($inspector);

        $response = $this->getJson("/api/sites/{$site->id}/comparison?inspection_id={$current->id}");

        $response->assertOk()
            ->assertJsonPath('has_previous', true)
            ->assertJsonPath('previous_inspection_id', $previous->id);

        $comparison = $response->json('comparison');
        $this->assertCount(3, $comparison);

        $byTitle = collect($comparison)->keyBy(function ($row) {
            return $row['finding']['title'] ?? $row['previous_finding']['title'];
        });

        $this->assertSame('STILL_OPEN', $byTitle['Finding A']['classification']);
        $this->assertSame('RESOLVED', $byTitle['Finding B']['classification']);
        $this->assertSame('NEW', $byTitle['Finding C']['classification']);
    }

    public function test_in_progress_follow_up_matches_unlinked_finding_by_title(): void
    {
        $inspector = User::factory()->inspector()->create();
        $customer = Customer::factory()->create();
        $site = Site::factory()->create(['customer_id' => $customer->id]);
        $template = InspectionTemplate::factory()->create();
        $section = TemplateSection::factory()->create(['template_id' => $template->id]);
        $checklist = TemplateChecklistItem::factory()->create(['section_id' => $section->id, 'label' => 'Plumbing']);

        $previous = Inspection::factory()->completed()->create([
            'template_id' => $template->id, 'customer_id' => $customer->id, 'site_id' => $site->id,
            'inspector_id' => $inspector->id, 'completed_at' => now()->subDay(),
        ]);
        $prevItem = InspectionItem::factory()->create([
            'inspection_id' => $previous->id, 'template_checklist_item_id' => $checklist->id, 'label' => 'Plumbing', 'result' => 'fail',
        ]);
        Finding::factory()->create([
            'inspection_id' => $previous->id, 'inspection_item_id' => $prevItem->id,
            'title' => 'Leaking Pipe', 'severity' => 'medium', 'status' => Finding::STATUS_OPEN,
        ]);

        $current = Inspection::factory()->create([
            'template_id' => $template->id, 'customer_id' => $customer->id, 'site_id' => $site->id,
            'inspector_id' => $inspector->id, 'status' => Inspection::STATUS_IN_PROGRESS, 'completed_at' => null,
        ]);
        Finding::factory()->create([
            'inspection_id' => $current->id, 'inspection_item_id' => null,
            'title' => 'leaking pipe ', 'severity' => 'medium', 'status' => Finding::STATUS_OPEN,
            'location' => 'Building B · Floor 1',
        ]);

        Sanctum::actingAs($inspector);

        $response = $this->getJson("/api/sites/{$site->id}/comparison?inspection_id={$current->id}");

        $response->assertOk()->assertJsonPath('previous_inspection_id', $previous->id);
        $this->assertCount(1, $response->json('comparison'));
        $response->assertJsonPath('comparison.0.classification', 'STILL_OPEN')
            ->assertJsonPath('comparison.0.finding.location', 'Building B · Floor 1');
    }

    public function test_comparison_returns_no_previous_when_none_exists(): void
    {
        $inspector = User::factory()->inspector()->create();
        $customer = Customer::factory()->create();
        $site = Site::factory()->create(['customer_id' => $customer->id]);
        $inspection = Inspection::factory()->completed()->create([
            'customer_id' => $customer->id,
            'site_id' => $site->id,
            'inspector_id' => $inspector->id,
        ]);

        Sanctum::actingAs($inspector);

        $response = $this->getJson("/api/sites/{$site->id}/comparison?inspection_id={$inspection->id}");

        $response->assertOk()
            ->assertJsonPath('has_previous', false)
            ->assertJsonPath('comparison', []);
    }
}
