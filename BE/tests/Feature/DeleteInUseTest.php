<?php

namespace Tests\Feature;

use App\Filament\Resources\CustomerResource\Pages\EditCustomer;
use App\Filament\Resources\SiteResource\Pages\EditSite;
use App\Models\Customer;
use App\Models\Inspection;
use App\Models\InspectionTemplate;
use App\Models\Inspector;
use App\Models\Site;
use App\Models\User;
use Filament\Actions\DeleteAction;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Livewire\Livewire;
use Tests\TestCase;

/** QC-023: conflicts are reported as 4xx / a notice, never as a 500 page. */
class DeleteInUseTest extends TestCase
{
    use RefreshDatabase;

    private function inspectionFor(Customer $customer, Site $site, InspectionTemplate $template): Inspection
    {
        return Inspection::factory()->create([
            'customer_id' => $customer->id,
            'site_id' => $site->id,
            'template_id' => $template->id,
            'inspector_id' => User::factory()->inspector()->create()->id,
        ]);
    }

    public function test_template_in_use_cannot_be_deleted_via_api(): void
    {
        $customer = Customer::factory()->create();
        $site = Site::factory()->create(['customer_id' => $customer->id]);
        $template = InspectionTemplate::factory()->create();
        $this->inspectionFor($customer, $site, $template);
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->deleteJson("/api/inspection-templates/{$template->id}")->assertStatus(409);
        $this->assertModelExists($template);
    }

    public function test_customer_and_site_in_use_are_not_deleted_from_the_admin(): void
    {
        $customer = Customer::factory()->create();
        $site = Site::factory()->create(['customer_id' => $customer->id]);
        $this->inspectionFor($customer, $site, InspectionTemplate::factory()->create());
        $this->actingAs(User::factory()->admin()->create());

        Livewire::test(EditCustomer::class, ['record' => $customer->getKey()])
            ->callAction(DeleteAction::class)
            ->assertNotified();
        Livewire::test(EditSite::class, ['record' => $site->getKey()])
            ->callAction(DeleteAction::class)
            ->assertNotified();

        $this->assertModelExists($customer);
        $this->assertModelExists($site);
    }

    public function test_inspector_email_taken_by_another_login_is_a_validation_error(): void
    {
        $taken = User::factory()->inspector()->create(['email' => 'taken@inspectly.test']);
        $user = User::factory()->inspector()->create();
        $inspector = Inspector::create(['user_id' => $user->id, 'name' => 'A', 'email' => $user->email, 'status' => 'active']);
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->putJson("/api/inspectors/{$inspector->id}", ['email' => $taken->email])
            ->assertStatus(422)
            ->assertJsonValidationErrors('email');
    }
}
