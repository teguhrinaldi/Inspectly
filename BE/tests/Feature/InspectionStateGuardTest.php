<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Evidence;
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

/** QC-007: start/complete follow the inspection state machine and are safe to retry. */
class InspectionStateGuardTest extends TestCase
{
    use RefreshDatabase;

    private function inspection(string $status, ?string $result = 'pass', string $recurrence = 'one_time'): Inspection
    {
        $inspector = User::factory()->inspector()->create();
        $customer = Customer::factory()->create();
        $template = InspectionTemplate::factory()->create();
        $section = TemplateSection::factory()->create(['template_id' => $template->id]);
        $inspection = Inspection::factory()->create([
            'template_id' => $template->id,
            'customer_id' => $customer->id,
            'site_id' => Site::factory()->create(['customer_id' => $customer->id])->id,
            'inspector_id' => $inspector->id,
            'status' => $status,
            'recurrence' => $recurrence,
        ]);
        foreach ([0, 1] as $i) {
            $checklistItem = TemplateChecklistItem::factory()->create(['section_id' => $section->id]);
            InspectionItem::factory()->create([
                'inspection_id' => $inspection->id,
                'template_checklist_item_id' => $checklistItem->id,
                'label' => $checklistItem->label,
                'result' => $result,
                'sort_order' => $i,
            ]);
        }
        Sanctum::actingAs($inspector);

        return $inspection->fresh();
    }

    public function test_completing_twice_does_not_schedule_a_second_follow_up(): void
    {
        $inspection = $this->inspection(Inspection::STATUS_IN_PROGRESS, 'pass', Inspection::RECURRENCE_MONTHLY);

        $this->postJson("/api/inspections/{$inspection->id}/complete")->assertOk();
        $this->postJson("/api/inspections/{$inspection->id}/complete")
            ->assertOk()
            ->assertJsonPath('data.status', Inspection::STATUS_COMPLETED);

        $this->assertSame(2, Inspection::count()); // original + one follow-up
        $this->assertSame(1, $inspection->activities()->where('type', 'completed')->count());
    }

    public function test_a_completed_inspection_cannot_be_started_again(): void
    {
        $inspection = $this->inspection(Inspection::STATUS_COMPLETED);

        $this->postJson("/api/inspections/{$inspection->id}/start")->assertStatus(409);

        $this->assertSame(Inspection::STATUS_COMPLETED, $inspection->fresh()->status);
    }

    public function test_starting_an_inspection_in_progress_is_a_no_op(): void
    {
        $inspection = $this->inspection(Inspection::STATUS_IN_PROGRESS);

        $this->postJson("/api/inspections/{$inspection->id}/start")->assertOk();

        $this->assertSame(0, $inspection->activities()->where('type', 'started')->count());
    }

    public function test_complete_requires_every_checklist_item_to_be_answered(): void
    {
        $inspection = $this->inspection(Inspection::STATUS_IN_PROGRESS, null);

        $this->postJson("/api/inspections/{$inspection->id}/complete")
            ->assertStatus(422)
            ->assertJsonValidationErrors('items');

        $this->assertSame(Inspection::STATUS_IN_PROGRESS, $inspection->fresh()->status);
    }

    public function test_inspector_cannot_create_an_inspection_already_completed(): void
    {
        $inspection = $this->inspection(Inspection::STATUS_SCHEDULED);

        $this->postJson('/api/inspections', [
            'template_id' => $inspection->template_id,
            'customer_id' => $inspection->customer_id,
            'site_id' => $inspection->site_id,
            'inspector_id' => $inspection->inspector_id,
            'status' => Inspection::STATUS_COMPLETED,
        ])->assertStatus(422)->assertJsonValidationErrors('status');
    }

    public function test_only_an_inspection_in_progress_can_be_completed(): void
    {
        foreach ([Inspection::STATUS_DRAFT, Inspection::STATUS_SCHEDULED] as $status) {
            $inspection = $this->inspection($status);
            $this->postJson("/api/inspections/{$inspection->id}/complete")->assertStatus(409);
            $this->assertSame($status, $inspection->fresh()->status);
        }
    }

    public function test_items_requiring_evidence_need_a_photo_before_completing(): void
    {
        $inspection = $this->inspection(Inspection::STATUS_IN_PROGRESS);
        $item = $inspection->items()->first();
        $item->templateChecklistItem->update(['requires_evidence' => true]);

        $this->postJson("/api/inspections/{$inspection->id}/complete")
            ->assertStatus(422)
            ->assertJsonValidationErrors('items');

        Evidence::create([
            'inspection_id' => $inspection->id,
            'inspection_item_id' => $item->id,
            'file_path' => 'evidence/x.jpg',
            'captured_at' => now(),
        ]);
        $this->postJson("/api/inspections/{$inspection->id}/complete")->assertOk();
    }

    public function test_a_photo_on_the_items_finding_also_counts_as_evidence(): void
    {
        $inspection = $this->inspection(Inspection::STATUS_IN_PROGRESS);
        $item = $inspection->items()->first();
        $item->templateChecklistItem->update(['requires_evidence' => true]);
        $finding = Finding::factory()->create([
            'inspection_id' => $inspection->id,
            'inspection_item_id' => $item->id,
        ]);
        Evidence::create([
            'inspection_id' => $inspection->id,
            'finding_id' => $finding->id,
            'file_path' => 'evidence/y.jpg',
            'captured_at' => now(),
        ]);

        $this->postJson("/api/inspections/{$inspection->id}/complete")->assertOk();
    }
}
