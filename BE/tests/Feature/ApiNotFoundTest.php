<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ApiNotFoundTest extends TestCase
{
    use RefreshDatabase;

    /** QC-052: a missing record is a plain 404, without internal class names. */
    public function test_missing_record_returns_a_plain_404(): void
    {
        Sanctum::actingAs(User::factory()->inspector()->create());

        $this->getJson('/api/inspections/999999')
            ->assertNotFound()
            ->assertExactJson(['message' => 'Not found.']);
    }
}
