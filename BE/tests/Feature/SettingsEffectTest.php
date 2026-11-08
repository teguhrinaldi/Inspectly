<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Inspection;
use App\Models\InspectionTemplate;
use App\Models\Setting;
use App\Models\Site;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SettingsEffectTest extends TestCase
{
    use RefreshDatabase;

    public function test_default_recurrence_applies_when_request_omits_it(): void
    {
        Setting::put('default_recurrence', Inspection::RECURRENCE_QUARTERLY);
        $inspector = User::factory()->inspector()->create();
        $customer = Customer::factory()->create();
        $site = Site::factory()->create(['customer_id' => $customer->id]);
        $template = InspectionTemplate::factory()->create();
        Sanctum::actingAs($inspector);

        $this->postJson('/api/inspections', [
            'template_id' => $template->id,
            'customer_id' => $customer->id,
            'site_id' => $site->id,
            'inspector_id' => $inspector->id,
        ])->assertCreated()->assertJsonPath('data.recurrence', Inspection::RECURRENCE_QUARTERLY);
    }

    public function test_report_payload_carries_branding(): void
    {
        Setting::put('company_name', 'Acme Inspections');
        $inspector = User::factory()->inspector()->create();
        $inspection = Inspection::factory()->completed()->create(['inspector_id' => $inspector->id]);
        Sanctum::actingAs($inspector);

        $this->getJson("/api/reports/{$inspection->id}")
            ->assertOk()
            ->assertJsonPath('branding.company_name', 'Acme Inspections')
            ->assertJsonPath('branding.report_footer', 'Generated with Inspectly.');
    }
}
