<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/** QC-003: API tokens expire after 30 days and expired ones are pruned daily. */
class TokenExpiryTest extends TestCase
{
    use RefreshDatabase;

    public function test_token_works_for_30_days_then_expires(): void
    {
        $token = User::factory()->inspector()->create()->createToken('inspectly-mobile')->plainTextToken;

        $this->travel(29)->days();
        $this->withToken($token)->getJson('/api/me')->assertOk();

        $this->travel(2)->days();
        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/me')->assertUnauthorized();
    }

    public function test_expired_tokens_are_pruned_on_a_schedule(): void
    {
        $this->artisan('schedule:list')
            ->expectsOutputToContain('sanctum:prune-expired')
            ->assertSuccessful();
    }
}
