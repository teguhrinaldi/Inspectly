<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Evidence;
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

/**
 * QC-001: every inspector may READ every inspection, but only the assigned
 * inspector (or an admin) may change it. One IDOR test per write action.
 */
class InspectionOwnershipTest extends TestCase
{
    use RefreshDatabase;

    private User $owner;

    private User $other;

    private Inspection $inspection;

    private InspectionItem $item;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');
        $this->owner = User::factory()->inspector()->create();
        $this->other = User::factory()->inspector()->create();
        $customer = Customer::factory()->create();
        $this->inspection = Inspection::factory()->create([
            'template_id' => InspectionTemplate::factory()->create()->id,
            'customer_id' => $customer->id,
            'site_id' => Site::factory()->create(['customer_id' => $customer->id])->id,
            'inspector_id' => $this->owner->id,
            'status' => Inspection::STATUS_IN_PROGRESS,
        ]);
        $this->item = InspectionItem::factory()->create([
            'inspection_id' => $this->inspection->id,
            'result' => 'pass',
        ]);
    }

    private function asOther(): void
    {
        Sanctum::actingAs($this->other);
    }

    public function test_other_inspectors_can_still_read(): void
    {
        $this->asOther();
        $this->getJson("/api/inspections/{$this->inspection->id}")->assertOk();
        $this->getJson('/api/inspections')->assertOk()->assertJsonPath('data.0.id', $this->inspection->id);
    }

    public function test_start_is_owner_only(): void
    {
        $this->inspection->update(['status' => Inspection::STATUS_SCHEDULED]);
        $this->asOther();
        $this->postJson("/api/inspections/{$this->inspection->id}/start")->assertForbidden();
        $this->assertSame(Inspection::STATUS_SCHEDULED, $this->inspection->fresh()->status);
    }

    public function test_complete_is_owner_only(): void
    {
        $this->asOther();
        $this->postJson("/api/inspections/{$this->inspection->id}/complete")->assertForbidden();
        $this->assertSame(Inspection::STATUS_IN_PROGRESS, $this->inspection->fresh()->status);
    }

    public function test_checklist_update_is_owner_only(): void
    {
        $this->asOther();
        $this->putJson("/api/inspections/{$this->inspection->id}/items/{$this->item->id}", ['result' => 'fail'])
            ->assertForbidden();
        $this->assertSame('pass', $this->item->fresh()->result);
    }

    public function test_adding_a_finding_is_owner_only(): void
    {
        $this->asOther();
        $this->postJson('/api/findings', [
            'inspection_id' => $this->inspection->id,
            'title' => 'x',
            'severity' => 'low',
        ])->assertForbidden();
        $this->assertSame(0, Finding::count());
    }

    public function test_updating_a_finding_is_owner_only(): void
    {
        $finding = Finding::factory()->create(['inspection_id' => $this->inspection->id, 'status' => 'open']);
        $this->asOther();
        $this->putJson("/api/findings/{$finding->id}", ['status' => 'resolved'])->assertForbidden();
        $this->assertSame('open', $finding->fresh()->status);
    }

    public function test_uploading_evidence_is_owner_only(): void
    {
        $this->asOther();
        $this->post('/api/evidence', [
            'file' => UploadedFile::fake()->image('a.jpg'),
            'inspection_id' => $this->inspection->id,
        ], ['Accept' => 'application/json'])->assertForbidden();
        $this->assertSame(0, Evidence::count());
    }

    public function test_deleting_evidence_is_owner_only(): void
    {
        $evidence = Evidence::create([
            'inspection_id' => $this->inspection->id,
            'file_path' => 'evidence/x.jpg',
            'captured_at' => now(),
        ]);
        $this->asOther();
        $this->deleteJson("/api/evidence/{$evidence->id}")->assertForbidden();
        $this->assertModelExists($evidence);
    }

    public function test_signing_is_owner_only(): void
    {
        $this->asOther();
        $this->post('/api/signatures', [
            'file' => UploadedFile::fake()->image('s.png'),
            'inspection_id' => $this->inspection->id,
            'type' => 'customer',
            'signer_name' => 'X',
        ], ['Accept' => 'application/json'])->assertForbidden();
    }

    public function test_owner_and_admin_can_write(): void
    {
        Sanctum::actingAs($this->owner);
        $this->putJson("/api/inspections/{$this->inspection->id}/items/{$this->item->id}", ['result' => 'fail'])
            ->assertOk();

        Sanctum::actingAs(User::factory()->admin()->create());
        $this->putJson("/api/inspections/{$this->inspection->id}/items/{$this->item->id}", ['result' => 'pass'])
            ->assertOk();
    }
}
