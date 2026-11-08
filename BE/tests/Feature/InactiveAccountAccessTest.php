<?php

namespace Tests\Feature;

use App\Models\Inspector;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/** QC-003 / QC-004: a deactivated or removed inspector loses API access. */
class InactiveAccountAccessTest extends TestCase
{
    use RefreshDatabase;

    private function inspectorWithToken(): array
    {
        $user = User::factory()->inspector()->create();
        $inspector = Inspector::create([
            'user_id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'status' => 'active',
        ]);

        return [$user, $inspector, $user->createToken('inspectly-mobile')->plainTextToken];
    }

    public function test_existing_token_stops_working_when_user_is_deactivated(): void
    {
        [$user, , $token] = $this->inspectorWithToken();

        $this->withToken($token)->getJson('/api/me')->assertOk();

        // Deactivated directly in the database (e.g. by another process), so
        // the per-request check must catch it even if tokens survive.
        User::whereKey($user->id)->update(['status' => 'inactive']);
        $this->app['auth']->forgetGuards();

        $this->withToken($token)->getJson('/api/me')->assertUnauthorized();
    }

    public function test_deactivating_a_user_revokes_their_tokens(): void
    {
        [$user] = $this->inspectorWithToken();

        $user->update(['status' => 'inactive']);

        $this->assertSame(0, $user->tokens()->count());
    }
}
