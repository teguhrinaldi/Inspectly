<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Inspection;
use App\Models\InspectionTemplate;
use App\Models\Site;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/**
 * QC-001 (partial): hardening that does not change what the mobile app can
 * do. The app never calls PUT /inspections/{id} and always creates
 * inspections for the signed-in inspector.
 */
class InspectionAuthorizationTest extends TestCase
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
            'status' => Inspection::STATUS_SCHEDULED,
        ]);
    }

    public function test_inspector_cannot_update_inspection_attributes_directly(): void
    {
        $owner = User::factory()->inspector()->create();
        $inspection = $this->inspection($owner);
        Sanctum::actingAs(User::factory()->inspector()->create());

        $this->putJson("/api/inspections/{$inspection->id}", ['status' => 'completed'])
            ->assertForbidden();

        $this->assertSame(Inspection::STATUS_SCHEDULED, $inspection->fresh()->status);
    }

    public function test_admin_can_update_inspection_attributes(): void
    {
        $inspection = $this->inspection(User::factory()->inspector()->create());
        Sanctum::actingAs(User::factory()->create(['role' => User::ROLE_ADMIN]));

        $this->putJson("/api/inspections/{$inspection->id}", ['recurrence' => 'weekly'])
            ->assertOk()
            ->assertJsonPath('data.recurrence', 'weekly');
    }

    public function test_inspector_cannot_create_inspection_for_someone_else(): void
    {
        $me = User::factory()->inspector()->create();
        $other = User::factory()->inspector()->create();
        $template = InspectionTemplate::factory()->create();
        $customer = Customer::factory()->create();
        $site = Site::factory()->create(['customer_id' => $customer->id]);
        Sanctum::actingAs($me);

        $this->postJson('/api/inspections', [
            'template_id' => $template->id,
            'customer_id' => $customer->id,
            'site_id' => $site->id,
            'inspector_id' => $other->id,
        ])->assertStatus(422)->assertJsonValidationErrors('inspector_id');

        $this->postJson('/api/inspections', [
            'template_id' => $template->id,
            'customer_id' => $customer->id,
            'site_id' => $site->id,
            'inspector_id' => $me->id,
        ])->assertCreated();
    }
}
