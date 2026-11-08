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

/**
 * QC-024: removing a checklist item from a template must not cut past
 * inspections loose from it (the link keys the previous-inspection
 * comparison and the app requires it).
 */
class TemplateEditKeepsHistoryTest extends TestCase
{
    use RefreshDatabase;

    public function test_removed_template_items_stay_linked_to_past_inspections(): void
    {
        $template = InspectionTemplate::factory()->create();
        $section = TemplateSection::factory()->create(['template_id' => $template->id]);
        $keep = TemplateChecklistItem::factory()->create(['section_id' => $section->id, 'label' => 'Keep']);
        $drop = TemplateChecklistItem::factory()->create(['section_id' => $section->id, 'label' => 'Drop', 'help_text' => 'Check the seal']);
        $customer = Customer::factory()->create();
        $inspection = Inspection::factory()->create([
            'template_id' => $template->id,
            'customer_id' => $customer->id,
            'site_id' => Site::factory()->create(['customer_id' => $customer->id])->id,
            'inspector_id' => User::factory()->inspector()->create()->id,
        ]);
        $used = InspectionItem::factory()->create([
            'inspection_id' => $inspection->id,
            'template_checklist_item_id' => $drop->id,
            'label' => 'Drop',
        ]);
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->putJson("/api/inspection-templates/{$template->id}", [
            'sections' => [[
                'id' => $section->id,
                'title' => $section->title,
                'items' => [['id' => $keep->id, 'label' => 'Keep']],
            ]],
        ])->assertOk()->assertJsonCount(1, 'data.sections.0.items');

        $this->assertSame($drop->id, $used->fresh()->template_checklist_item_id);

        Sanctum::actingAs($inspection->inspector);
        $this->getJson("/api/inspections/{$inspection->id}")
            ->assertOk()
            ->assertJsonPath('data.items.0.template_checklist_item_id', $drop->id)
            ->assertJsonPath('data.items.0.help_text', 'Check the seal');
    }
}
