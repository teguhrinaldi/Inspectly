<?php

namespace Tests\Feature;

use App\Models\Customer;
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

class InspectionLifecycleTest extends TestCase
{
    use RefreshDatabase;

    private function makeInspectionWithItems(int $itemCount = 4): Inspection
    {
        $inspector = User::factory()->inspector()->create();
        $customer = Customer::factory()->create();
        $site = Site::factory()->create(['customer_id' => $customer->id]);
        $template = InspectionTemplate::factory()->create();
        $section = TemplateSection::factory()->create(['template_id' => $template->id]);

        $inspection = Inspection::factory()->create([
            'template_id' => $template->id,
            'customer_id' => $customer->id,
            'site_id' => $site->id,
            'inspector_id' => $inspector->id,
            'status' => Inspection::STATUS_SCHEDULED,
        ]);

        for ($i = 0; $i < $itemCount; $i++) {
            $checklistItem = TemplateChecklistItem::factory()->create(['section_id' => $section->id]);
            InspectionItem::factory()->create([
                'inspection_id' => $inspection->id,
                'template_checklist_item_id' => $checklistItem->id,
                'label' => $checklistItem->label,
                'result' => null,
                'sort_order' => $i,
            ]);
        }

        return $inspection->fresh();
    }

    public function test_start_transitions_status_and_records_location_and_activity(): void
    {
        $inspection = $this->makeInspectionWithItems();
        Sanctum::actingAs($inspection->inspector);

        $response = $this->postJson("/api/inspections/{$inspection->id}/start", [
            'location_lat' => 40.7712,
            'location_lng' => -73.9542,
        ]);

        $response->assertOk()->assertJsonPath('data.status', Inspection::STATUS_IN_PROGRESS);

        $inspection->refresh();
        $this->assertSame(Inspection::STATUS_IN_PROGRESS, $inspection->status);
        $this->assertNotNull($inspection->started_at);
        $this->assertEquals(40.7712, $inspection->location_lat);
        $this->assertEquals(-73.9542, $inspection->location_lng);

        $this->assertDatabaseHas('activities', [
            'inspection_id' => $inspection->id,
            'type' => 'started',
        ]);
    }

    public function test_checklist_item_update_persists_result_and_logs_activity(): void
    {
        $inspection = $this->makeInspectionWithItems();
        $item = $inspection->items()->first();
        Sanctum::actingAs($inspection->inspector);

        $response = $this->putJson("/api/inspections/{$inspection->id}/items/{$item->id}", [
            'result' => 'fail',
            'note' => 'Needs attention',
        ]);

        $response->assertOk()->assertJsonPath('data.result', 'fail');

        $this->assertDatabaseHas('inspection_items', [
            'id' => $item->id,
            'result' => 'fail',
            'note' => 'Needs attention',
        ]);

        $this->assertDatabaseHas('activities', [
            'inspection_id' => $inspection->id,
            'type' => 'checklist_updated',
        ]);
    }

    public function test_checklist_item_update_rejects_invalid_result(): void
    {
        $inspection = $this->makeInspectionWithItems();
        $item = $inspection->items()->first();
        Sanctum::actingAs($inspection->inspector);

        $response = $this->putJson("/api/inspections/{$inspection->id}/items/{$item->id}", [
            'result' => 'not-a-real-result',
        ]);

        $response->assertStatus(422);
    }

    public function test_complete_computes_pass_percentage_excluding_na(): void
    {
        $inspection = $this->makeInspectionWithItems(4);
        $inspection->update(['status' => Inspection::STATUS_IN_PROGRESS]);
        $items = $inspection->items()->orderBy('sort_order')->get();

        // 2 pass, 1 fail, 1 na -> pass% = 2 / (2+1) = 66.67 -> rounds to 67, NA excluded from denominator.
        $items[0]->update(['result' => 'pass']);
        $items[1]->update(['result' => 'pass']);
        $items[2]->update(['result' => 'fail']);
        $items[3]->update(['result' => 'na']);

        Sanctum::actingAs($inspection->inspector);

        $response = $this->postJson("/api/inspections/{$inspection->id}/complete");

        $response->assertOk()
            ->assertJsonPath('data.status', Inspection::STATUS_COMPLETED)
            ->assertJsonPath('data.pass_percentage', 67);

        $inspection->refresh();
        $this->assertSame(67, $inspection->pass_percentage);
        $this->assertSame(Inspection::STATUS_COMPLETED, $inspection->status);
        $this->assertNotNull($inspection->completed_at);

        $this->assertDatabaseHas('activities', [
            'inspection_id' => $inspection->id,
            'type' => 'completed',
        ]);
    }

    public function test_complete_with_recurrence_schedules_next_inspection(): void
    {
        $inspection = $this->makeInspectionWithItems(2);
        $inspection->update(['recurrence' => Inspection::RECURRENCE_MONTHLY, 'status' => Inspection::STATUS_IN_PROGRESS]);
        $inspection->items->each(fn ($item) => $item->update(['result' => 'pass']));

        Sanctum::actingAs($inspection->inspector);

        $this->postJson("/api/inspections/{$inspection->id}/complete")->assertOk();

        $inspection->refresh();
        $this->assertNotNull($inspection->next_due_at);

        $this->assertDatabaseHas('inspections', [
            'site_id' => $inspection->site_id,
            'template_id' => $inspection->template_id,
            'status' => Inspection::STATUS_SCHEDULED,
            'scheduled_at' => $inspection->next_due_at,
        ]);
    }

    public function test_finding_can_be_created_for_an_inspection_item(): void
    {
        $inspection = $this->makeInspectionWithItems(1);
        $item = $inspection->items()->first();
        Sanctum::actingAs($inspection->inspector);

        $response = $this->postJson('/api/findings', [
            'inspection_id' => $inspection->id,
            'inspection_item_id' => $item->id,
            'title' => 'Cracked exterior signage',
            'severity' => 'low',
            'recommendation' => 'Replace sign panel.',
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.title', 'Cracked exterior signage')
            ->assertJsonPath('data.severity', 'low')
            ->assertJsonPath('data.status', 'open');

        $this->assertDatabaseHas('findings', [
            'inspection_id' => $inspection->id,
            'inspection_item_id' => $item->id,
            'title' => 'Cracked exterior signage',
        ]);

        $this->assertDatabaseHas('activities', [
            'inspection_id' => $inspection->id,
            'type' => 'finding_added',
        ]);
    }

    public function test_finding_creation_rejects_invalid_severity(): void
    {
        $inspection = $this->makeInspectionWithItems(1);
        Sanctum::actingAs($inspection->inspector);

        $response = $this->postJson('/api/findings', [
            'inspection_id' => $inspection->id,
            'title' => 'Something',
            'severity' => 'super-bad',
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors('severity');
    }
}
