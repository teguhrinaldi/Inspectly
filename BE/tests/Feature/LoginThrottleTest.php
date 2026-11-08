<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/** QC-022: password guessing on /login is throttled per account + IP. */
class LoginThrottleTest extends TestCase
{
    use RefreshDatabase;

    public function test_repeated_failed_logins_are_throttled(): void
    {
        $user = User::factory()->inspector()->create();

        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/login', ['email' => $user->email, 'password' => 'wrong'])
                ->assertStatus(422);
        }

        $this->postJson('/api/login', ['email' => $user->email, 'password' => 'password'])
            ->assertStatus(429);
    }

    public function test_other_accounts_are_not_blocked(): void
    {
        $victim = User::factory()->inspector()->create();
        $other = User::factory()->inspector()->create();

        for ($i = 0; $i < 6; $i++) {
            $this->postJson('/api/login', ['email' => $victim->email, 'password' => 'wrong']);
        }

        $this->postJson('/api/login', ['email' => $other->email, 'password' => 'password'])
            ->assertOk();
    }
}
