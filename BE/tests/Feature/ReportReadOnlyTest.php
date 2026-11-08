<?php

namespace Tests\Feature;

use App\Models\Activity;
use App\Models\Customer;
use App\Models\Inspection;
use App\Models\InspectionTemplate;
use App\Models\Site;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/** QC-053: reading a report is a plain GET — it writes nothing. */
class ReportReadOnlyTest extends TestCase
{
    use RefreshDatabase;

    public function test_get_report_does_not_log_activity(): void
    {
        $customer = Customer::factory()->create();
        $inspection = Inspection::factory()->create([
            'template_id' => InspectionTemplate::factory()->create()->id,
            'customer_id' => $customer->id,
            'site_id' => Site::factory()->create(['customer_id' => $customer->id])->id,
            'inspector_id' => User::factory()->inspector()->create()->id,
        ]);
        Sanctum::actingAs(User::factory()->inspector()->create());

        $this->getJson("/api/reports/{$inspection->id}")->assertOk();
        $this->getJson("/api/reports/{$inspection->id}")->assertOk();

        $this->assertSame(0, Activity::count());
    }
}
