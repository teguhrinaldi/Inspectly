<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_succeeds_with_valid_credentials(): void
    {
        $user = User::factory()->create([
            'email' => 'inspector@inspectly.test',
            'password' => Hash::make('password'),
            'role' => User::ROLE_INSPECTOR,
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'inspector@inspectly.test',
            'password' => 'password',
        ]);

        $response->assertOk()
            ->assertJsonStructure(['token', 'user' => ['id', 'email', 'role']])
            ->assertJsonPath('user.id', $user->id)
            ->assertJsonPath('user.role', 'inspector');
    }

    public function test_login_fails_with_invalid_credentials(): void
    {
        User::factory()->create([
            'email' => 'inspector@inspectly.test',
            'password' => Hash::make('password'),
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'inspector@inspectly.test',
            'password' => 'wrong-password',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('email');
    }

    public function test_login_requires_email_and_password(): void
    {
        $response = $this->postJson('/api/login', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email', 'password']);
    }

    public function test_unauthenticated_request_is_rejected(): void
    {
        $response = $this->getJson('/api/me');

        $response->assertStatus(401);
    }

    public function test_authenticated_user_can_fetch_me(): void
    {
        $user = User::factory()->create();

        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer '.$token)->getJson('/api/me');

        $response->assertOk()->assertJsonPath('user.id', $user->id);
    }

    public function test_logout_revokes_current_token(): void
    {
        $user = User::factory()->create();
        $tokenResult = $user->createToken('test');

        $this->withHeader('Authorization', 'Bearer '.$tokenResult->plainTextToken)
            ->postJson('/api/logout')
            ->assertOk();

        // The token row backing this access token must be gone from the DB —
        // asserted directly rather than via a second simulated request, since
        // Laravel's RequestGuard caches the resolved user for the lifetime of
        // the test process and won't re-evaluate the (now revoked) token.
        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $tokenResult->accessToken->id,
        ]);
    }
}
