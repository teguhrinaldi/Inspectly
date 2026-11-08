<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Inspection;
use App\Models\InspectionTemplate;
use App\Models\Site;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/** QC-026: the "review" status no longer exists. */
class ReviewStatusRemovedTest extends TestCase
{
    use RefreshDatabase;

    public function test_migration_moves_review_inspections_to_in_progress(): void
    {
        $customer = Customer::factory()->create();
        $id = DB::table('inspections')->insertGetId([
            'template_id' => InspectionTemplate::factory()->create()->id,
            'customer_id' => $customer->id,
            'site_id' => Site::factory()->create(['customer_id' => $customer->id])->id,
            'inspector_id' => User::factory()->inspector()->create()->id,
            'status' => 'review',
            'recurrence' => 'one_time',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $migration = require database_path('migrations/2024_01_03_000004_remove_review_status_from_inspections.php');
        $migration->up();

        $this->assertSame('in_progress', DB::table('inspections')->where('id', $id)->value('status'));
    }

    public function test_review_is_not_an_accepted_status(): void
    {
        $this->assertFalse(defined(Inspection::class.'::STATUS_REVIEW'));
        $customer = Customer::factory()->create();
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->postJson('/api/inspections', [
            'template_id' => InspectionTemplate::factory()->create()->id,
            'customer_id' => $customer->id,
            'site_id' => Site::factory()->create(['customer_id' => $customer->id])->id,
            'inspector_id' => User::factory()->inspector()->create()->id,
            'status' => 'review',
        ])->assertStatus(422)->assertJsonValidationErrors('status');
    }
}
