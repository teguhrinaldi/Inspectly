<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\InspectionTemplate;
use App\Models\Site;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/** QC-006: the app must be able to reach every row, not just page one. */
class ListPaginationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Sanctum::actingAs(User::factory()->inspector()->create());
    }

    public function test_sites_can_be_looked_up_by_exact_qr_code(): void
    {
        $customer = Customer::factory()->create();
        Site::factory()->count(20)->create(['customer_id' => $customer->id]);
        $target = Site::factory()->create([
            'customer_id' => $customer->id,
            'name' => 'Zzz Last Site',
            'qr_code' => 'INSPECTLY:SITE:ZZZ-021',
        ]);

        $this->getJson('/api/sites?qr_code=INSPECTLY:SITE:ZZZ-021')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $target->id);
    }

    public function test_reference_lists_honour_per_page(): void
    {
        $customer = Customer::factory()->create();
        Site::factory()->count(20)->create(['customer_id' => $customer->id]);
        InspectionTemplate::factory()->count(20)->create();
        Customer::factory()->count(19)->create();

        foreach (['/api/sites', '/api/inspection-templates', '/api/customers', '/api/inspectors'] as $url) {
            $this->getJson($url.'?per_page=100')
                ->assertOk()
                ->assertJsonPath('meta.per_page', 100);
        }
        $this->getJson('/api/sites?per_page=100')->assertJsonCount(20, 'data');
        $this->getJson('/api/sites?per_page=1000')->assertJsonPath('meta.per_page', 100);
    }
}
