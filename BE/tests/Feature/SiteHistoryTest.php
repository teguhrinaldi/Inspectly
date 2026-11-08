<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Inspection;
use App\Models\Site;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SiteHistoryTest extends TestCase
{
    use RefreshDatabase;

    public function test_history_is_ordered_most_recent_first(): void
    {
        $inspector = User::factory()->inspector()->create();
        $customer = Customer::factory()->create();
        $site = Site::factory()->create(['customer_id' => $customer->id]);
        $otherSite = Site::factory()->create(['customer_id' => $customer->id]);

        $oldest = Inspection::factory()->completed()->create([
            'customer_id' => $customer->id, 'site_id' => $site->id, 'inspector_id' => $inspector->id,
            'scheduled_at' => now()->subDays(60), 'completed_at' => now()->subDays(60),
        ]);
        $middle = Inspection::factory()->completed()->create([
            'customer_id' => $customer->id, 'site_id' => $site->id, 'inspector_id' => $inspector->id,
            'scheduled_at' => now()->subDays(30), 'completed_at' => now()->subDays(30),
        ]);
        $newest = Inspection::factory()->completed()->create([
            'customer_id' => $customer->id, 'site_id' => $site->id, 'inspector_id' => $inspector->id,
            'scheduled_at' => now(), 'completed_at' => now(),
        ]);

        // Belongs to a different site — must not appear in this site's history.
        Inspection::factory()->completed()->create([
            'customer_id' => $customer->id, 'site_id' => $otherSite->id, 'inspector_id' => $inspector->id,
        ]);

        Sanctum::actingAs($inspector);

        $response = $this->getJson("/api/sites/{$site->id}/history");

        $response->assertOk();

        $ids = collect($response->json('data'))->pluck('id')->all();

        $this->assertSame([$newest->id, $middle->id, $oldest->id], $ids);
    }
}
