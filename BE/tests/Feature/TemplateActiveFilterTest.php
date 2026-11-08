<?php

namespace Tests\Feature;

use App\Models\InspectionTemplate;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/** QC-025: `?active=1` (docs/api.md, the app) hides inactive templates. */
class TemplateActiveFilterTest extends TestCase
{
    use RefreshDatabase;

    public function test_active_filter_hides_inactive_templates(): void
    {
        InspectionTemplate::factory()->create(['name' => 'Live', 'is_active' => true]);
        InspectionTemplate::factory()->create(['name' => 'Retired', 'is_active' => false]);
        Sanctum::actingAs(User::factory()->inspector()->create());

        $this->getJson('/api/inspection-templates?active=1')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Live');
        $this->getJson('/api/inspection-templates?active_only=1')->assertJsonCount(1, 'data');
        $this->getJson('/api/inspection-templates')->assertJsonCount(2, 'data');
    }
}
