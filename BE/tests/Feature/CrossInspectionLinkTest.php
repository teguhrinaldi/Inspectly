<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Finding;
use App\Models\Inspection;
use App\Models\InspectionItem;
use App\Models\InspectionTemplate;
use App\Models\Site;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/** QC-021: items/findings referenced in a request must belong to that inspection. */
class CrossInspectionLinkTest extends TestCase
{
    use RefreshDatabase;

    private function inspection(User $inspector): Inspection
    {
        $customer = Customer::factory()->create();

        return Inspection::factory()->create([
            'template_id' => InspectionTemplate::factory()->create()->id,
            'customer_id' => $customer->id,
            'site_id' => Site::factory()->create(['customer_id' => $customer->id])->id,
            'inspector_id' => $inspector->id,
            'status' => Inspection::STATUS_IN_PROGRESS,
        ]);
    }

    public function test_evidence_cannot_point_at_another_inspections_item_or_finding(): void
    {
        Storage::fake('public');
        $inspector = User::factory()->inspector()->create();
        Sanctum::actingAs($inspector);
        $mine = $this->inspection($inspector);
        $other = $this->inspection($inspector);
        $otherItem = InspectionItem::factory()->create(['inspection_id' => $other->id]);
        $otherFinding = Finding::factory()->create(['inspection_id' => $other->id]);

        $this->post('/api/evidence', [
            'file' => UploadedFile::fake()->image('a.jpg'),
            'inspection_id' => $mine->id,
            'inspection_item_id' => $otherItem->id,
        ], ['Accept' => 'application/json'])->assertStatus(422)->assertJsonValidationErrors('inspection_item_id');

        $this->post('/api/evidence', [
            'file' => UploadedFile::fake()->image('a.jpg'),
            'inspection_id' => $mine->id,
            'finding_id' => $otherFinding->id,
        ], ['Accept' => 'application/json'])->assertStatus(422)->assertJsonValidationErrors('finding_id');
    }

    public function test_finding_cannot_point_at_another_inspections_item(): void
    {
        $inspector = User::factory()->inspector()->create();
        Sanctum::actingAs($inspector);
        $mine = $this->inspection($inspector);
        $other = $this->inspection($inspector);
        $otherItem = InspectionItem::factory()->create(['inspection_id' => $other->id]);
        $finding = Finding::factory()->create(['inspection_id' => $mine->id]);

        $this->postJson('/api/findings', [
            'inspection_id' => $mine->id,
            'inspection_item_id' => $otherItem->id,
            'title' => 'x',
            'severity' => 'low',
        ])->assertStatus(422)->assertJsonValidationErrors('inspection_item_id');

        $this->putJson("/api/findings/{$finding->id}", [
            'inspection_item_id' => $otherItem->id,
        ])->assertStatus(422)->assertJsonValidationErrors('inspection_item_id');
    }

    public function test_valid_links_are_still_accepted(): void
    {
        Storage::fake('public');
        $inspector = User::factory()->inspector()->create();
        Sanctum::actingAs($inspector);
        $mine = $this->inspection($inspector);
        $item = InspectionItem::factory()->create(['inspection_id' => $mine->id]);

        $this->post('/api/evidence', [
            'file' => UploadedFile::fake()->image('a.jpg'),
            'inspection_id' => $mine->id,
            'inspection_item_id' => $item->id,
        ], ['Accept' => 'application/json'])->assertCreated();
    }
}
