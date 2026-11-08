<?php

namespace Tests\Feature;

use App\Filament\Resources\InspectorResource\Pages\CreateInspector;
use App\Models\Inspector;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Livewire\Livewire;
use Tests\TestCase;

/** QC-022: inspector passwords have at least 8 characters (API + admin). */
class PasswordPolicyTest extends TestCase
{
    use RefreshDatabase;

    public function test_api_rejects_short_passwords(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->postJson('/api/inspectors', [
            'name' => 'New Inspector',
            'email' => 'new@inspectly.test',
            'password' => 'short77',
        ])->assertStatus(422)->assertJsonValidationErrors('password');

        $user = User::factory()->inspector()->create();
        $inspector = Inspector::create(['user_id' => $user->id, 'name' => 'A', 'email' => $user->email, 'status' => 'active']);
        $this->putJson("/api/inspectors/{$inspector->id}", ['password' => 'short77'])
            ->assertStatus(422)->assertJsonValidationErrors('password');

        $this->postJson('/api/inspectors', [
            'name' => 'New Inspector',
            'email' => 'new@inspectly.test',
            'password' => 'longenough',
        ])->assertCreated();
    }

    public function test_admin_form_rejects_short_passwords(): void
    {
        $this->actingAs(User::factory()->admin()->create());

        Livewire::test(CreateInspector::class)
            ->fillForm([
                'name' => 'New Inspector',
                'email' => 'new@inspectly.test',
                'password' => 'short77',
                'status' => 'active',
            ])
            ->call('create')
            ->assertHasFormErrors(['password' => 'min']);
    }
}
